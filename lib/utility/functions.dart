import 'dart:convert';

import 'package:AnimeTalk/data/database/database.dart';
import 'package:AnimeTalk/models/llm_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String isFirstTimeKey = 'isFirstTime';
const String userDetailsKey = 'userDetails';

Future<bool> IsFirstTime() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(isFirstTimeKey) ?? true;
}

Future<void> SetFirstTime(bool value) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool(isFirstTimeKey, value);
}

List<LLMessage> convertToLLMessages(List<Message> messages) {
  return messages
      .map((msg) => LLMessage(role: msg.role, content: msg.message))
      .toList();
}


String encodeLastKey(String value) {
  final Map<String, dynamic> lastKeyObject = {
    'name': {'S': value}
  };

  String jsonString = jsonEncode(lastKeyObject);
  String encodedLastKey = Uri.encodeComponent(jsonString);

  return encodedLastKey;
}