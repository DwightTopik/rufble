import 'package:flutter_test/flutter_test.dart';
import 'package:rufble/core/enums/currency.dart';
import 'package:rufble/core/utils/money.dart';
import 'package:rufble/features/settings/domain/exchange_rates_data.dart';

// Use the real separators the formatter emits so test literals never depend on
// which whitespace character happens to be in this source file.
const g = groupSeparator; // U+202F narrow no-break space (thousands)
const s = symbolSeparator; // U+00A0 no-break space (symbol ↔ amount)

void main() {
  group('formatAmount', () {
    test('formats whole RUB with thousands grouping and symbol', () {
      expect(formatAmount(1500000, Currency.rub), '₽${s}15${g}000');
    });

    test('shows fractional minor units only when non-zero', () {
      expect(formatAmount(19999, Currency.usd), '\$${s}199.99');
      expect(formatAmount(20000, Currency.usd), '\$${s}200');
    });

    test('uses typographic minus for negatives', () {
      expect(formatAmount(-5000, Currency.eur), '−€${s}50');
    });

    test('groups large numbers correctly', () {
      expect(
        formatAmount(123456789, Currency.rub),
        '₽${s}1${g}234${g}567.89',
      );
    });
  });

  group('parseToMinor', () {
    test('parses whole numbers to minor units', () {
      expect(parseToMinor('15000', Currency.rub), 1500000);
    });

    test('parses a 2-digit fraction', () {
      expect(parseToMinor('199.99', Currency.usd), 19999);
    });

    test('treats comma as decimal separator', () {
      expect(parseToMinor('50,5', Currency.eur), 5050);
    });

    test('ignores grouping spaces', () {
      expect(parseToMinor('1 234', Currency.rub), 123400);
    });

    test('rejects more than two fractional digits', () {
      expect(parseToMinor('1.234', Currency.usd), isNull);
    });

    test('rejects non-numeric input', () {
      expect(parseToMinor('abc', Currency.rub), isNull);
      expect(parseToMinor('', Currency.rub), isNull);
    });

    test('round-trips with formatAmount for whole amounts', () {
      final minor = parseToMinor('9 999', Currency.rub);
      expect(minor, 999900);
      expect(formatAmount(minor!, Currency.rub), '₽${s}9${g}999');
    });
  });

  group('formatSecondary', () {
    final rates = ExchangeRatesData(
      usdToRub: '90.00',
      eurToRub: '100.00',
      fetchedAt: DateTime(2026, 6, 8),
    );

    test('RUB goal converts to USD (divide by rate)', () {
      // 9000 ₽ / 90 = 100 $ → 10000 cents.
      expect(formatSecondary(900000, Currency.rub, rates), '\$${s}100');
    });

    test('USD goal converts to RUB (multiply by rate)', () {
      // 100 $ * 90 = 9000 ₽ → 900000 kopecks.
      expect(formatSecondary(10000, Currency.usd, rates), '₽${s}9${g}000');
    });

    test('EUR goal converts to RUB (multiply by rate)', () {
      // 10 € * 100 = 1000 ₽.
      expect(formatSecondary(1000, Currency.eur, rates), '₽${s}1${g}000');
    });

    test('returns null for an unparseable rate', () {
      final bad = ExchangeRatesData(
        usdToRub: 'n/a',
        eurToRub: '100',
        fetchedAt: DateTime(2026, 6, 8),
      );
      expect(formatSecondary(900000, Currency.rub, bad), isNull);
    });
  });
}
