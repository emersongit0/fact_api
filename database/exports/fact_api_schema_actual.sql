-- Estructura actual sin datos privados. Importar en una base vacia.

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
DROP TABLE IF EXISTS `boletas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `boletas` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `company_id` bigint unsigned NOT NULL,
  `branch_id` bigint unsigned NOT NULL,
  `client_id` bigint unsigned NOT NULL,
  `daily_summary_id` bigint unsigned DEFAULT NULL,
  `tipo_documento` varchar(2) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '03',
  `serie` varchar(4) COLLATE utf8mb4_unicode_ci NOT NULL,
  `correlativo` varchar(8) COLLATE utf8mb4_unicode_ci NOT NULL,
  `numero_completo` varchar(15) COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha_emision` date NOT NULL,
  `ubl_version` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '2.1',
  `tipo_operacion` varchar(4) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0101',
  `moneda` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PEN',
  `metodo_envio` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'individual',
  `valor_venta` decimal(12,2) NOT NULL DEFAULT '0.00',
  `mto_oper_gravadas` decimal(12,2) NOT NULL DEFAULT '0.00',
  `mto_oper_exoneradas` decimal(12,2) NOT NULL DEFAULT '0.00',
  `mto_oper_inafectas` decimal(12,2) NOT NULL DEFAULT '0.00',
  `mto_oper_gratuitas` decimal(12,2) NOT NULL DEFAULT '0.00',
  `mto_igv_gratuitas` decimal(12,2) NOT NULL DEFAULT '0.00',
  `mto_igv` decimal(12,2) NOT NULL DEFAULT '0.00',
  `mto_base_ivap` decimal(12,2) NOT NULL DEFAULT '0.00' COMMENT 'Base imponible IVAP',
  `mto_ivap` decimal(12,2) NOT NULL DEFAULT '0.00' COMMENT 'Monto IVAP',
  `mto_isc` decimal(12,2) NOT NULL DEFAULT '0.00',
  `mto_icbper` decimal(12,2) NOT NULL DEFAULT '0.00',
  `total_impuestos` decimal(12,2) NOT NULL DEFAULT '0.00',
  `sub_total` decimal(12,2) NOT NULL DEFAULT '0.00',
  `mto_imp_venta` decimal(12,2) NOT NULL DEFAULT '0.00',
  `detalles` json NOT NULL,
  `leyendas` json DEFAULT NULL,
  `datos_adicionales` json DEFAULT NULL,
  `xml_path` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cdr_path` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pdf_path` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `estado_sunat` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDIENTE',
  `consulta_cpe_estado` varchar(2) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `consulta_cpe_respuesta` json DEFAULT NULL,
  `consulta_cpe_fecha` timestamp NULL DEFAULT NULL,
  `respuesta_sunat` text COLLATE utf8mb4_unicode_ci,
  `codigo_hash` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `usuario_creacion` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `boletas_company_id_serie_correlativo_unique` (`company_id`,`serie`,`correlativo`),
  KEY `boletas_branch_id_foreign` (`branch_id`),
  KEY `boletas_client_id_foreign` (`client_id`),
  KEY `boletas_company_id_branch_id_index` (`company_id`,`branch_id`),
  KEY `boletas_fecha_emision_index` (`fecha_emision`),
  KEY `boletas_estado_sunat_index` (`estado_sunat`),
  KEY `boletas_consulta_cpe_estado_index` (`consulta_cpe_estado`),
  KEY `boletas_consulta_cpe_fecha_index` (`consulta_cpe_fecha`),
  CONSTRAINT `boletas_branch_id_foreign` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`) ON DELETE CASCADE,
  CONSTRAINT `boletas_client_id_foreign` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`) ON DELETE CASCADE,
  CONSTRAINT `boletas_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `branches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `branches` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `company_id` bigint unsigned NOT NULL,
  `codigo` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nombre` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `direccion` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ubigeo` varchar(6) COLLATE utf8mb4_unicode_ci NOT NULL,
  `distrito` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `provincia` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `departamento` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `telefono` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `series_factura` json DEFAULT NULL,
  `series_boleta` json DEFAULT NULL,
  `series_nota_credito` json DEFAULT NULL,
  `series_nota_debito` json DEFAULT NULL,
  `series_guia_remision` json DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `branches_company_id_codigo_unique` (`company_id`,`codigo`),
  CONSTRAINT `branches_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `cache_locks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache_locks` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `clients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `clients` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `company_id` bigint unsigned DEFAULT NULL,
  `tipo_documento` varchar(1) COLLATE utf8mb4_unicode_ci NOT NULL,
  `numero_documento` varchar(15) COLLATE utf8mb4_unicode_ci NOT NULL,
  `razon_social` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nombre_comercial` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `direccion` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ubigeo` varchar(6) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `distrito` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `provincia` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `departamento` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `telefono` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `clients_tipo_documento_numero_documento_unique` (`tipo_documento`,`numero_documento`),
  KEY `clients_company_id_foreign` (`company_id`),
  CONSTRAINT `clients_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `companies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `companies` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `ruc` varchar(11) COLLATE utf8mb4_unicode_ci NOT NULL,
  `razon_social` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nombre_comercial` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `direccion` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ubigeo` varchar(6) COLLATE utf8mb4_unicode_ci NOT NULL,
  `distrito` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `provincia` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `departamento` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `telefono` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `web` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `usuario_sol` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `clave_sol` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `api_sunat_client_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `api_sunat_client_secret` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `api_sunat_endpoint_beta` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT 'https://api-beta.sunat.gob.pe',
  `api_sunat_endpoint_produccion` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT 'https://api.sunat.gob.pe',
  `certificado_pem` text COLLATE utf8mb4_unicode_ci,
  `certificado_password` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `endpoint_beta` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `endpoint_produccion` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `modo_produccion` tinyint(1) NOT NULL DEFAULT '0',
  `logo_path` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `companies_ruc_unique` (`ruc`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `company_configurations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `company_configurations` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `company_id` bigint unsigned NOT NULL,
  `config_type` enum('tax_settings','invoice_settings','gre_settings','document_settings') COLLATE utf8mb4_unicode_ci NOT NULL,
  `environment` enum('general','beta','produccion') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'general',
  `service_type` enum('general','facturacion','guias_remision','resumenes_diarios','comunicaciones_baja','retenciones') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `config_data` json NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `priority` int NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_company_config` (`company_id`,`config_type`,`environment`,`service_type`),
  KEY `company_configurations_company_id_config_type_index` (`company_id`,`config_type`),
  KEY `company_configurations_company_id_environment_index` (`company_id`,`environment`),
  KEY `company_configurations_company_id_config_type_environment_index` (`company_id`,`config_type`,`environment`),
  KEY `company_configurations_company_id_service_type_environment_index` (`company_id`,`service_type`,`environment`),
  CONSTRAINT `company_configurations_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `correlatives`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `correlatives` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `branch_id` bigint unsigned NOT NULL,
  `tipo_documento` varchar(2) COLLATE utf8mb4_unicode_ci NOT NULL,
  `serie` varchar(4) COLLATE utf8mb4_unicode_ci NOT NULL,
  `correlativo_actual` int unsigned NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `correlatives_branch_id_tipo_documento_serie_unique` (`branch_id`,`tipo_documento`,`serie`),
  KEY `correlatives_branch_id_tipo_documento_index` (`branch_id`,`tipo_documento`),
  CONSTRAINT `correlatives_branch_id_foreign` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `credit_notes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `credit_notes` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `company_id` bigint unsigned NOT NULL,
  `branch_id` bigint unsigned NOT NULL,
  `client_id` bigint unsigned NOT NULL,
  `invoice_id` bigint unsigned DEFAULT NULL,
  `tipo_documento` char(2) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '07',
  `serie` varchar(4) COLLATE utf8mb4_unicode_ci NOT NULL,
  `correlativo` varchar(8) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tipo_doc_afectado` char(2) COLLATE utf8mb4_unicode_ci NOT NULL,
  `num_doc_afectado` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `cod_motivo` char(2) COLLATE utf8mb4_unicode_ci NOT NULL,
  `des_motivo` varchar(250) COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha_emision` date NOT NULL,
  `ubl_version` varchar(4) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '2.1',
  `moneda` char(3) COLLATE utf8mb4_unicode_ci NOT NULL,
  `forma_pago_tipo` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `forma_pago_cuotas` json DEFAULT NULL,
  `detalles` json DEFAULT NULL,
  `leyendas` json DEFAULT NULL,
  `guias` json DEFAULT NULL,
  `datos_adicionales` json DEFAULT NULL,
  `valor_venta` decimal(14,2) NOT NULL DEFAULT '0.00',
  `mto_oper_gravadas` decimal(14,2) NOT NULL DEFAULT '0.00',
  `mto_oper_exoneradas` decimal(14,2) NOT NULL DEFAULT '0.00',
  `mto_oper_inafectas` decimal(14,2) NOT NULL DEFAULT '0.00',
  `mto_oper_gratuitas` decimal(14,2) NOT NULL DEFAULT '0.00',
  `mto_igv` decimal(14,2) NOT NULL DEFAULT '0.00',
  `mto_isc` decimal(14,2) NOT NULL DEFAULT '0.00',
  `mto_icbper` decimal(14,2) NOT NULL DEFAULT '0.00',
  `total_impuestos` decimal(14,2) NOT NULL DEFAULT '0.00',
  `mto_imp_venta` decimal(14,2) NOT NULL DEFAULT '0.00',
  `estado_sunat` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDIENTE',
  `respuesta_sunat` text COLLATE utf8mb4_unicode_ci,
  `xml_path` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cdr_path` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pdf_path` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `codigo_hash` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `usuario_creacion` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `credit_notes_company_id_serie_correlativo_unique` (`company_id`,`serie`,`correlativo`),
  UNIQUE KEY `credit_notes_invoice_id_unique` (`invoice_id`),
  KEY `credit_notes_branch_id_foreign` (`branch_id`),
  KEY `credit_notes_client_id_foreign` (`client_id`),
  CONSTRAINT `credit_notes_branch_id_foreign` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `credit_notes_client_id_foreign` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`),
  CONSTRAINT `credit_notes_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  CONSTRAINT `credit_notes_invoice_id_foreign` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `failed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `failed_jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `invoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `invoices` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `company_id` bigint unsigned NOT NULL,
  `branch_id` bigint unsigned NOT NULL,
  `client_id` bigint unsigned NOT NULL,
  `tipo_documento` varchar(2) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '01',
  `serie` varchar(4) COLLATE utf8mb4_unicode_ci NOT NULL,
  `correlativo` varchar(8) COLLATE utf8mb4_unicode_ci NOT NULL,
  `numero_completo` varchar(15) COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha_emision` date NOT NULL,
  `fecha_vencimiento` date DEFAULT NULL,
  `ubl_version` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '2.1',
  `tipo_operacion` varchar(4) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0101',
  `moneda` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PEN',
  `forma_pago_tipo` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Contado',
  `forma_pago_cuotas` json DEFAULT NULL,
  `valor_venta` decimal(12,2) NOT NULL DEFAULT '0.00',
  `mto_oper_gravadas` decimal(12,2) NOT NULL DEFAULT '0.00',
  `mto_oper_exoneradas` decimal(12,2) NOT NULL DEFAULT '0.00',
  `mto_oper_inafectas` decimal(12,2) NOT NULL DEFAULT '0.00',
  `mto_oper_exportacion` decimal(12,2) NOT NULL DEFAULT '0.00',
  `mto_oper_gratuitas` decimal(12,2) NOT NULL DEFAULT '0.00',
  `mto_igv_gratuitas` decimal(10,2) NOT NULL DEFAULT '0.00',
  `mto_igv` decimal(12,2) NOT NULL DEFAULT '0.00',
  `mto_base_ivap` decimal(12,2) NOT NULL DEFAULT '0.00' COMMENT 'Base imponible IVAP',
  `mto_ivap` decimal(12,2) NOT NULL DEFAULT '0.00' COMMENT 'Monto IVAP',
  `mto_isc` decimal(12,2) NOT NULL DEFAULT '0.00',
  `mto_icbper` decimal(12,2) NOT NULL DEFAULT '0.00',
  `mto_otros_tributos` decimal(12,2) NOT NULL DEFAULT '0.00',
  `mto_detraccion` decimal(12,2) NOT NULL DEFAULT '0.00',
  `mto_percepcion` decimal(12,2) NOT NULL DEFAULT '0.00',
  `mto_retencion` decimal(12,2) NOT NULL DEFAULT '0.00',
  `total_impuestos` decimal(12,2) NOT NULL DEFAULT '0.00',
  `sub_total` decimal(12,2) NOT NULL DEFAULT '0.00',
  `mto_imp_venta` decimal(12,2) NOT NULL DEFAULT '0.00',
  `mto_anticipos` decimal(12,2) NOT NULL DEFAULT '0.00',
  `detalles` json NOT NULL,
  `leyendas` json DEFAULT NULL,
  `guias` json DEFAULT NULL,
  `documentos_relacionados` json DEFAULT NULL,
  `detraccion` json DEFAULT NULL,
  `percepcion` json DEFAULT NULL,
  `retencion` json DEFAULT NULL,
  `datos_adicionales` json DEFAULT NULL,
  `xml_path` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cdr_path` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pdf_path` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `estado_sunat` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDIENTE',
  `consulta_cpe_estado` varchar(2) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `consulta_cpe_respuesta` json DEFAULT NULL,
  `consulta_cpe_fecha` timestamp NULL DEFAULT NULL,
  `respuesta_sunat` text COLLATE utf8mb4_unicode_ci,
  `codigo_hash` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `usuario_creacion` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `anticipos` json DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `invoices_company_id_serie_correlativo_unique` (`company_id`,`serie`,`correlativo`),
  KEY `invoices_branch_id_foreign` (`branch_id`),
  KEY `invoices_client_id_foreign` (`client_id`),
  KEY `invoices_company_id_branch_id_index` (`company_id`,`branch_id`),
  KEY `invoices_fecha_emision_index` (`fecha_emision`),
  KEY `invoices_estado_sunat_index` (`estado_sunat`),
  KEY `invoices_consulta_cpe_estado_index` (`consulta_cpe_estado`),
  KEY `invoices_consulta_cpe_fecha_index` (`consulta_cpe_fecha`),
  CONSTRAINT `invoices_branch_id_foreign` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`) ON DELETE CASCADE,
  CONSTRAINT `invoices_client_id_foreign` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`) ON DELETE CASCADE,
  CONSTRAINT `invoices_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `job_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_batches` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` mediumtext COLLATE utf8mb4_unicode_ci,
  `cancelled_at` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` tinyint unsigned NOT NULL,
  `reserved_at` int unsigned DEFAULT NULL,
  `available_at` int unsigned NOT NULL,
  `created_at` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `migrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `password_reset_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `permissions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `display_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `category` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'general',
  `is_system` tinyint(1) NOT NULL DEFAULT '0',
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `permissions_name_unique` (`name`),
  KEY `permissions_category_active_index` (`category`,`active`),
  KEY `permissions_name_active_index` (`name`,`active`)
) ENGINE=InnoDB AUTO_INCREMENT=62 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `personal_access_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `personal_access_tokens` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint unsigned NOT NULL,
  `name` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  KEY `personal_access_tokens_expires_at_index` (`expires_at`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `role_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `role_permission` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `role_id` bigint unsigned NOT NULL,
  `permission_id` bigint unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `role_permission_role_id_permission_id_unique` (`role_id`,`permission_id`),
  KEY `role_permission_permission_id_foreign` (`permission_id`),
  CONSTRAINT `role_permission_permission_id_foreign` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `role_permission_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=122 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `display_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `permissions` json DEFAULT NULL,
  `is_system` tinyint(1) NOT NULL DEFAULT '0',
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `roles_name_unique` (`name`),
  KEY `roles_name_active_index` (`name`,`active`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sessions` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint unsigned DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_activity` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `spsd_beta_prepayment_recoveries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `spsd_beta_prepayment_recoveries` (
  `invoice_id` bigint unsigned NOT NULL,
  `original_response` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `recovered_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`invoice_id`),
  CONSTRAINT `spsd_beta_prepayment_recoveries_invoice_id_foreign` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `spsd_invoice_operations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `spsd_invoice_operations` (
  `company_id` bigint unsigned NOT NULL,
  `operation_id` char(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `fingerprint` char(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `invoice_id` bigint unsigned DEFAULT NULL,
  PRIMARY KEY (`company_id`,`operation_id`),
  UNIQUE KEY `spsd_invoice_operations_invoice_id_unique` (`invoice_id`),
  CONSTRAINT `spsd_invoice_operations_invoice_id_foreign` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `spsd_invoice_prepayments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `spsd_invoice_prepayments` (
  `invoice_id` bigint unsigned NOT NULL,
  `order_reference` char(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `settlement_id` bigint unsigned DEFAULT NULL,
  PRIMARY KEY (`invoice_id`),
  KEY `spsd_invoice_prepayments_settlement_id_foreign` (`settlement_id`),
  CONSTRAINT `spsd_invoice_prepayments_invoice_id_foreign` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`),
  CONSTRAINT `spsd_invoice_prepayments_settlement_id_foreign` FOREIGN KEY (`settlement_id`) REFERENCES `invoices` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `ubi_distritos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ubi_distritos` (
  `id` varchar(6) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nombre` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `info_busqueda` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `provincia_id` varchar(6) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `region_id` varchar(6) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `ubi_distritos_provincia_id_foreign` (`provincia_id`),
  KEY `ubi_distritos_region_id_foreign` (`region_id`),
  CONSTRAINT `ubi_distritos_provincia_id_foreign` FOREIGN KEY (`provincia_id`) REFERENCES `ubi_provincias` (`id`),
  CONSTRAINT `ubi_distritos_region_id_foreign` FOREIGN KEY (`region_id`) REFERENCES `ubi_regiones` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `ubi_provincias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ubi_provincias` (
  `id` varchar(6) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nombre` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `region_id` varchar(6) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `ubi_provincias_region_id_foreign` (`region_id`),
  CONSTRAINT `ubi_provincias_region_id_foreign` FOREIGN KEY (`region_id`) REFERENCES `ubi_regiones` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `ubi_regiones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ubi_regiones` (
  `id` varchar(6) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nombre` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `role_id` bigint unsigned DEFAULT NULL,
  `company_id` bigint unsigned DEFAULT NULL,
  `user_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'user',
  `allowed_ips` json DEFAULT NULL,
  `permissions` json DEFAULT NULL,
  `restrictions` json DEFAULT NULL,
  `last_login_at` timestamp NULL DEFAULT NULL,
  `last_login_ip` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `failed_login_attempts` int NOT NULL DEFAULT '0',
  `locked_until` timestamp NULL DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `force_password_change` tinyint(1) NOT NULL DEFAULT '0',
  `password_changed_at` timestamp NULL DEFAULT NULL,
  `metadata` json DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`),
  KEY `users_role_id_foreign` (`role_id`),
  KEY `users_company_id_active_index` (`company_id`,`active`),
  KEY `users_user_type_active_index` (`user_type`,`active`),
  KEY `users_last_login_at_index` (`last_login_at`),
  CONSTRAINT `users_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE,
  CONSTRAINT `users_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 DROP PROCEDURE IF EXISTS `spsd_apply_prepayment` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `spsd_apply_prepayment`(IN a BIGINT, IN f BIGINT)
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
            UPDATE spsd_invoice_prepayments SET settlement_id=f
              WHERE invoice_id=a AND settlement_id IS NULL;
            SELECT ROW_COUNT() AS applied;
          END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `spsd_claim_credit_note` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `spsd_claim_credit_note`(IN c BIGINT, IN n BIGINT)
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
            UPDATE credit_notes cn JOIN companies e ON e.id=cn.company_id
            SET cn.estado_sunat='PROCESANDO'
            WHERE cn.id=n AND cn.company_id=c AND cn.invoice_id IS NOT NULL
              AND e.modo_produccion=0 AND cn.estado_sunat='PENDIENTE';
            SELECT ROW_COUNT() AS reserved;
          END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `spsd_document_files` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `spsd_document_files`(
          IN c BIGINT, IN o CHAR(36) CHARACTER SET ascii COLLATE ascii_bin)
    READS SQL DATA
    SQL SECURITY INVOKER
SELECT 'factura' AS tipo,i.id,i.numero_completo AS numero,NULL AS referencia,
            i.estado_sunat AS estado,i.mto_imp_venta AS total,i.fecha_emision AS fecha,
            i.xml_path,i.cdr_path,i.respuesta_sunat
          FROM invoices i JOIN spsd_invoice_operations s ON s.invoice_id=i.id AND s.company_id=i.company_id
          WHERE s.company_id=c AND s.operation_id=o
          UNION ALL
          SELECT 'nota',n.id,CONCAT(n.serie,'-',n.correlativo),n.num_doc_afectado,
            n.estado_sunat,n.mto_imp_venta,n.fecha_emision,n.xml_path,n.cdr_path,n.respuesta_sunat
          FROM credit_notes n JOIN spsd_invoice_operations s ON s.invoice_id=n.invoice_id AND s.company_id=n.company_id
          WHERE s.company_id=c AND s.operation_id=o ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `spsd_get_prepayment` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `spsd_get_prepayment`(
          IN c BIGINT, IN o CHAR(36) CHARACTER SET ascii COLLATE ascii_bin,
          IN r CHAR(36) CHARACTER SET ascii COLLATE ascii_bin)
    READS SQL DATA
    SQL SECURITY INVOKER
SELECT i.id, i.numero_completo, i.mto_imp_venta, i.moneda,
                 cliente.tipo_documento, cliente.numero_documento, DATE(i.fecha_emision) AS fecha_emision
          FROM spsd_invoice_operations s
          JOIN invoices i ON i.id=s.invoice_id AND i.company_id=s.company_id
          JOIN clients cliente ON cliente.id=i.client_id
          JOIN spsd_invoice_prepayments p ON p.invoice_id=i.id
          WHERE s.company_id=c AND s.operation_id=o AND p.order_reference=r
            AND p.settlement_id IS NULL AND i.estado_sunat='ACEPTADO'
          FOR UPDATE ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `spsd_invoice_claim_send` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `spsd_invoice_claim_send`(
          IN c BIGINT, IN o CHAR(36) CHARACTER SET ascii COLLATE ascii_bin, IN total DECIMAL(14,2))
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
            UPDATE invoices i JOIN spsd_invoice_operations s ON s.invoice_id=i.id AND s.company_id=i.company_id
            JOIN companies e ON e.id=i.company_id
            SET i.estado_sunat='PROCESANDO'
            WHERE s.company_id=c AND s.operation_id=o AND e.modo_produccion=0
              AND i.estado_sunat='PENDIENTE' AND i.mto_imp_venta=total;
            SELECT ROW_COUNT() AS reserved;
          END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `spsd_invoice_find` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `spsd_invoice_find`(IN c BIGINT, IN o CHAR(36) CHARACTER SET ascii COLLATE ascii_bin)
    READS SQL DATA
    SQL SECURITY INVOKER
SELECT i.id,i.serie,i.correlativo,i.estado_sunat,i.moneda,i.mto_imp_venta,i.respuesta_sunat
          FROM spsd_invoice_operations s JOIN invoices i ON i.id=s.invoice_id AND i.company_id=s.company_id
          WHERE s.company_id=c AND s.operation_id=o ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `spsd_invoice_link` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `spsd_invoice_link`(IN c BIGINT, IN o CHAR(36) CHARACTER SET ascii COLLATE ascii_bin, IN i BIGINT)
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
UPDATE spsd_invoice_operations SET invoice_id=i
          WHERE company_id=c AND operation_id=o AND invoice_id IS NULL ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `spsd_invoice_reserve` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `spsd_invoice_reserve`(IN c BIGINT, IN o CHAR(36) CHARACTER SET ascii COLLATE ascii_bin, IN h CHAR(64))
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
            INSERT INTO spsd_invoice_operations VALUES(c,o,h,NULL)
              ON DUPLICATE KEY UPDATE operation_id=operation_id;
            SELECT fingerprint,invoice_id FROM spsd_invoice_operations
              WHERE company_id=c AND operation_id=o FOR UPDATE;
          END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `spsd_mark_prepayment` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `spsd_mark_prepayment`(
          IN i BIGINT, IN r CHAR(36) CHARACTER SET ascii COLLATE ascii_bin)
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
INSERT INTO spsd_invoice_prepayments(invoice_id,order_reference) VALUES(i,r) ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `spsd_recover_beta_prepayment_3206` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `spsd_recover_beta_prepayment_3206`(IN c BIGINT, IN i BIGINT)
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
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
          END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `spsd_recover_beta_settlement_3287` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `spsd_recover_beta_settlement_3287`(IN c BIGINT, IN i BIGINT)
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
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
          END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `spsd_settlement_documents` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `spsd_settlement_documents`(IN c BIGINT, IN i BIGINT)
    READS SQL DATA
    SQL SECURITY INVOKER
SELECT f.id FROM invoices f
          WHERE f.company_id=c AND (f.id=i OR EXISTS
            (SELECT 1 FROM spsd_invoice_prepayments p WHERE p.invoice_id=f.id AND p.settlement_id=i))
          ORDER BY f.id ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;


INSERT INTO migrations(id,migration,batch) VALUES (1,'0001_01_01_000000_create_users_table',1);

INSERT INTO migrations(id,migration,batch) VALUES (2,'0001_01_01_000001_create_cache_table',1);

INSERT INTO migrations(id,migration,batch) VALUES (3,'0001_01_01_000002_create_jobs_table',1);

INSERT INTO migrations(id,migration,batch) VALUES (4,'2025_09_01_121617_create_companies_table',1);

INSERT INTO migrations(id,migration,batch) VALUES (5,'2025_09_01_121659_create_branches_table',1);

INSERT INTO migrations(id,migration,batch) VALUES (6,'2025_09_01_121756_create_correlatives_table',1);

INSERT INTO migrations(id,migration,batch) VALUES (7,'2025_09_01_121823_create_clients_table',1);

INSERT INTO migrations(id,migration,batch) VALUES (8,'2025_09_01_122355_create_invoices_table',1);

INSERT INTO migrations(id,migration,batch) VALUES (9,'2025_09_01_122505_create_boletas_table',1);

INSERT INTO migrations(id,migration,batch) VALUES (10,'2025_09_04_155546_create_personal_access_tokens_table',1);

INSERT INTO migrations(id,migration,batch) VALUES (11,'2025_09_04_181325_add_ivap_fields_to_invoices_table',1);

INSERT INTO migrations(id,migration,batch) VALUES (12,'2025_09_04_181406_add_ivap_fields_to_boletas_table',1);

INSERT INTO migrations(id,migration,batch) VALUES (13,'2025_09_06_144953_add_mto_igv_gratuitas_to_boletas_table',1);

INSERT INTO migrations(id,migration,batch) VALUES (14,'2025_09_07_112908_create_roles_table',1);

INSERT INTO migrations(id,migration,batch) VALUES (15,'2025_09_07_113010_create_permissions_table',1);

INSERT INTO migrations(id,migration,batch) VALUES (16,'2025_09_07_113141_create_role_permission_table',1);

INSERT INTO migrations(id,migration,batch) VALUES (17,'2025_09_07_113159_add_security_fields_to_users_table',1);

INSERT INTO migrations(id,migration,batch) VALUES (18,'2025_09_10_114509_create_ubi_regiones_table',1);

INSERT INTO migrations(id,migration,batch) VALUES (19,'2025_09_10_114515_create_ubi_provincias_table',1);

INSERT INTO migrations(id,migration,batch) VALUES (20,'2025_09_10_114526_create_ubi_distritos_table',1);

INSERT INTO migrations(id,migration,batch) VALUES (21,'2025_09_10_120000_create_company_configurations_table',1);

INSERT INTO migrations(id,migration,batch) VALUES (22,'2025_09_10_120001_migrate_company_configurations_data',1);

INSERT INTO migrations(id,migration,batch) VALUES (23,'2025_09_10_120002_remove_configurations_column_from_companies',1);

INSERT INTO migrations(id,migration,batch) VALUES (24,'2025_09_10_161649_add_company_id_to_clients_table',1);

INSERT INTO migrations(id,migration,batch) VALUES (25,'2025_09_12_000000_add_consulta_cpe_fields_to_documents',1);

INSERT INTO migrations(id,migration,batch) VALUES (26,'2025_09_13_140000_clean_company_configurations',1);

INSERT INTO migrations(id,migration,batch) VALUES (27,'2025_12_15_104136_add_missing_columns_to_boletas_table',2);

INSERT INTO migrations(id,migration,batch) VALUES (28,'2026_11_20_200000_create_spsd_invoice_operations',3);

INSERT INTO migrations(id,migration,batch) VALUES (29,'2026_11_20_200001_reserve_spsd_beta_submission',3);

INSERT INTO migrations(id,migration,batch) VALUES (30,'2026_11_20_200002_store_invoice_prepayment_references',4);

INSERT INTO migrations(id,migration,batch) VALUES (31,'2026_11_20_200003_link_spsd_prepayments',4);

INSERT INTO migrations(id,migration,batch) VALUES (32,'2026_11_20_200004_recover_beta_prepayment_operation_code',5);

INSERT INTO migrations(id,migration,batch) VALUES (33,'2026_11_20_200005_recover_beta_settlement_3287',6);

INSERT INTO migrations(id,migration,batch) VALUES (34,'2026_11_20_200006_create_credit_notes_table',7);

INSERT INTO migrations(id,migration,batch) VALUES (35,'2026_11_20_200007_claim_credit_note_submission',8);

INSERT INTO migrations(id,migration,batch) VALUES (36,'2026_11_20_200008_settlement_correction_documents',9);

INSERT INTO migrations(id,migration,batch) VALUES (37,'2026_11_20_200009_list_spsd_documents',10);
