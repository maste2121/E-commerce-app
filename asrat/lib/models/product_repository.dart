import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product.dart';

class ProductRepository {
  final String baseUrl = 'http://10.161.163.14:8080';

  Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => Product.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching products: $e');
      return [];
    }
  }

  // CREATE product
  Future<Product?> createProduct(Product product) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product.toJson()),
      );
      if (response.statusCode == 201) {
        return Product.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print('❌ Error creating product: $e');
    }
    return null;
  }

  // UPDATE product
  Future<Product?> updateProduct(Product product) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/products/${product.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product.toJson()),
      );
      if (response.statusCode == 200) {
        return Product.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print('❌ Error updating product: $e');
    }
    return null;
  }

  // DELETE product
  Future<bool> deleteProduct(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/products/$id'));
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error deleting product: $e');
      return false;
    }
  }
}
