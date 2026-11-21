<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    public function up(): void
    {
        if (DB::connection()->getDriverName() === 'sqlite') {
            return;
        }
        DB::unprepared("CREATE PROCEDURE spsd_recover_beta_settlement_3287(IN c BIGINT, IN i BIGINT)
          SQL SECURITY INVOKER MODIFIES SQL DATA
          BEGIN
            DECLARE original TEXT;
            SELECT f.respuesta_sunat INTO original FROM invoices f
            JOIN companies e ON e.id=f.company_id
            WHERE f.id=i AND f.company_id=c AND e.modo_produccion=0
              AND f.estado_sunat='RECHAZADO' AND f.cdr_path IS NULL AND f.mto_anticipos>0
              AND JSON_UNQUOTE(JSON_EXTRACT(f.respuesta_sunat,'$.code'))='3287'
              AND EXISTS (SELECT 1 FROM spsd_invoice_prepayments p WHERE p.settlement_id=f.id)
            FOR UPDATE;
            IF original IS NULL THEN
              SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Regularizacion beta no elegible para correccion 3287';
            END IF;
            INSERT INTO spsd_beta_prepayment_recoveries(invoice_id,original_response) VALUES(i,original);
            UPDATE invoices SET estado_sunat='PENDIENTE',respuesta_sunat=NULL WHERE id=i;
          END");
    }

    public function down(): void
    {
        if (DB::connection()->getDriverName() !== 'sqlite') {
            DB::unprepared('DROP PROCEDURE IF EXISTS spsd_recover_beta_settlement_3287');
        }
    }
};
