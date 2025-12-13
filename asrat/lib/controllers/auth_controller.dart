import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AuthController extends GetxController {
  final _storage = GetStorage();

  // Reactive variables
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

  @override
  void onInit() {
    super.onInit();
    baseUrl =
        Platform.isAndroid
            ? "http://10.161.163.14:8080"
            : "http://localhost:8080";
    _loadSavedState();
  }

  void _loadSavedState() {
    _isFirstTime.value = _storage.read('isFirstTime') ?? true;
    _loggedIn.value = _storage.read('loggedIn') ?? false;

    final savedUser = _storage.read('user');
    if (savedUser != null) _user.value = Map<String, dynamic>.from(savedUser);

    // Load avatar from storage separately
    final savedAvatar = _storage.read('avatar');
    if (savedAvatar != null) {
      final updatedUser = Map<String, dynamic>.from(_user.value ?? {});
      updatedUser['avatar'] = savedAvatar;
      _user.value = updatedUser;
    }
  }

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
    _storage.write('userRole', userData['role'] ?? "user");
  }

  Future<bool> signup(
    String name,
    String email,
    String password,
    String role,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "role": role,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data["success"] == true) {
        updateUser(data);
        return true;
      } else {
        Get.snackbar("Signup Failed", data["error"] ?? "Unknown error");
        return false;
      }
    } catch (e) {
      Get.snackbar("Signup Error", e.toString());
      return false;
    }
  }

  Future<bool> loginWithBackend(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/signin"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data["success"] == true) {
        _setLoggedIn(true);
        updateUser(data);
        return true;
      } else {
        Get.snackbar("Login Failed", data["error"] ?? "Invalid credentials");
        return false;
      }
    } catch (e) {
      Get.snackbar("Login Error", e.toString());
      return false;
    }
  }

  Future<void> fetchCurrentUser() async {
    final savedUser = _storage.read('user');
    if (savedUser != null) _user.value = Map<String, dynamic>.from(savedUser);
    if (userId == 0) return;

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/user/$userId"),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true && data["user"] != null) updateUser(data);
      }
    } catch (e) {
      print("❌ Fetch user error: $e");
    }
  }

  /// Avatar functions

  Future<void> updateAvatar(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final base64String = base64Encode(bytes);

    final updatedUser = Map<String, dynamic>.from(_user.value ?? {});
    updatedUser['avatar'] = base64String;

    _storage.write('avatar', base64String); // persist separately
    updateUser(updatedUser);
  }

  ImageProvider getAvatarImage() {
    final base64String = _user.value?['avatar'] ?? '';
    if (base64String.isEmpty) {
      // Default person icon
      return const AssetImage('assets/images/default_person.png');
      // Or you can use Flutter Icon widget in UI instead of image
    } else {
      try {
        return MemoryImage(base64Decode(base64String));
      } catch (_) {
        return const AssetImage('assets/images/default_person.png');
      }
    }
  }

  Future<void> pickAvatarImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) await updateAvatar(File(picked.path));
  }

  void logout() {
    _loggedIn.value = false;
    _user.value = null;
    // Keep avatar persistent
    _storage.remove('loggedIn');
    _storage.remove('userRole');
  }
}
