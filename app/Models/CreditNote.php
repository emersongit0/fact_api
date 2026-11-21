<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/** Nota electrónica independiente del comprobante que corrige. */
class CreditNote extends Model
{
    use HasFactory;

    protected $fillable = [
        'company_id', 'branch_id', 'client_id', 'invoice_id', 'tipo_documento', 'serie', 'correlativo',
        'tipo_doc_afectado', 'num_doc_afectado', 'cod_motivo', 'des_motivo', 'fecha_emision',
        'ubl_version', 'moneda', 'forma_pago_tipo', 'forma_pago_cuotas', 'valor_venta',
        'mto_oper_gravadas', 'mto_oper_exoneradas', 'mto_oper_inafectas', 'mto_oper_gratuitas',
        'mto_igv', 'mto_isc', 'mto_icbper', 'total_impuestos', 'mto_imp_venta', 'detalles',
        'leyendas', 'guias', 'datos_adicionales', 'estado_sunat', 'usuario_creacion',
    ];

    protected $casts = [
        'fecha_emision' => 'date',
        'forma_pago_cuotas' => 'array',
        'detalles' => 'array',
        'leyendas' => 'array',
        'guias' => 'array',
        'datos_adicionales' => 'array',
    ];

    public function company(): BelongsTo
    {
        return $this->belongsTo(Company::class);
    }

    public function branch(): BelongsTo
    {
        return $this->belongsTo(Branch::class);
    }

    public function client(): BelongsTo
    {
        return $this->belongsTo(Client::class);
    }

    public function getNumeroCompletoAttribute(): string
    {
        return $this->serie . '-' . $this->correlativo;
    }
}
