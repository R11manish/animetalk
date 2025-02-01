import 'package:dio/dio.dart';
import 'api_interceptor.dart';
import 'api_endpoints.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ));

    _dio.interceptors.add(ApiInterceptor());
  }

  Future<Response> get(String path, {Map<String, dynamic>? params}) async {
    return await _dio.get(path, queryParameters: params);
  }

  Future<Response> post(String path,
      {dynamic data, bool requiresAuth = true}) async {
    return await _dio.post(
      path,
      data: data,
      options: Options(headers: _getHeaders(requiresAuth)),
    );
  }

  Future<Response> put(String path,
      {dynamic data, bool requiresAuth = true}) async {
    return await _dio.put(
      path,
      data: data,
      options: Options(headers: _getHeaders(requiresAuth)),
    );
  }

  Future<Response> delete(String path, {bool requiresAuth = true}) async {
    return await _dio.delete(
      path,
      options: Options(headers: _getHeaders(requiresAuth)),
    );
  }

  Map<String, String> _getHeaders(bool requiresAuth) {
    if (!requiresAuth) return {};
    return {'Authorization': 'Bearer YOUR_ACCESS_TOKEN'};
  }
}
