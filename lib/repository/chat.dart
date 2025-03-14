import 'package:AnimeTalk/constants/types.dart';
import 'package:AnimeTalk/core/network/api_client.dart';
import 'package:AnimeTalk/core/network/api_endpoints.dart';
import 'package:AnimeTalk/core/service_locator.dart';
import 'package:AnimeTalk/data/repositories/message_repository.dart';
import 'package:AnimeTalk/models/llm_message.dart';
import 'package:AnimeTalk/models/user_details.dart';
import 'package:AnimeTalk/services/token_service.dart';

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

    var response = await _apiClient.post(ApiEndpoints.chat,
        data: character.toJson(), requiresAuth: true);

    if (response.statusCode == 200) {
      messageRepository.createMessage(
          characterId: id,
          role: 'assistant',
          message: response.data?['message']);
    }
  }
}
