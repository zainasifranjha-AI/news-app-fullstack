import 'package:shared_preferences/shared_preferences.dart';

class AuthStore {
  AuthStore._();

  static const _tokenKey = 'sanctum_token';
  static const _userIdKey = 'user_id';
  static const _roleKey = 'user_role';

  static Future<void> saveToken(String? token) async {
    final p = await SharedPreferences.getInstance();
    if (token == null || token.isEmpty) {
      await p.remove(_tokenKey);
    } else {
      await p.setString(_tokenKey, token);
    }
  }

  static Future<void> saveProfile({int? userId, String? role}) async {
    final p = await SharedPreferences.getInstance();
    if (userId == null) {
      await p.remove(_userIdKey);
    } else {
      await p.setInt(_userIdKey, userId);
    }
    if (role == null || role.isEmpty) {
      await p.remove(_roleKey);
    } else {
      await p.setString(_roleKey, role);
    }
  }

  static Future<void> clearSession() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_tokenKey);
    await p.remove(_userIdKey);
    await p.remove(_roleKey);
  }

  static Future<String?> token() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_tokenKey);
  }

  static Future<int?> userId() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_userIdKey);
  }

  static Future<String?> role() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_roleKey);
  }
}
