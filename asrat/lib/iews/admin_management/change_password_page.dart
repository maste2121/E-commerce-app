import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:asrat/controllers/auth_controller.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final AuthController auth = Get.find<AuthController>();

  final currentController = TextEditingController();
  final newController = TextEditingController();
  final confirmController = TextEditingController();

  bool loading = false;

  Future<void> _changePassword() async {
    if (newController.text != confirmController.text) {
      Get.snackbar('Error', 'Passwords do not match');
      return;
    }

    setState(() => loading = true);

    try {
      final response = await http.post(
        Uri.parse('${auth.baseUrl}/change-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': auth.userId,
          'currentPassword': currentController.text,
          'newPassword': newController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        Get.back();
        Get.snackbar('Success', 'Password updated successfully');
      } else {
        Get.snackbar('Failed', data['error'] ?? 'Password change failed');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _passwordField('Current Password', currentController),
            const SizedBox(height: 16),
            _passwordField('New Password', newController),
            const SizedBox(height: 16),
            _passwordField('Confirm New Password', confirmController),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : _changePassword,
                child:
                    loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Update Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _passwordField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
