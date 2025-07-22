// lib/services/receipt_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_config.dart';
class Receipt {
  final int receipt_id;
  final double total_amount;
  final String receipt_date;

  Receipt({
    required this.receipt_id,
    required this.total_amount,
    required this.receipt_date
  });

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      receipt_id: json['receipt_id'],
      total_amount: (json['total_amount'] as num).toDouble(),
      receipt_date: json['receipt_date'], 
    );
  }
}



class ReceiptService {
  final String _baseUrl = AppConfig.baseUrl;

  Future<List<Receipt>> getMyReceipts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('User not authenticated.');
    }
    
    final url = Uri.parse('$_baseUrl/users/me/receipts');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        List<Receipt> receipts = body
            .map((dynamic item) => Receipt.fromJson(item))
            .toList();
        return receipts;
      } else {
        print("Failed to load receipts with status: ${response.statusCode}");
        print("Response body: ${response.body}");
        throw Exception("Failed to load receipts: ${response.statusCode}");
      }
    } catch (e) {
      print("Error getting receipts: $e");
      throw Exception("Error: $e");
    }
  }
}