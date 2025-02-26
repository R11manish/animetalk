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
    ));

    _dio.interceptors.add(ApiInterceptor());
    tokenService = getIt<TokenService>();
  }

  Future<Response> get(String path, {Map<String, dynamic>? params}) async {
    return await _dio.get(path, queryParameters: params);
  }

  Future<Response> post(String path,
      {dynamic data, bool requiresAuth = true}) async {
    print(await _getHeaders(requiresAuth));
    print(data);
    return await _dio.post(
      path,
      data: data,
      options: Options(headers: await _getHeaders(requiresAuth)),
    );
  }

  Future<Response> put(String path,
      {dynamic data, bool requiresAuth = true}) async {
    return await _dio.put(
      path,
      data: data,
      options: Options(headers: await _getHeaders(requiresAuth)),
    );
  }

  Future<Response> delete(String path, {bool requiresAuth = true}) async {
    return await _dio.delete(
      path,
      options: Options(headers: await _getHeaders(requiresAuth)),
    );
  }

  Future<Map<String, String>> _getHeaders(bool requiresAuth) async {
    if (!requiresAuth) return {};

    String? value = await tokenService.getToken('x-api-key');
    if (value == null) return {};

    return {'x-api-key': value};
  }
}
