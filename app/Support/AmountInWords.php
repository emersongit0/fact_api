<?php

namespace App\Support;

use InvalidArgumentException;

/** Conversión compartida de importes para la leyenda XML y el PDF. */
final class AmountInWords
{
    private const UNITS = [
        'CERO', 'UNO', 'DOS', 'TRES', 'CUATRO', 'CINCO', 'SEIS', 'SIETE',
        'OCHO', 'NUEVE', 'DIEZ', 'ONCE', 'DOCE', 'TRECE', 'CATORCE',
        'QUINCE', 'DIECISÉIS', 'DIECISIETE', 'DIECIOCHO', 'DIECINUEVE',
        'VEINTE', 'VEINTIUNO', 'VEINTIDÓS', 'VEINTITRÉS', 'VEINTICUATRO',
        'VEINTICINCO', 'VEINTISÉIS', 'VEINTISIETE', 'VEINTIOCHO', 'VEINTINUEVE',
    ];

    private const TENS = [
        3 => 'TREINTA', 4 => 'CUARENTA', 5 => 'CINCUENTA', 6 => 'SESENTA',
        7 => 'SETENTA', 8 => 'OCHENTA', 9 => 'NOVENTA',
    ];

    private const HUNDREDS = [
        1 => 'CIENTO', 2 => 'DOSCIENTOS', 3 => 'TRESCIENTOS', 4 => 'CUATROCIENTOS',
        5 => 'QUINIENTOS', 6 => 'SEISCIENTOS', 7 => 'SETECIENTOS',
        8 => 'OCHOCIENTOS', 9 => 'NOVECIENTOS',
    ];

    public function convert(int|float|string $amount, ?string $currency = null): string
    {
        [$integer, $cents] = $this->splitAmount($amount);
        $words = $this->integerWords($integer) . ' CON ' . sprintf('%02d', $cents) . '/100';

        if ($currency !== null) {
            $words .= ' ' . match ($currency) {
                'PEN' => 'SOLES',
                'USD' => 'DÓLARES AMERICANOS',
                'EUR' => 'EUROS',
                default => throw new InvalidArgumentException('Moneda no admitida para el importe en letras.'),
            };
        }

        return $words;
    }

    /** Redondea a centavos sin truncar por errores de representación de float. */
    private function splitAmount(int|float|string $amount): array
    {
        if (is_float($amount) && !is_finite($amount)) {
            throw new InvalidArgumentException('El importe debe ser finito y no negativo.');
        }

        $decimal = is_float($amount) ? sprintf('%.10F', $amount) : trim((string) $amount);
        if (!preg_match('/^(\d+)(?:\.(\d+))?$/D', $decimal, $matches)) {
            throw new InvalidArgumentException('El importe debe ser un número decimal no negativo.');
        }

        $whole = ltrim($matches[1], '0') ?: '0';
        if (strlen($whole) > 12) {
            throw new InvalidArgumentException('El importe supera el máximo admitido.');
        }

        $integer = (int) $whole;
        $fraction = str_pad($matches[2] ?? '', 3, '0');
        $cents = (int) substr($fraction, 0, 2);
        if ((int) $fraction[2] >= 5) {
            $cents++;
        }
        if ($cents === 100) {
            $integer++;
            $cents = 0;
        }
        if ($integer > 999999999999) {
            throw new InvalidArgumentException('El importe supera el máximo admitido.');
        }

        return [$integer, $cents];
    }

    private function integerWords(int $number): string
    {
        if ($number < 30) {
            return self::UNITS[$number];
        }
        if ($number < 100) {
            $remainder = $number % 10;
            return self::TENS[intdiv($number, 10)]
                . ($remainder ? ' Y ' . self::UNITS[$remainder] : '');
        }
        if ($number === 100) {
            return 'CIEN';
        }
        if ($number < 1000) {
            $remainder = $number % 100;
            return self::HUNDREDS[intdiv($number, 100)]
                . ($remainder ? ' ' . $this->integerWords($remainder) : '');
        }
        if ($number < 1000000) {
            $thousands = intdiv($number, 1000);
            $remainder = $number % 1000;
            $words = $thousands === 1 ? 'MIL' : $this->masculine($this->integerWords($thousands)) . ' MIL';
            return $words . ($remainder ? ' ' . $this->integerWords($remainder) : '');
        }

        $millions = intdiv($number, 1000000);
        $remainder = $number % 1000000;
        $words = $millions === 1 ? 'UN MILLÓN' : $this->masculine($this->integerWords($millions)) . ' MILLONES';
        return $words . ($remainder ? ' ' . $this->integerWords($remainder) : '');
    }

    private function masculine(string $words): string
    {
        $words = preg_replace('/VEINTIUNO$/u', 'VEINTIÚN', $words);
        return preg_replace('/UNO$/u', 'UN', $words);
    }
}
