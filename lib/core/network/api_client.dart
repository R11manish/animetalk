import 'package:AnimeTalk/core/service_locator.dart';
import 'package:AnimeTalk/services/token_service.dart';
import 'package:dio/dio.dart';
import 'api_interceptor.dart';
import 'api_endpoints.dart';

class ApiClient {
  late final Dio _dio;
  late TokenService tokenService;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 360),
      receiveTimeout: const Duration(seconds: 360),
      validateStatus: (status) => true, 
    ));

    _dio.interceptors.add(ApiInterceptor());
    tokenService = getIt<TokenService>();
  }

  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String path,
      {dynamic data, bool requiresAuth = true}) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        options: Options(headers: await _getHeaders(requiresAuth)),
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(String path,
      {dynamic data, bool requiresAuth = true}) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        options: Options(headers: await _getHeaders(requiresAuth)),
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(String path, {bool requiresAuth = true}) async {
    try {
      final response = await _dio.delete(
        path,
        options: Options(headers: await _getHeaders(requiresAuth)),
      );

      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException error) {
    String message = 'An error occurred';

    if (error.response?.data != null) {
      if (error.response?.data is Map) {
        message = error.response?.data['message'] ??
            error.response?.data['error'] ??
            error.response?.data['error_message'] ??
            error.response?.data['error_description'] ??
            error.message ??
            'An error occurred';
      } else if (error.response?.data is String) {
        message = error.response?.data;
      }
    } else if (error.type == DioExceptionType.connectionTimeout) {
      message = 'Connection timeout';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      message = 'Server not responding';
    } else if (error.type == DioExceptionType.connectionError) {
      message = 'No internet connection';
    }

    return Exception(message);
  }

  Future<Map<String, String>> _getHeaders(bool requiresAuth) async {
    if (!requiresAuth) return {};

    String? value = await tokenService.getToken('x-api-key');
    if (value == null) return {};

    return {'x-api-key': value};
  }
}
