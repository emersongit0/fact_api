<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    public function up(): void
    {
        if (DB::connection()->getDriverName() === 'sqlite') {
            return;
        }
        DB::unprepared("CREATE PROCEDURE spsd_invoice_claim_send(
          IN c BIGINT, IN o CHAR(36) CHARACTER SET ascii COLLATE ascii_bin, IN total DECIMAL(14,2))
          SQL SECURITY INVOKER MODIFIES SQL DATA
          BEGIN
            UPDATE invoices i JOIN spsd_invoice_operations s ON s.invoice_id=i.id AND s.company_id=i.company_id
            JOIN companies e ON e.id=i.company_id
            SET i.estado_sunat='PROCESANDO'
            WHERE s.company_id=c AND s.operation_id=o AND e.modo_produccion=0
              AND i.estado_sunat='PENDIENTE' AND i.mto_imp_venta=total;
            SELECT ROW_COUNT() AS reserved;
          END");
    }

    public function down(): void
    {
        if (DB::connection()->getDriverName() !== 'sqlite') {
            DB::unprepared('DROP PROCEDURE IF EXISTS spsd_invoice_claim_send');
        }
    }
};
