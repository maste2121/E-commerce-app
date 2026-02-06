import 'dart:convert';
import 'package:asrat/controllers/auth_controller.dart';
import 'package:asrat/iews/widgets/admin_dashboard_page.dart';
import 'package:asrat/iews/widgets/custom_textfields.dart';
import 'package:asrat/iews/widgets/main_shreen.dart';
import 'package:asrat/iews/widgets/signin_screen.dart';
import 'package:asrat/utlits/app_textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  final TextEditingController _namecontroller = TextEditingController();
  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _passwordcontroller = TextEditingController();
  final TextEditingController _confirmcontroller = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String _selectedRole = 'user';
  Future<void> _signupUser(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final name = _namecontroller.text.trim();
    final email = _emailcontroller.text.trim();
    final password = _passwordcontroller.text.trim();
    final role = _selectedRole;

    final authController = Get.find<AuthController>(); // Get the controller

    try {
      final response = await http.post(
        Uri.parse('http://10.161.163.14:8080/users/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // ✅ Update AuthController user data
        authController.updateUser(data);
        authController.setFirstTimeDone();
        // authController._setLoggedIn(true); // Optional: mark as logged in

        Get.snackbar(
          'Success',
          'Account created successfully!',
          snackPosition: SnackPosition.BOTTOM,
        );

        // Navigate based on role (keep your original navigation)
        if (role == 'admin') {
          Get.offAll(() => AdminDashboard());
        } else {
          Get.offAll(() => MainShreen());
        }
      } else {
        Get.snackbar(
          'Error',
          data['error'] ?? 'Signup failed',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Create Account',
                  style: AppTextstyle.withColor(
                    AppTextstyle.h1,
                    Theme.of(context).textTheme.bodyLarge!.color!,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'SignUp to get started',
                  style: AppTextstyle.withColor(
                    AppTextstyle.bodylarge,
                    isDark ? Colors.grey[400]! : Colors.grey[600]!,
                  ),
                ),
                const SizedBox(height: 40),

                CustomTextfields(
                  label: 'Full Name',
                  perfixIcon: Icons.person_outline,
                  keyboardType: TextInputType.name,
                  controller: _namecontroller,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextfields(
                  label: 'Email',
                  perfixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailcontroller,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!GetUtils.isEmail(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextfields(
                  label: 'Password',
                  perfixIcon: Icons.lock_outline,
                  keyboardType: TextInputType.visiblePassword,
                  ispassword: true,
                  controller: _passwordcontroller,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextfields(
                  label: 'Confirm Password',
                  perfixIcon: Icons.lock_outline,
                  keyboardType: TextInputType.visiblePassword,
                  ispassword: true,
                  controller: _confirmcontroller,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordcontroller.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _signupUser(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Sign Up',
                      style: AppTextstyle.withColor(
                        AppTextstyle.buttonmedium,
                        Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already Have an account?',
                      style: AppTextstyle.withColor(
                        AppTextstyle.bodymedium,
                        isDark ? Colors.grey[400]! : Colors.grey[600]!,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.to(() => SigninScreen());
                      },
                      child: Text(
                        'Sign In',
                        style: AppTextstyle.withColor(
                          AppTextstyle.buttonmedium,
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
