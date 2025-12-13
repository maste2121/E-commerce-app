import 'dart:convert';
import 'dart:io';
import 'package:asrat/models/user.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class UserController extends GetxController {
  var users = <User>[].obs;
  var isLoading = false.obs;
  late final String baseUrl;

  @override
  void onInit() {
    super.onInit();
    // Adjust base URL for emulator or desktop
    if (Platform.isAndroid) {
      baseUrl = 'http://10.161.163.14:8080';
    } else {
      baseUrl = 'http://localhost:8080';
    }
    fetchUsers();
  }

  // 🔹 Fetch all users
  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;
      final response = await http.get(Uri.parse('$baseUrl/users'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final userList = data is List ? data : data['users'];
        users.value = userList.map<User>((u) => User.fromJson(u)).toList();
      } else {
        Get.snackbar('Error', 'Failed to fetch users (${response.statusCode})');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch users: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 🔹 Update user role
  Future<void> updateUserRole(int userId, String newRole) async {
    try {
      final url = Uri.parse('$baseUrl/users/$userId');
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'role': newRole}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true || data['message'] == 'Role updated') {
          final idx = users.indexWhere((u) => u.id == userId);
          if (idx != -1) {
            users[idx].role = newRole;
            users.refresh();
          }
          Get.snackbar('Success', 'User role updated successfully');
        } else {
          Get.snackbar('Error', data['message'] ?? 'Failed to update role');
        }
      } else {
        Get.snackbar('Error', 'Failed to update role (${response.statusCode})');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error updating role: $e');
    }
  }
}
