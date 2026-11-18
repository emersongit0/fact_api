<?php

use App\Services\DocumentService;
use App\Services\FileService;
use App\Services\PdfService;
use App\Support\AmountInWords;

test('convierte importes y conserva correctamente los centavos', function ($amount, $expected) {
    expect((new AmountInWords())->convert($amount))->toBe($expected);
})->with([
    'cero' => ['0', 'CERO CON 00/100'],
    'centavos con cero inicial' => ['0.05', 'CERO CON 05/100'],
    'regresion de truncamiento float' => [0.29, 'CERO CON 29/100'],
    'un entero' => [1, 'UNO CON 00/100'],
    'dieciseis' => [16, 'DIECISÉIS CON 00/100'],
    'veintiuno' => [21, 'VEINTIUNO CON 00/100'],
    'veintidos' => [22, 'VEINTIDÓS CON 00/100'],
    'veintitres' => [23, 'VEINTITRÉS CON 00/100'],
    'veintiseis' => [26, 'VEINTISÉIS CON 00/100'],
    'treinta y uno' => [31, 'TREINTA Y UNO CON 00/100'],
    'cien exacto' => [100, 'CIEN CON 00/100'],
    'ciento uno' => [101, 'CIENTO UNO CON 00/100'],
    'factura beta' => ['118.00', 'CIENTO DIECIOCHO CON 00/100'],
    'quinientos' => ['500.99', 'QUINIENTOS CON 99/100'],
    'setecientos' => [700, 'SETECIENTOS CON 00/100'],
    'novecientos' => [900, 'NOVECIENTOS CON 00/100'],
    'mil' => [1000, 'MIL CON 00/100'],
    'mil uno' => [1001, 'MIL UNO CON 00/100'],
    'veintiun mil' => [21000, 'VEINTIÚN MIL CON 00/100'],
    'ciento un mil' => [101000, 'CIENTO UN MIL CON 00/100'],
    'un millon' => [1000000, 'UN MILLÓN CON 00/100'],
    'dos millones con resto' => ['2000118.29', 'DOS MILLONES CIENTO DIECIOCHO CON 29/100'],
    'veintiun millones' => [21000000, 'VEINTIÚN MILLONES CON 00/100'],
    'mil millones' => [1000000000, 'MIL MILLONES CON 00/100'],
    'ceros iniciales' => ['00118.20', 'CIENTO DIECIOCHO CON 20/100'],
    'redondeo sin incremento' => ['118.294', 'CIENTO DIECIOCHO CON 29/100'],
    'redondeo de medio centavo' => ['118.295', 'CIENTO DIECIOCHO CON 30/100'],
    'acarreo a siguiente entero' => ['99.995', 'CIEN CON 00/100'],
    'acarreo a millon' => ['999999.995', 'UN MILLÓN CON 00/100'],
    'maximo documentado' => ['999999999999.99', 'NOVECIENTOS NOVENTA Y NUEVE MIL NOVECIENTOS NOVENTA Y NUEVE MILLONES NOVECIENTOS NOVENTA Y NUEVE MIL NOVECIENTOS NOVENTA Y NUEVE CON 99/100'],
]);

test('agrega la moneda sin cambiar el importe', function ($currency, $name) {
    expect((new AmountInWords())->convert('118.29', $currency))
        ->toBe('CIENTO DIECIOCHO CON 29/100 ' . $name);
})->with([
    ['PEN', 'SOLES'],
    ['USD', 'DÓLARES AMERICANOS'],
    ['EUR', 'EUROS'],
]);

test('rechaza importes invalidos o fuera de rango', function ($amount) {
    expect(fn () => (new AmountInWords())->convert($amount))
        ->toThrow(InvalidArgumentException::class);
})->with([
    [-1], [''], ['1,000.00'], ['abc'], [INF], [NAN],
    ['1000000000000'], ['999999999999.995'],
]);

test('rechaza una moneda no soportada', function () {
    expect(fn () => (new AmountInWords())->convert(118, 'XYZ'))
        ->toThrow(InvalidArgumentException::class);
});

test('el generador de leyendas y el PDF coinciden tambien con centavos', function ($amount, $expected) {
    $pdf = new PdfService();
    $documents = new class(new FileService(), $pdf) extends DocumentService {
        public function legend(float $amount): string
        {
            return $this->generateLegends($amount, 'PEN')[0]['value'];
        }
    };

    expect($documents->legend($amount))->toBe($expected . ' SOLES')
        ->and($pdf->numeroALetras($amount))->toBe($expected);
})->with([
    [118.00, 'CIENTO DIECIOCHO CON 00/100'],
    [0.29, 'CERO CON 29/100'],
    [21.99, 'VEINTIUNO CON 99/100'],
    [1000000.00, 'UN MILLÓN CON 00/100'],
]);
