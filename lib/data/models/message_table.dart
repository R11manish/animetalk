import 'package:AnimeTalk/data/models/character_table.dart';
import 'package:drift/drift.dart';

class Messages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get characterId =>
      integer().named('character_table').references(Characters, #id)();
  TextColumn get role => text()();
  TextColumn get message => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get files =>
      text().nullable()();
}