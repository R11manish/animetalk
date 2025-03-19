import 'package:animetalk/constants/types.dart';
import 'package:animetalk/core/network/api_client.dart';
import 'package:animetalk/core/network/api_endpoints.dart';
import 'package:animetalk/core/service_locator.dart';
import 'package:animetalk/models/user_details.dart';
import 'package:animetalk/services/token_service.dart';

class Register {
  late ApiClient _apiClient;
  late TokenService tokenService;

  Register() {
    _apiClient = ApiClient();
    tokenService = getIt<TokenService>();
  }

  Future<void> sendOtp(UserDetails user) async {
    _apiClient.post(ApiEndpoints.sendOtp,
        data: user.toJson(), requiresAuth: false);
    await tokenService.saveToken(USER_DETAILS, user.toString());
  }

  Future<void> validateOtp(String otp, String? email) async {
    final response = await _apiClient.post(ApiEndpoints.verifyOtp,
        data: {'otp': otp, 'email': email}, requiresAuth: false);

    final apiKey = response.data?['api_key'];

    if (response.data?['status'] == "error") {
      throw Exception(response.data?['message'] ?? 'An error occurred');
    }
    if (apiKey == null) {
      throw StateError('API key not found in response');
    }

    tokenService.saveToken(API_KEY, apiKey);
  }
}
