import 'package:AnimeTalk/constants/types.dart';
import 'package:AnimeTalk/core/service_locator.dart';
import 'package:AnimeTalk/data/database/database.dart';
import 'package:AnimeTalk/data/repositories/character_repository.dart';
import 'package:AnimeTalk/data/repositories/message_repository.dart';
import 'package:AnimeTalk/models/llm_message.dart';
import 'package:AnimeTalk/repository/chat.dart';
import 'package:AnimeTalk/utility/functions.dart';
import 'package:flutter/material.dart';

class ChatViewModel extends ChangeNotifier {
  final CharacterRepository _characterRepository = getIt<CharacterRepository>();
  final MessageRepository _messageRepository = getIt<MessageRepository>();
  final Chat _chatService = Chat();

  List<Message> messages = [];
  // Map to track typing status per character ID
  final Map<int, bool> _characterTypingStatus = {};

  String characterName;
  String characterDesc;
  String characterImage;
  int? characterId;

  ChatViewModel({
    required this.characterName,
    required this.characterDesc,
    required this.characterImage,
  }) {
    _initialize();
  }

  // Getter for the current character's typing status
  bool get isCharacterTyping {
    if (characterId == null) return false;
    return _characterTypingStatus[characterId!] ?? false;
  }

  // Setter for the current character's typing status
  set isCharacterTyping(bool value) {
    if (characterId != null) {
      _characterTypingStatus[characterId!] = value;
      notifyListeners();
    }
  }

  Future<void> _initialize() async {
    characterId = await getCharacterId(characterName);
    if (characterId != null) {
      await _loadMessages();
    }
  }

  Future<void> _loadMessages() async {
    if (characterId != null) {
      final loadedMessages =
          await _messageRepository.getMessagesByCharacterId(characterId!);
      messages = loadedMessages;
      notifyListeners();
    }
  }

  Future<int?> getCharacterId(String name) async {
    Character? ch = await _characterRepository.getCharacterByName(name);
    return ch?.id;
  }

  Stream<List<Message>> watchMessages() {
    if (characterId != null) {
      return _messageRepository.watchMessagesByCharacterId(characterId!);
    }
    return Stream.value([]);
  }

  Future<int> getOrCreateCharacterId() async {
    try {
      Character? character =
          await _characterRepository.getCharacterByName(characterName);

      if (character == null) {
        characterId = await _characterRepository.createCharacter(
          name: characterName,
          description: characterDesc,
          profileUrl: characterImage,
          favourite: false,
        );
        notifyListeners();
        return characterId!;
      }

      characterId = character.id;
      return character.id;
    } catch (e) {
      throw Exception('Failed to get or create character');
    }
  }

  Future<void> saveMessage(int id, String message, Role role) async {
    await _messageRepository.createMessage(
      characterId: id,
      role: role.name,
      message: message,
    );
  }

  Future<void> sendMessage(String messageText) async {
    if (messageText.isNotEmpty) {
      final id = await getOrCreateCharacterId();

      // Save user message
      await saveMessage(
        id,
        messageText,
        Role.user,
      );

      // Create LLMessage from user input
      final newMessage = LLMessage(role: 'user', content: messageText);
      final llMessages = convertToLLMessages(messages);

      // Set typing indicator for this specific character
      isCharacterTyping = true;

      try {
        // Send message to API
        await _chatService.sendMessage(
            id, characterName, characterDesc, [...llMessages, newMessage]);
      } catch (e) {
        // Handle error
        print('Error sending message: $e');
      } finally {
        // Remove typing indicator for this specific character
        isCharacterTyping = false;
      }
    }
  }

  Future<void> deleteMessage(int messageId) async {
    try {
      await _messageRepository.deleteMessage(messageId);
    } catch (e) {
      print('Error deleting message: $e');
      throw Exception('Failed to delete message');
    }
  }
}
