import 'package:AnimeTalk/constants/types.dart';
import 'package:AnimeTalk/core/service_locator.dart';
import 'package:AnimeTalk/data/database/database.dart';
import 'package:AnimeTalk/data/repositories/character_repository.dart';
import 'package:AnimeTalk/data/repositories/message_repository.dart';
import 'package:AnimeTalk/models/llm_message.dart';
import 'package:AnimeTalk/repository/chat.dart';
import 'package:AnimeTalk/utility/functions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../widgets/chat_message_bubble.dart';
import '../widgets/typing_indicator.dart';

class ChatScreen extends StatefulWidget {
  final String characterName;
  final String characterDesc;
  final String characterImage;

  const ChatScreen({
    super.key,
    required this.characterName,
    required this.characterDesc,
    required this.characterImage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final CharacterRepository characterRepository;
  late final MessageRepository messageRepository;
  final ScrollController _scrollController = ScrollController();
  late final Chat chatService;
  final TextEditingController _messageController = TextEditingController();
  List<Message> currentMessages = []; // State to maintain messages
  bool _isCharacterTyping = false; // Added to track typing state

  @override
  void initState() {
    super.initState();
    messageRepository = getIt<MessageRepository>();
    characterRepository = getIt<CharacterRepository>();
    chatService = Chat();
    _initializeMessages();
  }

  Future<void> _initializeMessages() async {
    final characterId = await getCharacterId(widget.characterName);
    if (characterId != null) {
      final messages =
          await messageRepository.getMessagesByCharacterId(characterId);
      setState(() {
        currentMessages = messages;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<int?> getCharacterId(String name) async {
    Character? ch = await characterRepository.getCharacterByName(name);
    return ch?.id;
  }

  Future<void> saveMessage(int id, String message, Role role) async {
    await messageRepository.createMessage(
        characterId: id, role: role.name, message: message);
  }

  Future<int> getOrCreateCharacterId() async {
    try {
      int characterId;
      Character? character =
          await characterRepository.getCharacterByName(widget.characterName);

      if (character == null) {
        characterId = await characterRepository.createCharacter(
          name: widget.characterName,
          description: widget.characterDesc,
          profileUrl: widget.characterImage,
          favourite: false,
        );

        setState(() {});
        return characterId;
      }

      return character.id;
    } catch (e) {
      throw Exception('Failed to get or create character');
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      FocusScope.of(context).unfocus();
      final characterId = await getOrCreateCharacterId();

      final newMessage =
          LLMessage(role: 'user', content: _messageController.text);

      await saveMessage(
        characterId,
        _messageController.text,
        Role.user,
      );

      final llMessages = convertToLLMessages(currentMessages);
      _messageController.clear();

      // Set typing indicator to true before sending message
      setState(() {
        _isCharacterTyping = true;
      });

      try {
        await chatService.sendMessage(characterId, widget.characterName,
            widget.characterDesc, [...llMessages, newMessage]);
      } finally {
        // Set typing indicator to false when done
        setState(() {
          _isCharacterTyping = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CachedNetworkImage(
              imageUrl: widget.characterImage,
              imageBuilder: (context, imageProvider) => CircleAvatar(
                backgroundImage: imageProvider,
                radius: 20,
              ),
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.characterName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Online',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[200],
            child: Text(
              widget.characterDesc,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<int?>(
              future: getCharacterId(widget.characterName),
              builder: (context, idSnapshot) {
                if (idSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (idSnapshot.hasError) {
                  return Center(child: Text('Error: ${idSnapshot.error}'));
                }

                if (!idSnapshot.hasData) {
                  return const Center(child: Text('No messages yet'));
                }

                return StreamBuilder<List<Message>>(
                  stream: messageRepository
                      .watchMessagesByCharacterId(idSnapshot.data!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No messages yet'));
                    }

                    final messages = snapshot.data!;
                    // Update currentMessages when stream provides new data
                    currentMessages = messages;

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients) {
                        _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent + 300,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }
                    });

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _isCharacterTyping ? messages.length + 1 : messages.length,
                      itemBuilder: (context, index) {
                        if (_isCharacterTyping && index == messages.length) {
                          return TypingIndicator(
                            characterImage: widget.characterImage,
                          );
                        }
                        final message = messages[index];
                        return ChatMessageBubble(
                          message: message,
                          characterImage: widget.characterImage,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.grid_3x3, color: Colors.grey),
                  onPressed: () {},
                ),
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(
                      maxHeight: 150,
                    ),
                    child: TextField(
                      controller: _messageController,
                      maxLength: 120,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      maxLines: null,
                      minLines: 1,
                      textInputAction: TextInputAction.newline,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                        counterText: "",
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_forward,
                        color: Colors.white, size: 20),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
