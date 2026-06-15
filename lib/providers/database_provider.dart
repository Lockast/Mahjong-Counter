import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database/app_database.dart';

// Overridden in main() with the already-initialized AppDatabase instance.
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('databaseProvider must be overridden in main()');
});
