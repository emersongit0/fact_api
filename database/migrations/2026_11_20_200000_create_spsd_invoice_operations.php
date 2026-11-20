<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        if (DB::connection()->getDriverName() === 'sqlite') {
            return; // Las pruebas de procedimientos se ejecutan con MySQL.
        }

        Schema::create('spsd_invoice_operations', function (Blueprint $table) {
            $table->unsignedBigInteger('company_id');
            $table->uuid('operation_id')->charset('ascii')->collation('ascii_bin');
            $table->char('fingerprint', 64);
            $table->foreignId('invoice_id')->nullable()->unique()->constrained('invoices');
            $table->primary(['company_id', 'operation_id']);
        });

        DB::unprepared("CREATE PROCEDURE spsd_invoice_reserve(IN c BIGINT, IN o CHAR(36) CHARACTER SET ascii COLLATE ascii_bin, IN h CHAR(64))
          SQL SECURITY INVOKER MODIFIES SQL DATA
          BEGIN
            INSERT INTO spsd_invoice_operations VALUES(c,o,h,NULL)
              ON DUPLICATE KEY UPDATE operation_id=operation_id;
            SELECT fingerprint,invoice_id FROM spsd_invoice_operations
              WHERE company_id=c AND operation_id=o FOR UPDATE;
          END");
        DB::unprepared("CREATE PROCEDURE spsd_invoice_link(IN c BIGINT, IN o CHAR(36) CHARACTER SET ascii COLLATE ascii_bin, IN i BIGINT)
          SQL SECURITY INVOKER MODIFIES SQL DATA
          UPDATE spsd_invoice_operations SET invoice_id=i
          WHERE company_id=c AND operation_id=o AND invoice_id IS NULL");
        DB::unprepared("CREATE PROCEDURE spsd_invoice_find(IN c BIGINT, IN o CHAR(36) CHARACTER SET ascii COLLATE ascii_bin)
          SQL SECURITY INVOKER READS SQL DATA
          SELECT i.id,i.serie,i.correlativo,i.estado_sunat,i.moneda,i.mto_imp_venta,i.respuesta_sunat
          FROM spsd_invoice_operations s JOIN invoices i ON i.id=s.invoice_id AND i.company_id=s.company_id
          WHERE s.company_id=c AND s.operation_id=o");
    }

    public function down(): void
    {
        if (DB::connection()->getDriverName() === 'sqlite') {
            return;
        }

        DB::unprepared('DROP PROCEDURE IF EXISTS spsd_invoice_find');
        DB::unprepared('DROP PROCEDURE IF EXISTS spsd_invoice_link');
        DB::unprepared('DROP PROCEDURE IF EXISTS spsd_invoice_reserve');
        Schema::dropIfExists('spsd_invoice_operations');
    }
};
