import 'dart:convert';
import 'package:asrat/iews/widgets/admin_dashboard_page.dart';
import 'package:asrat/iews/widgets/custom_textfields.dart';
import 'package:asrat/iews/widgets/forgot_password_screen.dart';
import 'package:asrat/iews/widgets/main_shreen.dart';
import 'package:asrat/iews/widgets/sign_up_screen.dart';
import 'package:asrat/utlits/app_textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class SigninScreen extends StatelessWidget {
  SigninScreen({super.key});

  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _passwordcontroller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _handleSignIn(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailcontroller.text.trim();
    final password = _passwordcontroller.text.trim();

    try {
      final response = await http.post(
        Uri.parse('http://10.161.171.184:8080/signin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // ✅ Store JWT token and role locally
        final storage = GetStorage();
        storage.write('userToken', data['token']);
        storage.write('userRole', data['user']['role'] ?? 'user');

        Get.snackbar(
          'Success',
          'Login successful!',
          snackPosition: SnackPosition.BOTTOM,
        );

        // Navigate based on role
        final userRole = data['user']['role'] ?? 'user';
        if (userRole == 'admin') {
          Get.offAll(() => AdminDashboard());
        } else {
          Get.offAll(() => MainShreen());
        }
      } else {
        Get.snackbar(
          'Error',
          data['error'] ?? 'Invalid email or password',
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text(
                  'Welcome Back!',
                  style: AppTextstyle.withColor(
                    AppTextstyle.h1,
                    Theme.of(context).textTheme.bodyLarge!.color!,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue shopping',
                  style: AppTextstyle.withColor(
                    AppTextstyle.bodylarge,
                    isDark ? Colors.grey[400]! : Colors.grey[600]!,
                  ),
                ),
                const SizedBox(height: 24),

                CustomTextfields(
                  label: 'Email',
                  perfixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailcontroller,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter your email';
                    if (!GetUtils.isEmail(value))
                      return 'Please enter a valid email';
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
                    if (value == null || value.isEmpty)
                      return 'Please enter your password';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Get.to(() => ForgotPasswordScreen()),
                    child: Text(
                      'Forgot password?',
                      style: AppTextstyle.withColor(
                        AppTextstyle.buttonmedium,
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _handleSignIn(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Sign In',
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
                      'Do not have an account?',
                      style: AppTextstyle.withColor(
                        AppTextstyle.bodymedium,
                        isDark ? Colors.grey[400]! : Colors.grey[600]!,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.to(() => SignUpScreen()),
                      child: Text(
                        'Sign Up',
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
