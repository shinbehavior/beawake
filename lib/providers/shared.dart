import 'package:shared_preferences/shared_preferences.dart';

class Shared {
  static String loginSharedPreference = "LOGGEDINKEY";

  // Save login state
  static Future<bool> saveLoginSharedPreference(bool islogin) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(loginSharedPreference, islogin);
  }

  // Fetch login state
  static Future<bool?> getUserSharedPreferences() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool(loginSharedPreference);
  }
}
