<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;

return new class extends Migration {
    public function up(): void
    {
        if (DB::connection()->getDriverName() === 'sqlite') {
            return;
        }
        Schema::create('spsd_beta_prepayment_recoveries', function (Blueprint $table) {
            $table->foreignId('invoice_id')->primary()->constrained('invoices');
            $table->text('original_response');
            $table->timestamp('recovered_at')->useCurrent();
        });
        DB::unprepared("CREATE PROCEDURE spsd_recover_beta_prepayment_3206(IN c BIGINT, IN i BIGINT)
          SQL SECURITY INVOKER MODIFIES SQL DATA
          BEGIN
            DECLARE v_response TEXT;
            SELECT f.respuesta_sunat INTO v_response FROM invoices f
            JOIN companies e ON e.id=f.company_id
            JOIN spsd_invoice_prepayments p ON p.invoice_id=f.id
            WHERE f.id=i AND f.company_id=c AND e.modo_produccion=0
              AND p.settlement_id IS NULL AND f.estado_sunat='RECHAZADO'
              AND f.tipo_operacion='0104' AND f.cdr_path IS NULL
              AND JSON_UNQUOTE(JSON_EXTRACT(f.respuesta_sunat,'$.code'))='3206'
            FOR UPDATE;
            IF v_response IS NULL THEN
              SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Anticipo beta no elegible para correccion 3206';
            END IF;
            INSERT INTO spsd_beta_prepayment_recoveries(invoice_id,original_response)
              VALUES(i,v_response);
            UPDATE invoices SET tipo_operacion='0101',estado_sunat='PENDIENTE',
              respuesta_sunat=NULL WHERE id=i;
          END");
    }

    public function down(): void
    {
        if (DB::connection()->getDriverName() !== 'sqlite') {
            DB::unprepared('DROP PROCEDURE IF EXISTS spsd_recover_beta_prepayment_3206');
            Schema::dropIfExists('spsd_beta_prepayment_recoveries');
        }
    }
};
