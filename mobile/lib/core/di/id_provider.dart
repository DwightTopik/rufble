import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

/// App-wide id generator for offline-created rows (UUID v4). Provided so tests
/// can override it for deterministic ids.
final idGeneratorProvider = Provider<String Function()>((ref) {
  const uuid = Uuid();
  return uuid.v4;
});
