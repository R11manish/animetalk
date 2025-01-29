import 'package:drift/drift.dart';

class Characters extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text()();
  TextColumn get profileUrl => text()();
  BoolColumn get favourite => boolean()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
