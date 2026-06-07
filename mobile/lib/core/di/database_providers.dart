import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rufble/core/database/app_database.dart';

/// Single app-wide Drift database instance. Disposed with the [ProviderScope].
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
