import 'package:drift/drift.dart';

class ReceiptsTable extends Table {
  TextColumn get id => text()();
  TextColumn get expenseId => text()();
  TextColumn get localPath => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
