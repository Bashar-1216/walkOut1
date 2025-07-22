import 'package:http/http.dart' as http;
import 'dart:convert';
import '../app_config.dart';

class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'],
    );
  }
}

class ProductService {
  Future<List<Product>> getProducts() async {
    final url = Uri.parse("${AppConfig.baseUrl}/products");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        return body.map((dynamic item) => Product.fromJson(item)).toList();
      } else {
        print("Failed to load products with status: ${response.statusCode}");
        print("Response body: ${response.body}");
        throw Exception("Failed to load products: ${response.statusCode}");
      }
    } catch (e) {
      print("Error connecting to the server for products: $e");
      throw Exception("Error connecting to the server: $e");
    }
  }
}