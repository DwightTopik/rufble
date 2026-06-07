/// Domain model for cached ЦБ РФ exchange rates.
///
/// Rates are kept as Decimal-strings (never `double`) — parse with `Decimal`
/// from the dart ecosystem at the point of calculation, per CLAUDE.md.
class ExchangeRatesData {
  const ExchangeRatesData({
    required this.usdToRub,
    required this.eurToRub,
    required this.fetchedAt,
  });

  final String usdToRub;
  final String eurToRub;
  final DateTime fetchedAt;

  /// Whether the cached rates are older than [maxAge] (default 24h) and a
  /// refresh should be attempted on next foreground.
  bool isStale({Duration maxAge = const Duration(hours: 24)}) =>
      DateTime.now().difference(fetchedAt) > maxAge;

  ExchangeRatesData copyWith({
    String? usdToRub,
    String? eurToRub,
    DateTime? fetchedAt,
  }) {
    return ExchangeRatesData(
      usdToRub: usdToRub ?? this.usdToRub,
      eurToRub: eurToRub ?? this.eurToRub,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }
}
