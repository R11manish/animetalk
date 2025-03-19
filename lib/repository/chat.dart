import 'package:AnimeTalk/constants/types.dart';
import 'package:AnimeTalk/core/network/api_client.dart';
import 'package:AnimeTalk/core/network/api_endpoints.dart';
import 'package:AnimeTalk/core/service_locator.dart';
import 'package:AnimeTalk/data/repositories/message_repository.dart';
import 'package:AnimeTalk/models/llm_message.dart';
import 'package:AnimeTalk/models/user_details.dart';
import 'package:AnimeTalk/services/token_service.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class Chat {
  late ApiClient _apiClient;
  late TokenService tokenService;
  late UserDetails user;
  late final MessageRepository messageRepository;

  Chat() {
    _apiClient = ApiClient();
    tokenService = getIt<TokenService>();
    messageRepository = getIt<MessageRepository>();
  }

  Future<void> sendMessage(int id, String charName, String charDesc,
      List<LLMessage> messages) async {
    final userToken = await tokenService.getToken(USER_DETAILS);
    if (userToken != null) {
      user = UserDetails.fromString(userToken);
    } else {
      throw Exception('User details not found');
    }

    LLMCharacter character = LLMCharacter(
        name: user.name,
        gender: user.gender,
        characterName: charName,
        charDesc: charDesc,
        messages: messages);

    try {
      var response = await _apiClient.post(ApiEndpoints.chat,
          data: character.toJson(), requiresAuth: true);

      if (response.statusCode == 200) {
        messageRepository.createMessage(
            characterId: id,
            role: 'assistant',
            message: response.data?['message']);
      }
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 429) {
        // Show rate limit exceeded message
        ScaffoldMessenger.of(getIt<GlobalKey<NavigatorState>>().currentContext!)
            .showSnackBar(
          const SnackBar(
            content: Text(
                'Message limit exceeded. Please try again after 12 hours.'),
            duration: Duration(seconds: 5),
          ),
        );
      } else {
        rethrow; // Rethrow other errors
      }
    }
  }
}
