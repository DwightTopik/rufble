import 'package:rufble/core/enums/currency.dart';
import 'package:rufble/features/settings/domain/exchange_rates_data.dart';

/// Money formatting and parsing helpers. **Int-only** — all amounts are minor
/// units (kopecks / cents / euro cents). No `double`/`num` ever appears in the
/// pipeline; conversions go through integer arithmetic. See CLAUDE.md
/// "Money Handling".

/// Narrow no-break space (U+202F) used as the thousands grouping separator.
const String groupSeparator = ' ';

/// No-break space (U+00A0) between the currency symbol and the amount, keeping
/// them together on one line.
const String symbolSeparator = ' ';

/// Groups the integer part with narrow-space thousands separators:
/// `15000` → `15 000`.
String _group(int major) {
  final digits = major.toString();
  final buf = StringBuffer();
  final firstGroup = digits.length % 3 == 0 ? 3 : digits.length % 3;
  buf.write(digits.substring(0, firstGroup));
  for (var i = firstGroup; i < digits.length; i += 3) {
    buf
      ..write(groupSeparator)
      ..write(digits.substring(i, i + 3));
  }
  return buf.toString();
}

/// Formats [minor] (minor units of [currency]) as a display string with the
/// currency symbol, e.g. `₽ 15 000`, `$ 199.99`, `−€ 50`.
///
/// Fractional minor units are shown only when non-zero. A leading minus uses
/// the typographic minus sign (U+2212).
String formatAmount(int minor, Currency currency) {
  final negative = minor < 0;
  final abs = minor.abs();
  final major = abs ~/ 100;
  final frac = abs % 100;
  final sign = negative ? '−' : '';
  final body = frac == 0
      ? _group(major)
      : '${_group(major)}.${frac.toString().padLeft(2, '0')}';
  return '$sign${currency.symbol}$symbolSeparator$body';
}

/// Formats the secondary (converted) amount shown under the primary, smaller
/// and dimmed. Conversion rule (CLAUDE.md "Exchange Rates"):
/// - RUB goal → USD equivalent
/// - USD goal → RUB equivalent
/// - EUR goal → RUB equivalent
///
/// All math is integer: rates are Decimal-strings, scaled to integer
/// micro-rates (×10000) so we never touch `double`. Returns `null` when the
/// rate is unparseable (caller hides the secondary line).
String? formatSecondary(
  int minor,
  Currency currency,
  ExchangeRatesData rates,
) {
  final (target, rateStr) = switch (currency) {
    Currency.rub => (Currency.usd, rates.usdToRub),
    Currency.usd => (Currency.rub, rates.usdToRub),
    Currency.eur => (Currency.rub, rates.eurToRub),
  };

  // Scale the Decimal-string rate to an integer with 4 fractional digits.
  final scaledRate = _rateToScaled(rateStr);
  if (scaledRate == null || scaledRate == 0) return null;

  // converted_minor = minor * rate (RUB per unit) for X→RUB,
  // or minor / rate for RUB→USD. Kept in integer space throughout.
  final int converted;
  if (currency == Currency.rub) {
    // RUB → USD: divide by rate. minor(kopecks) * 10000 / scaledRate.
    converted = (minor * _rateScale) ~/ scaledRate;
  } else {
    // USD/EUR → RUB: multiply by rate.
    converted = (minor * scaledRate) ~/ _rateScale;
  }
  return formatAmount(converted, target);
}

const int _rateScale = 10000;

/// Parses a Decimal-string rate (e.g. `"92.5017"`) into an integer scaled by
/// [_rateScale] (4 fractional digits), or null on malformed input. No `double`.
int? _rateToScaled(String rate) {
  final trimmed = rate.trim();
  if (trimmed.isEmpty) return null;
  final parts = trimmed.split('.');
  if (parts.length > 2) return null;
  final whole = int.tryParse(parts[0]);
  if (whole == null) return null;
  var fracDigits = parts.length == 2 ? parts[1] : '';
  if (fracDigits.length > 4) {
    fracDigits = fracDigits.substring(0, 4);
  } else {
    fracDigits = fracDigits.padRight(4, '0');
  }
  final frac = int.tryParse(fracDigits.isEmpty ? '0' : fracDigits);
  if (frac == null) return null;
  return whole * _rateScale + frac;
}

/// Parses user text [input] into minor units of [currency]. Accepts an optional
/// fractional part with up to 2 digits separated by `.` or `,`. Group
/// separators (regular, narrow, and no-break spaces) are ignored. Returns null
/// on invalid input. **No `double` intermediate** — major and fractional parts
/// are parsed as separate ints.
int? parseToMinor(String input, Currency currency) {
  var s = input.trim();
  // Strip every kind of space we might emit or a user might type.
  s = s
      .replaceAll(' ', '')
      .replaceAll(' ', '')
      .replaceAll(' ', '')
      .replaceAll(currency.symbol, '');
  if (s.isEmpty) return null;

  final negative = s.startsWith('-') || s.startsWith('−');
  if (negative) s = s.substring(1);

  s = s.replaceAll(',', '.');
  final parts = s.split('.');
  if (parts.length > 2) return null;

  final majorStr = parts[0].isEmpty ? '0' : parts[0];
  final major = int.tryParse(majorStr);
  if (major == null) return null;

  var minorPart = 0;
  if (parts.length == 2) {
    var fracStr = parts[1];
    if (fracStr.length > 2) return null; // more precision than minor units
    fracStr = fracStr.padRight(2, '0');
    final parsed = int.tryParse(fracStr);
    if (parsed == null) return null;
    minorPart = parsed;
  }

  final total = major * 100 + minorPart;
  return negative ? -total : total;
}
