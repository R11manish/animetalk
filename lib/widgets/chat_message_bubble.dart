import 'package:animetalk/data/database/database.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';

class ChatMessageBubble extends StatelessWidget {
  final Message message;
  final String characterImage;
  final Function(int messageId)? onDelete;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.characterImage,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.75;
    final formattedTime = DateFormat('HH:mm').format(message.createdAt);
    final isUserMessage = message.role == 'user';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUserMessage) ...[
            CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(characterImage),
              radius: 16,
            ),
            const SizedBox(width: 8),
          ],
          GestureDetector(
            onLongPress: () {
              if (onDelete != null) {
                _showDeleteDialog(context);
              }
            },
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isUserMessage ? Colors.black : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MarkdownBody(
                      data: message.message,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                          color: isUserMessage ? Colors.white : Colors.black,
                          fontSize: 16,
                        ),
                        code: TextStyle(
                          backgroundColor: isUserMessage
                              ? Colors.grey[700]
                              : Colors.grey[300],
                          color: isUserMessage ? Colors.white : Colors.black,
                          fontSize: 14,
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: isUserMessage
                              ? Colors.grey[700]
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        blockquoteDecoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: isUserMessage
                                  ? Colors.grey[400]!
                                  : Colors.grey[600]!,
                              width: 4,
                            ),
                          ),
                        ),
                        blockquote: TextStyle(
                          color: isUserMessage
                              ? Colors.grey[300]
                              : Colors.grey[700],
                          fontSize: 16,
                        ),
                        a: TextStyle(
                          color: isUserMessage
                              ? Colors.lightBlue[200]
                              : Colors.blue,
                        ),
                        strong: TextStyle(
                          color: isUserMessage ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        em: TextStyle(
                          color: isUserMessage ? Colors.white : Colors.black,
                          fontStyle: FontStyle.italic,
                        ),
                        h1: TextStyle(
                          color: isUserMessage ? Colors.white : Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        h2: TextStyle(
                          color: isUserMessage ? Colors.white : Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        h3: TextStyle(
                          color: isUserMessage ? Colors.white : Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedTime,
                      style: TextStyle(
                        color:
                            isUserMessage ? Colors.white70 : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    if (isUserMessage && onDelete != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.touch_app,
                            size: 12,
                            color: Colors.white54,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Hold to delete',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (isUserMessage) const SizedBox(width: 24),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onDelete?.call(message.id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
