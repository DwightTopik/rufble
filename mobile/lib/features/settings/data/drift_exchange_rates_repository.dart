import 'package:drift/drift.dart';
import 'package:rufble/core/database/app_database.dart';
import 'package:rufble/features/settings/domain/exchange_rates_data.dart';
import 'package:rufble/features/settings/domain/exchange_rates_repository.dart';

/// Drift-backed [ExchangeRatesRepository] over the single rates row (id 0).
class DriftExchangeRatesRepository implements ExchangeRatesRepository {
  DriftExchangeRatesRepository(this._db);

  static const _rowId = 0;
  final AppDatabase _db;

  @override
  Future<ExchangeRatesData?> get() async {
    final row = await (_db.select(_db.exchangeRates)
          ..where((r) => r.id.equals(_rowId)))
        .getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Stream<ExchangeRatesData?> watch() {
    final query = _db.select(_db.exchangeRates)
      ..where((r) => r.id.equals(_rowId));
    return query
        .watchSingleOrNull()
        .map((row) => row == null ? null : _toDomain(row));
  }

  @override
  Future<void> save(ExchangeRatesData rates) =>
      _db.into(_db.exchangeRates).insertOnConflictUpdate(
            ExchangeRatesCompanion(
              id: const Value(_rowId),
              usdToRub: Value(rates.usdToRub),
              eurToRub: Value(rates.eurToRub),
              fetchedAt: Value(rates.fetchedAt),
            ),
          );

  ExchangeRatesData _toDomain(ExchangeRateRow row) => ExchangeRatesData(
        usdToRub: row.usdToRub,
        eurToRub: row.eurToRub,
        fetchedAt: row.fetchedAt,
      );
}
