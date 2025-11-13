import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class AuthController extends GetxController {
  final _storage = GetStorage();
  final RxBool _isFirstTime = true.obs;
  final RxBool _loggedIn = false.obs;

  bool get isFirstTime => _isFirstTime.value;
  bool get loggedIn => _loggedIn.value;
  String get userRole => _storage.read('userRole') ?? 'user';

  /// ✅ Expose logged in user info
  Map<String, dynamic>? get user {
    final data = _storage.read('user');
    if (data != null && data is Map) return data.cast<String, dynamic>();
    return null;
  }

  Map<String, dynamic>? get currentUser {
    return _storage.read('user') as Map<String, dynamic>?;
  }

  int get userId => user?['user']?['id'] ?? 0;
  String get userName => user?['user']?['name'] ?? '';

  late final String baseUrl;

  @override
  void onInit() {
    super.onInit();
    baseUrl =
        Platform.isAndroid
            ? "http://10.161.171.184:8080"
            : "http://localhost:8080";
    _loadInitialState();
  }

  void _loadInitialState() {
    _isFirstTime.value = _storage.read('isFirstTime') ?? true;
    _loggedIn.value = _storage.read('loggedIn') ?? false;
  }

  void setFirstTimeDone() {
    _isFirstTime.value = false;
    _storage.write('isFirstTime', false);
  }

  void _setLoggedIn(bool value) {
    _loggedIn.value = value;
    _storage.write('loggedIn', value);
  }

  /// ✅ Sign Up
  Future<bool> signup(
    String name,
    String email,
    String password,
    String role,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "role": role,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        _storage.write('userRole', role);
        return true;
      } else {
        Get.snackbar("Sign Up Failed", data['error'] ?? 'Unknown error');
        return false;
      }
    } catch (e) {
      Get.snackbar("Sign Up Failed", e.toString());
      return false;
    }
  }

  /// ✅ Login
  Future<bool> loginWithBackend(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"email": email, "password": password}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        _setLoggedIn(true);
        _storage.write('user', data); // Save user info
        _storage.write('userRole', data['user']['role'] ?? 'user');
        return true;
      } else {
        Get.snackbar("Login Failed", data['error'] ?? 'Invalid credentials');
        return false;
      }
    } catch (e) {
      Get.snackbar("Login Failed", e.toString());
      return false;
    }
  }

  /// ✅ Logout
  void logout() {
    _setLoggedIn(false);
    _storage.remove('user');
    _storage.remove('userRole');
  }
}
