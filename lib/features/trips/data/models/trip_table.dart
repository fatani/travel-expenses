import 'package:drift/drift.dart';

class TripsTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get defaultCurrency => text()();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
