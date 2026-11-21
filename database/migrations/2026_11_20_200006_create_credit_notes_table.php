<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('credit_notes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained();
            $table->foreignId('branch_id')->constrained();
            $table->foreignId('client_id')->constrained();
            $table->foreignId('invoice_id')->nullable()->unique()->constrained('invoices');
            $table->char('tipo_documento', 2)->default('07');
            $table->string('serie', 4);
            $table->string('correlativo', 8);
            $table->char('tipo_doc_afectado', 2);
            $table->string('num_doc_afectado', 20);
            $table->char('cod_motivo', 2);
            $table->string('des_motivo', 250);
            $table->date('fecha_emision');
            $table->string('ubl_version', 4)->default('2.1');
            $table->char('moneda', 3);
            $table->string('forma_pago_tipo', 10);
            foreach (['forma_pago_cuotas', 'detalles', 'leyendas', 'guias', 'datos_adicionales'] as $field) {
                $table->json($field)->nullable();
            }
            foreach (['valor_venta', 'mto_oper_gravadas', 'mto_oper_exoneradas', 'mto_oper_inafectas',
                'mto_oper_gratuitas', 'mto_igv', 'mto_isc', 'mto_icbper', 'total_impuestos', 'mto_imp_venta'] as $field) {
                $table->decimal($field, 14, 2)->default(0);
            }
            $table->string('estado_sunat', 20)->default('PENDIENTE');
            $table->text('respuesta_sunat')->nullable();
            foreach (['xml_path', 'cdr_path', 'pdf_path', 'codigo_hash', 'usuario_creacion'] as $field) {
                $table->string($field)->nullable();
            }
            $table->timestamps();
            $table->unique(['company_id', 'serie', 'correlativo']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('credit_notes');
    }
};
