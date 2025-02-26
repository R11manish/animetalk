import 'dart:convert';
import 'package:AnimeTalk/models/character_model.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl = "http://192.168.50.153:3000";
  final bool useMockData;

  ApiClient({
    this.useMockData = false,
  });
}
