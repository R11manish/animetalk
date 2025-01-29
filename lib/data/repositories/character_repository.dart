import 'package:drift/drift.dart';
import '../database/database.dart';

class CharacterRepository {
  final AppDatabase _db;

  CharacterRepository(this._db);

  Future<List<Character>> getAllCharacters() {
    return (_db.select(_db.characters)).get();
  }

  Future<Character> getCharacterById(int id) {
    return (_db.select(_db.characters)..where((tbl) => tbl.id.equals(id)))
        .getSingle();
  }

  Future<Character?> getCharacterByName(String characterName) {
    return (_db.select(_db.characters)
          ..where((tbl) => tbl.name.equals(characterName)))
        .getSingleOrNull();
  }

  Stream<List<Character>> watchFavoriteCharacters() {
    return (_db.select(_db.characters)
          ..where((tbl) => tbl.favourite.equals(true)))
        .watch();
  }

  Stream<Character?> watchCharacterByName(String name) {
    return (_db.select(_db.characters)..where((tbl) => tbl.name.equals(name)))
        .watchSingleOrNull();
  }

  Stream<List<Character>> watchAllCharacters() {
    return (_db.select(_db.characters)
          ..orderBy([
            (t) => OrderingTerm(
                  expression: t.createdAt,
                  mode: OrderingMode.desc,
                )
          ]))
        .watch();
  }

  Future<int> createCharacter({
    required String name,
    required String description,
    required String profileUrl,
    required bool favourite,
  }) {
    return _db.into(_db.characters).insert(
          CharactersCompanion.insert(
            name: name,
            description: description,
            profileUrl: profileUrl,
            favourite: favourite,
          ),
        );
  }

  Future<bool> updateCharacter({
    required int id,
    required String name,
    required String description,
    required String profileUrl,
    required bool favourite,
  }) {
    return _db.update(_db.characters).replace(
          CharactersCompanion(
            id: Value(id),
            name: Value(name),
            description: Value(description),
            profileUrl: Value(profileUrl),
            favourite: Value(favourite),
          ),
        );
  }

  Future<int> deleteCharacter(int id) {
    return (_db.delete(_db.characters)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<List<Character>> getFavoriteCharacters() {
    return (_db.select(_db.characters)
          ..where((tbl) => tbl.favourite.equals(true)))
        .get();
  }
}
