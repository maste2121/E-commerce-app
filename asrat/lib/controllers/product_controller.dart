import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductController extends GetxController {
  var products = <Product>[].obs;
  var isLoading = false.obs;
  var totalProducts = 0.obs;

  late final String baseUrl;

  @override
  void onInit() {
    super.onInit();
    if (Platform.isAndroid) {
      baseUrl = 'http://10.161.171.184:8080';
    } else {
      baseUrl = 'http://localhost:8080';
    }
    fetchProducts();
  }

  // READ
  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      final response = await http.get(Uri.parse('$baseUrl/products'));
      print('Fetch products status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List data = jsonDecode(
          response.body,
        ); // change to Map if backend wraps array
        products.assignAll(data.map((e) => Product.fromJson(e)).toList());
        totalProducts.value = products.length;
      } else {
        Get.snackbar("Error", "Failed to load products");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch products: $e");
      print('Fetch products error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // TOGGLE FAVORITE
  Future<void> toggleFavorite(Product product) async {
    try {
      final newStatus = !product.isFavorite;
      final index = products.indexWhere((p) => p.id == product.id);

      if (index != -1) {
        products[index] = products[index].copyWith(isFavorite: newStatus);
        products.refresh();
      }

      final response = await http.put(
        Uri.parse('$baseUrl/products/${product.id}/favorite'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'isFavorite': newStatus ? 1 : 0}),
      );

      if (response.statusCode != 200) {
        if (index != -1) {
          products[index] = products[index].copyWith(isFavorite: !newStatus);
          products.refresh();
        }
        Get.snackbar("Error", "Failed to update favorite");
      }
    } catch (e) {
      Get.snackbar("Error", "Favorite update failed: $e");
    }
  }

  // CREATE
  Future<void> addProduct(Product product) async {
    try {
      isLoading.value = true;
      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product.toJson()),
      );

      if (response.statusCode == 200) {
        final newProduct = Product.fromJson(jsonDecode(response.body));
        products.add(newProduct);
        totalProducts.value = products.length;
        Get.snackbar("Success", "Product added successfully");
      } else {
        Get.snackbar("Error", "Failed to add product");
      }
    } catch (e) {
      Get.snackbar("Error", "Add product failed: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // UPDATE
  Future<void> updateProduct(Product updatedProduct) async {
    try {
      isLoading.value = true;
      final response = await http.put(
        Uri.parse('$baseUrl/products/${updatedProduct.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedProduct.toJson()),
      );

      if (response.statusCode == 200) {
        final index = products.indexWhere((p) => p.id == updatedProduct.id);
        if (index != -1) {
          products[index] = updatedProduct;
          products.refresh();
        }
        Get.snackbar("Success", "Product updated successfully");
      } else {
        Get.snackbar("Error", "Failed to update product");
      }
    } catch (e) {
      Get.snackbar("Error", "Update failed: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // DELETE
  Future<void> deleteProduct(int id) async {
    try {
      isLoading.value = true;
      final response = await http.delete(Uri.parse('$baseUrl/products/$id'));
      if (response.statusCode == 200) {
        products.removeWhere((p) => p.id == id);
        totalProducts.value = products.length;
        Get.snackbar("Deleted", "Product removed successfully");
      } else {
        Get.snackbar("Error", "Failed to delete product");
      }
    } catch (e) {
      Get.snackbar("Error", "Delete failed: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
