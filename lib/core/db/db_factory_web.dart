import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

import 'app_database.dart';

AppDatabase createAppDatabase() {
  final executor = LazyDatabase(() async {
    final result = await WasmDatabase.open(
      databaseName: 'travel_expenses',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.dart.js'),
    );

    return result.resolvedExecutor;
  });

  return AppDatabase(executor);
}
