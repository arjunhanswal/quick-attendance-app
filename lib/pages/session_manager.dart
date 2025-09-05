import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _keyUid = 'uid';
  static const _keyUsername = 'username';
  static const _keyType = 'type';
  static const _keyStatus = 'status';

  // Save user data
  static Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUid, user['uid']);
    await prefs.setString(_keyUsername, user['username']);
    await prefs.setString(_keyType, user['type']);
    await prefs.setInt(_keyStatus, user['status']);
  }

  // Get user data
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_keyUid)) return null;

    return {
      'uid': prefs.getInt(_keyUid),
      'username': prefs.getString(_keyUsername),
      'type': prefs.getString(_keyType),
      'status': prefs.getInt(_keyStatus),
    };
  }

  static Future<void> saveUserId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUid, id);
  }

  static Future<int> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUid) ?? 0; // 0 if not found
  }

  // Logout / clear session
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
