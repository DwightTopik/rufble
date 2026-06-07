/// Supported goal currencies. Persisted as `.name` TEXT in Drift.
///
/// All amounts are stored as `int` minor units of the goal's currency
/// (kopecks / cents / euro cents). See CLAUDE.md "Money Handling".
enum Currency {
  rub,
  usd,
  eur;

  /// Parses a persisted `.name` value, falling back to [rub] (app default).
  static Currency fromName(String name) => Currency.values.firstWhere(
        (c) => c.name == name,
        orElse: () => Currency.rub,
      );

  /// Display symbol for the currency.
  String get symbol => switch (this) {
        Currency.rub => '₽',
        Currency.usd => r'$',
        Currency.eur => '€',
      };
}
