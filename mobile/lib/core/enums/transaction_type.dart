/// Kind of a money movement on a goal. Persisted as `.name` TEXT in Drift.
///
/// Sign convention for `saved` recalculation:
/// - [deposit], [transferIn] increase a goal's saved amount.
/// - [withdrawal], [transferOut], [writeOff] decrease it.
enum TransactionType {
  deposit,
  withdrawal,
  transferIn,
  transferOut,
  writeOff;

  /// Parses a persisted `.name` value. Throws [ArgumentError] on unknown input
  /// — a bad transaction type would silently corrupt `saved`, so fail loud.
  static TransactionType fromName(String name) =>
      TransactionType.values.firstWhere(
        (t) => t.name == name,
        orElse: () =>
            throw ArgumentError.value(name, 'name', 'Unknown TransactionType'),
      );

  /// Whether this type adds to a goal's saved amount.
  bool get isCredit =>
      this == TransactionType.deposit || this == TransactionType.transferIn;
}
