import 'package:rufble/features/settings/domain/exchange_rates_data.dart';

/// Access to the single-row cached exchange rates.
abstract interface class ExchangeRatesRepository {
  /// Last cached rates, or null if never fetched.
  Future<ExchangeRatesData?> get();

  /// Reactive variant for UI that shows converted amounts.
  Stream<ExchangeRatesData?> watch();

  /// Replaces the cached rates.
  Future<void> save(ExchangeRatesData rates);
}
