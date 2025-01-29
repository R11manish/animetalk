import 'package:AnimeTalk/data/database/database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this import

class ChatMessageBubble extends StatelessWidget {
  final Message message;
  final String characterImage;

  const ChatMessageBubble({
    Key? key,
    required this.message,
    required this.characterImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.75;

    // Format the DateTime to a string
    final formattedTime = DateFormat('HH:mm').format(message.createdAt);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: message.role == 'user'
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (message.role != 'user') ...[
            CircleAvatar(
              backgroundImage: AssetImage(characterImage),
              radius: 16,
            ),
            const SizedBox(width: 8),
          ],
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.role == 'user' ? Colors.black : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message,
                    style: TextStyle(
                      color:
                          message.role == 'user' ? Colors.white : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedTime, // Use the formatted time string
                    style: TextStyle(
                      color: message.role == 'user'
                          ? Colors.white.withOpacity(0.7)
                          : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.role == 'user') const SizedBox(width: 24),
        ],
      ),
    );
  }
}
