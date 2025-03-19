import 'package:animetalk/data/database/database.dart';
import 'package:drift/drift.dart';

class MessageRepository {
  final AppDatabase _db;

  MessageRepository(this._db);

  Future<List<Message>> getAllMessages() {
    return (_db.select(_db.messages)).get();
  }

  Future<Message> getMessageById(int id) {
    return (_db.select(_db.messages)..where((message) => message.id.equals(id)))
        .getSingle();
  }

  Future<List<Message>> getMessagesByCharacterId(int characterId) {
    return (_db.select(_db.messages)
          ..where((message) => message.characterId.equals(characterId)))
        .get();
  }

  Future<int> createMessage({
    required int characterId,
    required String role,
    required String message,
    String? files,
  }) {
    return _db.into(_db.messages).insert(
          MessagesCompanion.insert(
            characterId: characterId,
            role: role,
            message: message,
            files: Value(files),
          ),
        );
  }

  Stream<List<Message>> watchMessagesByCharacterId(int characterId) {
    return (_db.select(_db.messages)
          ..where((message) => message.characterId.equals(characterId))
          ..orderBy([
            (message) => OrderingTerm(
                  expression: message.createdAt,
                  mode: OrderingMode.asc,
                ),
          ]))
        .watch();
  }

  Future<bool> updateMessage({
    required int id,
    required int characterId,
    required String role,
    required String message,
    String? files,
  }) {
    return _db.update(_db.messages).replace(
          MessagesCompanion(
            id: Value(id),
            characterId: Value(characterId),
            role: Value(role),
            message: Value(message),
            files: Value(files),
          ),
        );
  }

  Future<Message?> getLatestMessage(int characterId) async {
    try {
      final query = (_db.select(_db.messages)
        ..where((t) => t.characterId.equals(characterId))
        ..orderBy([
          (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
        ])
        ..limit(1));

      final messages = await query.get();
      return messages.isEmpty ? null : messages.first;
    } catch (e) {
      print('Error getting latest message: $e');
      return null;
    }
  }

  Future<int> deleteMessage(int id) {
    return (_db.delete(_db.messages)..where((message) => message.id.equals(id)))
        .go();
  }

  // Additional methods
  Future<List<Message>> getMessagesByRole(String role) {
    return (_db.select(_db.messages)
          ..where((message) => message.role.equals(role)))
        .get();
  }

  Future<int> deleteMessagesByCharacterId(int characterId) {
    return (_db.delete(_db.messages)
          ..where((message) => message.characterId.equals(characterId)))
        .go();
  }
}
