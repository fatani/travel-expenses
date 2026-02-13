import 'package:drift/drift.dart';

class ReceiptsTable extends Table {
  TextColumn get id => text()();
  TextColumn get expenseId => text()();
  TextColumn get localPath => text().nullable()(); // Nullable for Web
  BlobColumn get data => blob().nullable()(); // Store image bytes for Web
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
