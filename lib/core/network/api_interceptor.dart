import 'package:dio/dio.dart';
import 'api_endpoints.dart';

class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final noAuthEndpoints = [ApiEndpoints.chat];

    // Add Authorization header only if required
    if (noAuthEndpoints.contains(options.path)) {
      options.headers['Authorization'] = 'Bearer YOUR_ACCESS_TOKEN';
    }

    print('🟢 REQUEST[${options.method}] => PATH: ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('🔴 ERROR[${err.response?.statusCode}] => MESSAGE: ${err.message}');

    if (err.response?.statusCode == 401) {
      // Handle unauthorized (force logout, refresh token, etc.)
      print("🔴 Unauthorized - Redirect to Login");
    }

    handler.next(err);
  }
}
