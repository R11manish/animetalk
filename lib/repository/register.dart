import 'package:AnimeTalk/constants/types.dart';
import 'package:AnimeTalk/core/network/api_client.dart';
import 'package:AnimeTalk/core/network/api_endpoints.dart';
import 'package:AnimeTalk/core/service_locator.dart';
import 'package:AnimeTalk/models/user_details.dart';
import 'package:AnimeTalk/services/token_service.dart';

class Register {
  late ApiClient _apiClient;
  late TokenService tokenService;

  Register() {
    _apiClient = ApiClient();
    tokenService = getIt<TokenService>();
  }

  Future<void> sendOtp(UserDetails user) async {
    print(user.toJson());
    await _apiClient.post(ApiEndpoints.sendOtp,
        data: user.toJson(), requiresAuth: false);
    await tokenService.saveToken(USER_DETAILS, user.toString());
  }

  Future<void> validateOtp(String otp, String? email) async {
    final response = await _apiClient.post(ApiEndpoints.verifyOtp,
        data: {'otp': otp, 'email': email}, requiresAuth: false);

    final apiKey = response.data?['api_key'];
    if (apiKey == null) {
      throw StateError('API key not found in response');
    }

    tokenService.saveToken(API_KEY, apiKey);
  }
}
