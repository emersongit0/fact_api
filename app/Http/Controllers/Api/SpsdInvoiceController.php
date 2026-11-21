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
        abort_unless($invoice['forma_pago_tipo'] === 'Contado', 422, 'El contrato SPSD admite contado simple.');
        $fingerprint = hash('sha256', json_encode($this->ordenar($invoice), JSON_THROW_ON_ERROR));

        // La reserva y el correlativo se confirman juntos. Un segundo proceso espera la misma fila.
        return DB::transaction(function () use ($company, $operation, $fingerprint, $invoice, $documents) {
            $reservation = DB::selectOne('CALL spsd_invoice_reserve(?, ?, ?)', [$company, $operation, $fingerprint]);
            abort_unless(hash_equals($reservation->fingerprint, $fingerprint), 409, 'La operación ya tiene otros datos.');
            $created = $reservation->invoice_id === null;
            if ($created) {
                $document = $documents->createInvoice($invoice);
                DB::statement('CALL spsd_invoice_link(?, ?, ?)', [$company, $operation, $document->id]);
            }

            return $this->response($company, $operation, $created ? 201 : 200);
        });
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
