import 'package:AnimeTalk/constants/types.dart';
import 'package:AnimeTalk/data/database/database.dart';
import 'package:AnimeTalk/viewmodels/chat_viewmodel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  late ChatViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ChatViewModel(
      characterName: widget.characterName,
      characterDesc: widget.characterDesc,
      characterImage: widget.characterImage,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildCharacterDescription(),
            _buildMessageList(),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
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
    );
  }

  Widget _buildCharacterDescription() {
    return Column(
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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          color: Colors.grey[100],
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 14, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text(
                'Tip: Long press on your messages to delete them',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageList() {
    return Expanded(
      child: Consumer<ChatViewModel>(
        builder: (context, viewModel, child) {
          return FutureBuilder<int?>(
            future: viewModel.getCharacterId(widget.characterName),
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

              // Use the local messages list instead of stream
              final messages = viewModel.messages;

              if (messages.isEmpty) {
                return const Center(child: Text('No messages yet'));
              }

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
                itemCount: viewModel.isCharacterTyping
                    ? messages.length + 1
                    : messages.length,
                itemBuilder: (context, index) {
                  if (viewModel.isCharacterTyping && index == messages.length) {
                    return TypingIndicator(
                      characterImage: widget.characterImage,
                    );
                  }
                  final message = messages[index];
                  return ChatMessageBubble(
                    message: message,
                    characterImage: widget.characterImage,
                    onDelete: (messageId) async {
                      // Show loading indicator
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Row(
                            children: [
                              SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 16),
                              Text('Deleting message...'),
                            ],
                          ),
                          duration: Duration(seconds: 1),
                        ),
                      );

                      try {
                        await viewModel.deleteMessage(messageId);
                        // Reload messages after deletion
                        await viewModel.loadMessages();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Message deleted'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to delete message: $e'),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInputArea() {
    return Consumer<ChatViewModel>(
      builder: (context, viewModel, child) {
        return Container(
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
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      FocusScope.of(context).unfocus();
                      viewModel.sendMessage(_messageController.text);
                      _messageController.clear();
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
