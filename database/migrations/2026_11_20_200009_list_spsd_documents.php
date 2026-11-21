<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    public function up(): void
    {
        if (DB::connection()->getDriverName() === 'sqlite') return;
        DB::unprepared("CREATE PROCEDURE spsd_document_files(
          IN c BIGINT, IN o CHAR(36) CHARACTER SET ascii COLLATE ascii_bin)
          SQL SECURITY INVOKER READS SQL DATA
          SELECT 'factura' AS tipo,i.id,i.numero_completo AS numero,NULL AS referencia,
            i.estado_sunat AS estado,i.mto_imp_venta AS total,i.fecha_emision AS fecha,
            i.xml_path,i.cdr_path,i.respuesta_sunat
          FROM invoices i JOIN spsd_invoice_operations s ON s.invoice_id=i.id AND s.company_id=i.company_id
          WHERE s.company_id=c AND s.operation_id=o
          UNION ALL
          SELECT 'nota',n.id,CONCAT(n.serie,'-',n.correlativo),n.num_doc_afectado,
            n.estado_sunat,n.mto_imp_venta,n.fecha_emision,n.xml_path,n.cdr_path,n.respuesta_sunat
          FROM credit_notes n JOIN spsd_invoice_operations s ON s.invoice_id=n.invoice_id AND s.company_id=n.company_id
          WHERE s.company_id=c AND s.operation_id=o");
    }
    public function down(): void
    {
        if (DB::connection()->getDriverName() !== 'sqlite')
            DB::unprepared('DROP PROCEDURE IF EXISTS spsd_document_files');
    }
};
