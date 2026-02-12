import 'package:drift/drift.dart';

class ExpensesTable extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text()();
  RealColumn get amount => real()();
  TextColumn get currency => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get category => text()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
