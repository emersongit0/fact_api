<?php

use App\Models\Company;

test('resuelve el endpoint de factura segun ambiente y respeta configuraciones existentes', function ($production, $configured, $expected) {
    $company = new class extends Company {
        public string $configuredEndpoint = '';

        public function getSunatEndpoint(string $serviceType, string $type = 'endpoint'): string
        {
            return $this->configuredEndpoint;
        }
    };
    $company->modo_produccion = $production;
    $company->endpoint_beta = 'https://e-beta.sunat.gob.pe/ol-ti-itcpfegem-beta/billService';
    $company->endpoint_produccion = 'https://e-factura.sunat.gob.pe/ol-ti-itcpfegem/billService';
    $company->configuredEndpoint = $configured;

    expect($company->getInvoiceEndpoint())->toBe($expected);
})->with([
    'beta sin configuracion adicional' => [false, '', 'https://e-beta.sunat.gob.pe/ol-ti-itcpfegem-beta/billService'],
    'produccion sin configuracion adicional' => [true, '', 'https://e-factura.sunat.gob.pe/ol-ti-itcpfegem/billService'],
    'beta con configuracion explicita' => [false, 'https://config.example.test/beta', 'https://config.example.test/beta'],
    'produccion con configuracion explicita' => [true, 'https://config.example.test/prod', 'https://config.example.test/prod'],
]);
