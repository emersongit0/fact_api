<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreInvoiceRequest;
use App\Services\DocumentService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Laravel\Sanctum\PersonalAccessToken;

class SpsdInvoiceController extends Controller
{
    public function store(StoreInvoiceRequest $request, DocumentService $documents): JsonResponse
    {
        $company = $this->company($request);
        $invoice = $request->validated();
        abort_unless((int) $invoice['company_id'] === $company, 403);
        $operation = strtolower($request->validate(['operacion_id' => 'required|uuid'])['operacion_id']);
        $context = $request->validate([
            'finalidad' => 'sometimes|required|in:ANTICIPO,VENTA_FINAL',
            'pedido_ref' => 'required_with:finalidad,anticipos_operaciones|uuid',
            'anticipos_operaciones' => 'sometimes|required|array|min:1',
            'anticipos_operaciones.*' => 'required|uuid|distinct:ignore_case',
        ]);
        $purpose = $context['finalidad'] ?? 'VENTA_FINAL';
        $order = isset($context['pedido_ref']) ? strtolower($context['pedido_ref']) : null;
        $references = array_map('strtolower', $context['anticipos_operaciones'] ?? []);
        sort($references);
        abort_if($purpose === 'ANTICIPO' && ($references !== [] || $invoice['forma_pago_tipo'] !== 'Contado'),
            422, 'Un anticipo corresponde a un cobro al contado sin anticipos aplicados.');
        $this->validatePayment($invoice);
        // Los pedidos del bloque 3 conservan la huella ya persistida.
        $payload = $context === [] ? $invoice : [$invoice, $purpose, $order, $references];
        $fingerprint = hash('sha256', json_encode($this->ordenar($payload), JSON_THROW_ON_ERROR));

        // La reserva y el correlativo se confirman juntos. Un segundo proceso espera la misma fila.
        return DB::transaction(function () use ($company, $operation, $fingerprint, $invoice, $documents,
            $purpose, $order, $references) {
            $reservation = DB::selectOne('CALL spsd_invoice_reserve(?, ?, ?)', [$company, $operation, $fingerprint]);
            abort_unless(hash_equals($reservation->fingerprint, $fingerprint), 409, 'La operación ya tiene otros datos.');
            $created = $reservation->invoice_id === null;
            if ($created) {
                $advances = $this->resolvePrepayments($company, $order, $references, $invoice);
                if ($advances !== []) {
                    $invoice['anticipos'] = array_column($advances, 'reference');
                }
                $document = $documents->createInvoice($invoice);
                if ($invoice['forma_pago_tipo'] === 'Credito') {
                    abort_unless(bccomp((string) $document->mto_imp_venta,
                        (string) array_values($invoice['forma_pago_cuotas'])[0]['monto'], 2) === 0,
                        422, 'La cuota debe coincidir con el importe total de la factura.');
                }
                DB::statement('CALL spsd_invoice_link(?, ?, ?)', [$company, $operation, $document->id]);
                if ($purpose === 'ANTICIPO') {
                    DB::statement('CALL spsd_mark_prepayment(?, ?)', [$document->id, $order]);
                }
                foreach ($advances as $advance) {
                    $result = DB::selectOne('CALL spsd_apply_prepayment(?, ?)', [$advance['id'], $document->id]);
                    abort_unless((int) $result->applied === 1, 409, 'El anticipo ya fue aplicado.');
                }
            }

            return $this->response($company, $operation, $created ? 201 : 200);
        });
    }

    private function resolvePrepayments(int $company, ?string $order, array $references, array $invoice): array
    {
        $advances = [];
        foreach ($references as $reference) {
            $row = DB::selectOne('CALL spsd_get_prepayment(?, ?, ?)', [$company, $reference, $order]);
            abort_if($row === null, 409, 'El anticipo no está aceptado, disponible o asociado al pedido.');
            abort_unless($row->moneda === $invoice['moneda']
                && (string) $row->tipo_documento === $invoice['client']['tipo_documento']
                && $row->numero_documento === $invoice['client']['numero_documento']
                && $row->fecha_emision <= date('Y-m-d', strtotime($invoice['fecha_emision'])),
                422, 'Los datos del anticipo no coinciden con la regularización.');
            $advances[] = ['id' => $row->id, 'reference' => [
                'numero_documento' => $row->numero_completo,
                'total' => $row->mto_imp_venta,
            ]];
        }
        return $advances;
    }

    private function validatePayment(array $invoice): void
    {
        $installments = $invoice['forma_pago_cuotas'] ?? [];
        if ($invoice['forma_pago_tipo'] === 'Contado') {
            abort_unless($installments === [], 422, 'Una factura al contado no admite cuotas.');
            return;
        }

        // Primer caso a crédito: la venta completa sigue pendiente en una cuota.
        abort_unless(count($installments) === 1, 422, 'La factura a crédito requiere una cuota.');
        $installment = array_values($installments)[0];
        validator(['cuota' => $installment, 'emision' => $invoice['fecha_emision']], [
            'cuota.monto' => 'required|decimal:0,2|gt:0',
            'cuota.moneda' => 'required|in:'.$invoice['moneda'],
            'cuota.fecha_pago' => 'required|date_format:Y-m-d|after:emision',
        ])->validate();
    }

    public function show(Request $request, string $operation): JsonResponse
    {
        return $this->response($this->company($request), strtolower($operation), 200);
    }

    public function send(Request $request, string $operation, DocumentService $documents): JsonResponse
    {
        $company = $this->company($request);
        $operation = strtolower($operation);
        $total = $request->validate(['total' => 'required|decimal:0,2|gt:0'])['total'];
        $row = DB::selectOne('CALL spsd_invoice_find(?, ?)', [$company, $operation]);
        abort_if($row === null, 404);
        $invoice = \App\Models\Invoice::with(['company', 'branch', 'client'])->findOrFail($row->id);
        abort_unless(!$invoice->company->modo_produccion
            && $invoice->company->getInvoiceEndpoint() === 'https://e-beta.sunat.gob.pe/ol-ti-itcpfegem-beta/billService', 409);

        // Confirmar la reserva antes de contactar a SUNAT. Si el proceso cae, se conserva PROCESANDO.
        $claim = DB::selectOne('CALL spsd_invoice_claim_send(?, ?, ?)', [$company, $operation, $total]);
        if ((int) $claim->reserved === 1) {
            $documents->sendToSunat($invoice, 'invoice');
        }
        return $this->response($company, $operation, 200);
    }

    private function company(Request $request): int
    {
        $user = $request->user();
        $token = $user->currentAccessToken();
        abort_unless($user->active && !$user->isLocked()
            && $user->company_id && $token instanceof PersonalAccessToken
            && in_array('spsd:facturar', $token->abilities, true), 403);

        return (int) $user->company_id;
    }

    public function creditNote(Request $request, string $operation, DocumentService $documents): JsonResponse
    {
        return $this->correction($request, $operation, $documents, false);
    }

    public function partialCreditNote(Request $request, string $operation, DocumentService $documents): JsonResponse
    {
        return $this->correction($request, $operation, $documents, true);
    }

    private function correction(Request $request, string $operation, DocumentService $documents, bool $partial): JsonResponse
    {
        $company = $this->company($request);
        $token = $request->user()->currentAccessToken();
        abort_unless(in_array('spsd:corregir', $token->abilities, true), 403);
        $reason = $request->validate(['motivo' => 'required|string|min:5|max:250'])['motivo'];
        $return = $partial ? $request->validate([
            'linea' => 'required|integer|min:1',
            'cantidad' => 'required|integer|min:1',
            'importe_esperado' => 'required|decimal:0,2|gt:0',
        ]) : [];
        $row = DB::selectOne('CALL spsd_invoice_find(?, ?)', [$company, strtolower($operation)]);
        abort_if($row === null, 404);
        $invoice = \App\Models\Invoice::with('company')->findOrFail($row->id);
        abort_unless(!$invoice->company->modo_produccion
            && $invoice->company->getInvoiceEndpoint() === 'https://e-beta.sunat.gob.pe/ol-ti-itcpfegem-beta/billService', 409);
        try {
            if (!$partial && (float) $invoice->mto_anticipos > 0) {
                return $this->settlementCorrection($company, $invoice, $reason, $documents);
            }
            $note = DB::transaction(function () use ($documents, $invoice, $reason, $partial, $return) {
                $date = now('America/Lima')->toDateString();
                if (!$partial) {
                    return $documents->createFullInvoiceCreditNote($invoice, $reason, $date);
                }
                $note = $documents->createPartialReturnCreditNote(
                    $invoice, $reason, $date, (int) $return['linea'], (int) $return['cantidad']
                );
                abort_unless(bccomp((string) $note->mto_imp_venta, (string) $return['importe_esperado'], 2) === 0,
                    422, 'El importe del retorno no coincide con la nota de crédito.');
                return $note;
            });
        } catch (\InvalidArgumentException $e) {
            abort(409, $e->getMessage());
        }
        $claim = DB::selectOne('CALL spsd_claim_credit_note(?, ?)', [$company, $note->id]);
        if ((int) $claim->reserved === 1) {
            $documents->sendToSunat($note, 'credit_note');
        }
        $note->refresh();
        return response()->json([
            'nota' => $note->numero_completo,
            'factura' => $note->num_doc_afectado,
            'estado' => $note->estado_sunat,
            'total' => $note->mto_imp_venta,
            'respuesta_sunat' => $note->respuesta_sunat,
        ]);
    }

    private function settlementCorrection(int $company, \App\Models\Invoice $invoice,
        string $reason, DocumentService $documents): JsonResponse
    {
        $rows = DB::select('CALL spsd_settlement_documents(?, ?)', [$company, $invoice->id]);
        abort_unless(count($rows) > 1, 409, 'No se encuentran los anticipos vinculados.');
        $notes = DB::transaction(function () use ($rows, $invoice, $reason, $documents) {
            $notes = [];
            foreach ($rows as $row) {
                $original = \App\Models\Invoice::with('company')->findOrFail($row->id);
                abort_unless($original->company_id === $invoice->company_id
                    && $original->client_id === $invoice->client_id && $original->moneda === $invoice->moneda,
                    409, 'Los comprobantes no pertenecen a la misma operación.');
                $notes[] = $original->id === $invoice->id
                    ? $documents->createBetaSettlementCreditNote($original, $reason, now('America/Lima')->toDateString())
                    : $documents->createFullInvoiceCreditNote($original, $reason, now('America/Lima')->toDateString());
            }
            $sum = '0.00';
            foreach ($notes as $note) $sum = bcadd($sum, (string) $note->mto_imp_venta, 2);
            $expected = bcadd((string) $invoice->mto_imp_venta, (string) $invoice->mto_anticipos, 2);
            abort_unless(bccomp($sum, $expected, 2) === 0, 409, 'Las notas no concilian con la venta.');
            return $notes;
        });
        $total = '0.00';
        $accepted = true;
        $result = [];
        foreach ($notes as $note) {
            $claim = DB::selectOne('CALL spsd_claim_credit_note(?, ?)', [$company, $note->id]);
            if ((int) $claim->reserved === 1) $documents->sendToSunat($note, 'credit_note');
            $note->refresh();
            $accepted = $accepted && $note->estado_sunat === 'ACEPTADO' && !empty($note->cdr_path);
            $total = bcadd($total, (string) $note->mto_imp_venta, 2);
            $result[] = ['nota' => $note->numero_completo, 'factura' => $note->num_doc_afectado,
                'importe' => $note->mto_imp_venta, 'estado' => $note->estado_sunat];
        }
        return response()->json(['nota' => 'GRUPO-'.$invoice->numero_completo,
            'factura' => $invoice->numero_completo, 'estado' => $accepted ? 'ACEPTADO' : 'EN_REVISION',
            'total' => $total, 'documentos' => $result]);
    }

    private function response(int $company, string $operation, int $status): JsonResponse
    {
        $document = DB::selectOne('CALL spsd_invoice_find(?, ?)', [$company, $operation]);
        abort_if($document === null, 404);

        return response()->json([
            'operacion_id' => $operation,
            'tipo_documento' => '01',
            'documento_id' => $document->id,
            'serie' => $document->serie,
            'correlativo' => $document->correlativo,
            'estado_remoto' => $document->estado_sunat ?? 'PENDIENTE',
            'moneda' => $document->moneda,
            'total' => $document->mto_imp_venta,
            'respuesta_sunat' => $document->respuesta_sunat,
        ], $status);
    }

    public function files(Request $request, string $operation): JsonResponse
    {
        $rows = DB::select('CALL spsd_document_files(?, ?)', [$this->company($request), strtolower($operation)]);
        foreach ($rows as $row) {
            $row->xml = !empty($row->xml_path);
            $row->cdr = !empty($row->cdr_path);
            $row->anticipos = $row->tipo === 'factura'
                ? array_column(\App\Models\Invoice::findOrFail($row->id)->anticipos ?? [], 'numero_documento')
                : [];
            unset($row->xml_path, $row->cdr_path);
        }
        return response()->json($rows);
    }

    public function download(Request $request, string $operation, string $type, string $id, string $format)
    {
        abort_unless(in_array($format, ['pdf', 'xml', 'cdr'], true), 404);
        $rows = DB::select('CALL spsd_document_files(?, ?)', [$this->company($request), strtolower($operation)]);
        $row = collect($rows)->first(fn($row) => $row->tipo === $type && (string) $row->id === $id);
        abort_if($row === null, 404);
        if ($format === 'pdf') {
            $pdf = app(\App\Services\PdfService::class);
            $bytes = $type === 'factura'
                ? $pdf->generateInvoicePdf(\App\Models\Invoice::findOrFail($id))
                : $pdf->generateCreditNotePdf(\App\Models\CreditNote::findOrFail($id));
            return response($bytes)->header('Content-Type', 'application/pdf');
        }
        $path = $format === 'xml' ? $row->xml_path : $row->cdr_path;
        $storage = \Illuminate\Support\Facades\Storage::disk('public');
        abort_unless($path && $storage->exists($path), 404);
        return response($storage->get($path))->header('Content-Type',
            $format === 'xml' ? 'application/xml' : 'application/zip');
    }

    private function ordenar(array $datos): array
    {
        if (!array_is_list($datos)) {
            ksort($datos);
        }
        foreach ($datos as &$valor) {
            if (is_array($valor)) {
                $valor = $this->ordenar($valor);
            }
        }

        return $datos;
    }
}
