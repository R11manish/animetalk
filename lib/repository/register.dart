import 'package:AnimeTalk/core/network/api_client.dart';
import 'package:AnimeTalk/core/network/api_endpoints.dart';
import 'package:AnimeTalk/models/user_details.dart';

class Register {
  late ApiClient _apiClient;

  Register() {
    _apiClient = ApiClient(); // Initialize the API client in constructor
  }

  Future<void> sendOtp(UserDetails user) async {
    print(user.toJson());
    var h = await _apiClient.post(ApiEndpoints.sendOtp,
        data: user.toJson(), requiresAuth: false);

    print(user);
  }
}
