<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    public function up(): void
    {
        if (DB::connection()->getDriverName() === 'sqlite') return;
        DB::unprepared("CREATE PROCEDURE spsd_settlement_documents(IN c BIGINT, IN i BIGINT)
          SQL SECURITY INVOKER READS SQL DATA
          SELECT f.id FROM invoices f
          WHERE f.company_id=c AND (f.id=i OR EXISTS
            (SELECT 1 FROM spsd_invoice_prepayments p WHERE p.invoice_id=f.id AND p.settlement_id=i))
          ORDER BY f.id");
    }

    public function down(): void
    {
        if (DB::connection()->getDriverName() !== 'sqlite')
            DB::unprepared('DROP PROCEDURE IF EXISTS spsd_settlement_documents');
    }
};
