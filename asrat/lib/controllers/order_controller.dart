import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/order.dart';

class OrderController extends GetxController {
  var orders = <Order>[].obs;
  var isLoading = false.obs;

  var searchQuery = ''.obs;
  var selectedStatus = 'All'.obs;
  late final String baseUrl;

  @override
  void onInit() {
    super.onInit();

    // ✅ Automatically detect platform
    // Change IP below to your local machine IP when testing on Android phone
    baseUrl =
        Platform.isAndroid
            ? 'http://10.161.163.14:8080' // use your machine’s Wi-Fi IPv4
            : 'http://localhost:8080';

    fetchOrders();
  }

  void setSearchQuery(String query) => searchQuery.value = query;
  void setSelectedStatus(String status) => selectedStatus.value = status;

  // ✅ Fetch all orders
  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      final response = await http.get(Uri.parse("$baseUrl/orders"));

      if (response.statusCode == 200) {
        final List jsonData = jsonDecode(response.body);

        orders.value =
            jsonData.map((e) {
              if (e is Map<String, dynamic>) {
                return Order.fromJson(e);
              } else if (e is Map) {
                return Order.fromJson(Map<String, dynamic>.from(e));
              } else {
                throw Exception("Invalid order data format");
              }
            }).toList();
      } else {
        print("❌ Fetch orders failed: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Fetch orders error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Add new order
  Future<void> addOrder({
    required String customerName,
    required int productId,
    required String productName,
    required double productPrice,
    required int quantity,
    int? customerId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/orders"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "customer_id": customerId,
          "customer_name": customerName,
          "product_id": productId,
          "product_name": productName,
          "product_price": productPrice,
          "quantity": quantity,
          "total_price": productPrice * quantity,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        fetchOrders();
        Get.snackbar(
          "✅ Success",
          "Order placed successfully!",
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar(
          "Error",
          "Failed to place order: ${errorData['error'] ?? 'Unknown error'}",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print("❌ Add order error: $e");
      Get.snackbar(
        "Error",
        "Failed to place order: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ✅ Update order status
  Future<void> updateOrderStatus(int orderId, String newStatus) async {
    try {
      isLoading.value = true;

      final url = Uri.parse('$baseUrl/orders/$orderId/status');
      final body = jsonEncode({'status': newStatus});
      final headers = {'Content-Type': 'application/json'};

      print("🟢 Sending PUT: $url");
      print("📦 Body: $body");

      final response = await http.put(url, headers: headers, body: body);

      print("🔵 Response code: ${response.statusCode}");
      print("🔵 Response body: ${response.body}");

      if (response.statusCode == 200) {
        // ✅ Find order by ID in the list
        final index = orders.indexWhere((order) => order.id == orderId);
        if (index != -1) {
          // ✅ Update the order object’s status field
          orders[index].status = newStatus;
        }

        Get.snackbar('Success', 'Order status updated successfully');
      } else {
        Get.snackbar('Error', 'Failed to update order status');
      }
    } catch (e) {
      print("❌ Exception: $e");
      Get.snackbar('Error', 'Status update failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Delete order
  Future<void> deleteOrder(int id) async {
    try {
      final response = await http.delete(Uri.parse("$baseUrl/orders/$id"));
      if (response.statusCode == 200) {
        orders.removeWhere((o) => o.id == id);
        Get.snackbar("🗑️ Deleted", "Order removed successfully");
      } else {
        print("❌ Delete order failed: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Delete order error: $e");
    }
  }

  // ✅ Computed values
  double get totalRevenue =>
      orders.fold(0, (sum, order) => sum + order.totalPrice);
  int get totalOrders => orders.fold(0, (sum, order) => sum + order.quantity);
}
