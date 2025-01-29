import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/character_table.dart';
import '../models/message_table.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Characters, Messages])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(
        p.join(dbFolder.path, 'anime_talk.sqlite')); // Changed database name
    return NativeDatabase(file);
  });
}
