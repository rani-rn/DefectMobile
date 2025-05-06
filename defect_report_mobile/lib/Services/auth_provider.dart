import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthProvider {
  static Future<Map<String, dynamic>?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return null;

    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    return {
      'name': decodedToken['unique_name'],
      'email': decodedToken['email'],
      'role': decodedToken['role']
    };
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return false;
    return !JwtDecoder.isExpired(token);
  }
}
