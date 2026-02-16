import 'dart:developer' as developer;

import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

import 'app_database.dart';

AppDatabase createAppDatabase() {
  final executor = LazyDatabase(() async {
    final probe = await WasmDatabase.probe(
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.dart.js'),
      databaseName: 'travel_expenses',
    );

    final chosen = _pickPersistentStorage(probe.availableStorages);
    final connection = await probe.open(
      chosen,
      'travel_expenses',
      enableMigrations: true,
    );

    developer.log(
      'Drift web storage: ${chosen.storageApi?.name ?? 'inMemory'} (${chosen.name})',
      name: 'db_factory_web',
    );
    if (probe.missingFeatures.isNotEmpty) {
      developer.log(
        'Drift web missing features: ${probe.missingFeatures}',
        name: 'db_factory_web',
      );
    }

    return connection.executor;
  });

  return AppDatabase(executor);
}

WasmStorageImplementation _pickPersistentStorage(
  List<WasmStorageImplementation> available,
) {
  for (final candidate in available) {
    if (candidate.storageApi == WebStorageApi.opfs) {
      return candidate;
    }
  }

  for (final candidate in available) {
    if (candidate.storageApi == WebStorageApi.indexedDb) {
      return candidate;
    }
  }

  return available.isNotEmpty ? available.first : WasmStorageImplementation.inMemory;
}
