<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        if (DB::connection()->getDriverName() === 'sqlite') {
            return;
        }
        Schema::create('spsd_invoice_prepayments', function (Blueprint $table) {
            $table->foreignId('invoice_id')->primary()->constrained('invoices');
            $table->uuid('order_reference')->charset('ascii')->collation('ascii_bin');
            $table->foreignId('settlement_id')->nullable()->constrained('invoices');
        });

        DB::unprepared("CREATE PROCEDURE spsd_mark_prepayment(
          IN i BIGINT, IN r CHAR(36) CHARACTER SET ascii COLLATE ascii_bin)
          SQL SECURITY INVOKER MODIFIES SQL DATA
          INSERT INTO spsd_invoice_prepayments(invoice_id,order_reference) VALUES(i,r)");
        DB::unprepared("CREATE PROCEDURE spsd_get_prepayment(
          IN c BIGINT, IN o CHAR(36) CHARACTER SET ascii COLLATE ascii_bin,
          IN r CHAR(36) CHARACTER SET ascii COLLATE ascii_bin)
          SQL SECURITY INVOKER READS SQL DATA
          SELECT i.id, i.numero_completo, i.mto_imp_venta, i.moneda,
                 cliente.tipo_documento, cliente.numero_documento, DATE(i.fecha_emision) AS fecha_emision
          FROM spsd_invoice_operations s
          JOIN invoices i ON i.id=s.invoice_id AND i.company_id=s.company_id
          JOIN clients cliente ON cliente.id=i.client_id
          JOIN spsd_invoice_prepayments p ON p.invoice_id=i.id
          WHERE s.company_id=c AND s.operation_id=o AND p.order_reference=r
            AND p.settlement_id IS NULL AND i.estado_sunat='ACEPTADO'
          FOR UPDATE");
        DB::unprepared("CREATE PROCEDURE spsd_apply_prepayment(IN a BIGINT, IN f BIGINT)
          SQL SECURITY INVOKER MODIFIES SQL DATA
          BEGIN
            UPDATE spsd_invoice_prepayments SET settlement_id=f
              WHERE invoice_id=a AND settlement_id IS NULL;
            SELECT ROW_COUNT() AS applied;
          END");
    }

    public function down(): void
    {
        if (DB::connection()->getDriverName() === 'sqlite') {
            return;
        }
        DB::unprepared('DROP PROCEDURE IF EXISTS spsd_apply_prepayment');
        DB::unprepared('DROP PROCEDURE IF EXISTS spsd_get_prepayment');
        DB::unprepared('DROP PROCEDURE IF EXISTS spsd_mark_prepayment');
        Schema::dropIfExists('spsd_invoice_prepayments');
    }
};
