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
