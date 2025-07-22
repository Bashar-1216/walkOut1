// lib/services/auth_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_config.dart';

class CurrentUser {
  final int id;
  final String phoneNumber;
  final String? paymentToken;

  CurrentUser({required this.id, required this.phoneNumber, this.paymentToken});

  factory CurrentUser.fromJson(Map<String, dynamic> json) {
    return CurrentUser(
      id: json['id'],
      phoneNumber: json['phone_number'],
      paymentToken: json['payment_token'],
    );
  }
}

class AuthService {
  /* -------- existing methods -------- */
  Future<bool> registerUser(String phoneNumber) async {
    final url = Uri.parse("${AppConfig.baseUrl}/auth/register");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"phone_number": phoneNumber}),
      );
      if (response.statusCode == 201 || response.statusCode == 409) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<String?> verifyOtp(String phoneNumber, String otp) async {
    final url = Uri.parse("${AppConfig.baseUrl}/auth/verify");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"phone_number": phoneNumber, "otp_code": otp}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String token = data["access_token"];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("auth_token", token);
        return token;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<CurrentUser?> getCurrentUser({bool forceRefresh = false}) async {
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString("auth_token");
  if (token == null) return null;

  final url = Uri.parse("${AppConfig.baseUrl}/users/me");
  try {
    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200) {
      return CurrentUser.fromJson(json.decode(response.body));
    }
    if (response.statusCode == 401) {
      await prefs.remove("auth_token");
    }
    return null;
  } catch (e) {
    return null;
  }
}

  /* -------- NEW method inside AuthService -------- */
  Future<bool> updatePaymentToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final String? authToken = prefs.getString('auth_token');
    if (authToken == null) return false;

    final url = Uri.parse('${AppConfig.baseUrl}/users/me/payment-token');
    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({'payment_token': token}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error updating payment token: $e");
      return false;
    }
  }
}
