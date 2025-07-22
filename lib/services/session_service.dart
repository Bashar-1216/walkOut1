import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../app_config.dart';
import 'auth_service.dart';

class SessionService {
  final _authService = AuthService();

  /// يبدأ جلسة تسوق جديدة للمستخدم الحالي.
  Future<int?> startSession() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');
    if (token == null) throw Exception('User not authenticated.');

    // جلب بيانات المستخدم من التوكن
    final currentUser = await _authService.getCurrentUser();
    if (currentUser == null) {
      throw Exception('Could not fetch current user data.');
    }

    final int userId = currentUser.id;

    final url = Uri.parse('${AppConfig.baseUrl}/sessions/start');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'user_id': userId}),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['id']; // إرجاع معرف الجلسة الجديدة
      } else {
        print('Failed to start session: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error starting session: $e');
      return null;
    }
  }

  /// يتحقق من وجود جلسة نشطة للمستخدم.
  Future<int?> getActiveSession() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');
    if (token == null) return null;

    final url = Uri.parse('${AppConfig.baseUrl}/sessions/active');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['id']; // إرجاع معرف الجلسة الحالية
      } else if (response.statusCode == 404) {
        // لا توجد جلسة نشطة
        return null;
      } else {
        print('Error checking active session: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception in getActiveSession: $e');
      return null;
    }
  }
}
