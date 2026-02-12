import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';
import 'app_repository.dart';
import 'db_factory.dart';
import 'drift_repository.dart';

/// AppDatabase provider - STABLE (not autoDispose)
/// 
/// Creates and maintains a single database instance for the entire app lifetime.
/// It is NOT disposed until the app closes.
/// 
/// Why: Ensuring DB stability avoids repeated initialization and lost connections
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = createDatabase();
  ref.onDispose(database.close);
  return database;
});

/// AppRepository provider using platform-appropriate implementation
/// 
/// STABLE (not autoDispose) for consistency across navigation
/// 
/// Why stable provider: Keeps repository alive, prevents repeated DB opens
final repositoryProvider = Provider<AppRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return DriftRepository(database);
});

