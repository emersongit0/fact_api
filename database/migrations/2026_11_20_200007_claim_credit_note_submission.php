<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    public function up(): void
    {
        if (DB::connection()->getDriverName() === 'sqlite') {
            return;
        }
        DB::unprepared("CREATE PROCEDURE spsd_claim_credit_note(IN c BIGINT, IN n BIGINT)
          SQL SECURITY INVOKER MODIFIES SQL DATA
          BEGIN
            UPDATE credit_notes cn JOIN companies e ON e.id=cn.company_id
            SET cn.estado_sunat='PROCESANDO'
            WHERE cn.id=n AND cn.company_id=c AND cn.invoice_id IS NOT NULL
              AND e.modo_produccion=0 AND cn.estado_sunat='PENDIENTE';
            SELECT ROW_COUNT() AS reserved;
          END");
    }

    public function down(): void
    {
        if (DB::connection()->getDriverName() !== 'sqlite') {
            DB::unprepared('DROP PROCEDURE IF EXISTS spsd_claim_credit_note');
        }
    }
};
