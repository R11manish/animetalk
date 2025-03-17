import 'package:AnimeTalk/core/service_locator.dart';
import 'package:AnimeTalk/data/repositories/character_repository.dart';
import 'package:AnimeTalk/data/repositories/message_repository.dart';
import 'package:AnimeTalk/data/database/database.dart';
import 'package:AnimeTalk/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreen();
}

class _MessagesScreen extends State<MessagesScreen> {
  late final CharacterRepository characterRepository;
  late final MessageRepository messageRepository;
  String searchQuery = '';
  List<Character> allCharacters = [];
  List<Character> filteredCharacters = [];

  @override
  void initState() {
    super.initState();
    characterRepository = getIt<CharacterRepository>();
    messageRepository = getIt<MessageRepository>();
    _loadCharacters();
  }

  Future<void> _loadCharacters() async {
    final characters = await characterRepository.getAllCharacters();
    setState(() {
      allCharacters = characters;
      filteredCharacters = characters;
    });
  }

  void _filterCharacters(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredCharacters = allCharacters;
      } else {
        filteredCharacters = allCharacters
            .where((character) =>
                character.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Messages'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search characters...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: (value) {
                _filterCharacters(value);
              },
            ),
          ),
          Expanded(
            child: allCharacters.isEmpty
                ? const Center(child: Text('No message found'))
                : filteredCharacters.isEmpty
                    ? Center(
                        child:
                            Text('No characters found matching "$searchQuery"'))
                    : ListView.separated(
                        itemCount: filteredCharacters.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final character = filteredCharacters[index];

                          return FutureBuilder<Message?>(
                            future: messageRepository
                                .getLatestMessage(character.id),
                            builder: (context, messageSnapshot) {
                              final latestMessage = messageSnapshot.data;

                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 25,
                                  backgroundImage:
                                      NetworkImage(character.profileUrl),
                                ),
                                title: Text(
                                  character.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  latestMessage?.message ?? 'No messages yet',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Text(
                                  latestMessage != null
                                      ? getTimeAgo(latestMessage.createdAt)
                                      : '',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                        characterName: character.name,
                                        characterDesc: character.description,
                                        characterImage: character.profileUrl,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
