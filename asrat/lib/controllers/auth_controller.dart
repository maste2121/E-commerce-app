import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AuthController extends GetxController {
  final _storage = GetStorage();

  // =====================
  // Reactive state
  // =====================
  final RxBool _isFirstTime = true.obs;
  final RxBool _loggedIn = false.obs;
  final Rx<Map<String, dynamic>?> _user = Rx<Map<String, dynamic>?>(null);

  bool get isFirstTime => _isFirstTime.value;
  bool get loggedIn => _loggedIn.value;
  Map<String, dynamic>? get user => _user.value;

  int get userId => _user.value?['id'] ?? 0;
  String get userName => _user.value?['name'] ?? "";
  String get userEmail => _user.value?['email'] ?? "";
  String get userRole => _user.value?['role'] ?? "user";

  late final String baseUrl;

  // =====================
  // Init
  // =====================
  @override
  void onInit() {
    super.onInit();

    // Android emulator must NOT use localhost
    baseUrl = "https://e-commerce-app-api-hvdc.onrender.com";

    _loadSavedState();
  }

  void _loadSavedState() {
    _isFirstTime.value = _storage.read('isFirstTime') ?? true;
    _loggedIn.value = _storage.read('loggedIn') ?? false;

    final savedUser = _storage.read('user');
    if (savedUser != null) {
      _user.value = Map<String, dynamic>.from(savedUser);
    }

    final savedAvatar = _storage.read('avatar');
    if (savedAvatar != null && _user.value != null) {
      final updatedUser = Map<String, dynamic>.from(_user.value!);
      updatedUser['avatar'] = savedAvatar;
      _user.value = updatedUser;
    }
  }

  // =====================
  // Helpers
  // =====================
  void setFirstTimeDone() {
    _isFirstTime.value = false;
    _storage.write('isFirstTime', false);
  }

  void _setLoggedIn(bool value) {
    _loggedIn.value = value;
    _storage.write('loggedIn', value);
  }

  void updateUser(Map<String, dynamic> data) {
    final userData = data['user'] ?? data;
    _user.value = Map<String, dynamic>.from(userData);
    _storage.write('user', userData);
    _storage.write('userRole', userData['role'] ?? 'user');
  }

  void _ensureJson(http.Response response) {
    final ct = response.headers['content-type'] ?? '';
    if (!ct.contains('application/json')) {
      throw Exception('Server returned non-JSON response');
    }
  }

  // =====================
  // AUTH API
  // =====================

  /// POST /users/signup
  Future<bool> signup(
    String name,
    String email,
    String password,
    String role,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/signup'),
        headers: const {"Content-Type": "application/json"},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      _ensureJson(response);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        updateUser(data);
        _setLoggedIn(true);
        return true;
      } else {
        Get.snackbar('Signup Failed', data['error'] ?? 'Unknown error');
        return false;
      }
    } catch (e) {
      Get.snackbar('Signup Error', e.toString());
      return false;
    }
  }

  /// POST /users/signin
  Future<bool> loginWithBackend(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/signin'),
        headers: const {"Content-Type": "application/json"},
        body: jsonEncode({'email': email, 'password': password}),
      );

      _ensureJson(response);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _setLoggedIn(true);
        updateUser(data);
        return true;
      } else {
        Get.snackbar('Login Failed', data['error'] ?? 'Invalid credentials');
        return false;
      }
    } catch (e) {
      Get.snackbar('Login Error', e.toString());
      return false;
    }
  }

  /// GET /users/:id
  Future<void> fetchCurrentUser() async {
    final savedUser = _storage.read('user');
    if (savedUser != null) {
      _user.value = Map<String, dynamic>.from(savedUser);
    }

    if (userId == 0) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: const {"Content-Type": "application/json"},
      );

      _ensureJson(response);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        updateUser(data);
      }
    } catch (e) {
      debugPrint('❌ Fetch user error: $e');
    }
  }

  // =====================
  // AVATAR (LOCAL ONLY)
  // =====================

  Future<void> updateAvatar(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final base64String = base64Encode(bytes);

    final updatedUser = Map<String, dynamic>.from(_user.value ?? {});
    updatedUser['avatar'] = base64String;

    _storage.write('avatar', base64String);
    updateUser(updatedUser);
  }

  ImageProvider getAvatarImage() {
    final base64String = _user.value?['avatar'] ?? '';

    if (base64String.isEmpty) {
      return const AssetImage('assets/images/default_person.png');
    }

    try {
      return MemoryImage(base64Decode(base64String));
    } catch (_) {
      return const AssetImage('assets/images/default_person.png');
    }
  }

  Future<void> pickAvatarImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      await updateAvatar(File(picked.path));
    }
  }

  // =====================
  // LOGOUT
  // =====================
  void logout() {
    _loggedIn.value = false;
    _user.value = null;

    _storage.remove('loggedIn');
    _storage.remove('user');
    _storage.remove('userRole');
    // avatar intentionally preserved
  }
}
