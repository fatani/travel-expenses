import 'dart:io' show File;

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'app_database.dart';

AppDatabase createAppDatabase() {
  final executor = LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(path.join(dir.path, 'travel_expenses.db'));
    return NativeDatabase(file);
  });

  return AppDatabase(executor);
}
