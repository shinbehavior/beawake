import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  Future<void> saveEventLocally(String eventType, DateTime eventTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastEventType', eventType);
    await prefs.setString('lastEventTime', eventTime.toIso8601String());
  }

  Future<void> clearLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
