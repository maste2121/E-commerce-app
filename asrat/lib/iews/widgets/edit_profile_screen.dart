import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:asrat/controllers/auth_controller.dart';
import 'package:asrat/utlits/app_textstyle.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final user = auth.user;

    final nameController = TextEditingController(
      text: user?['user']?['name'] ?? "",
    );
    final emailController = TextEditingController(
      text: user?['user']?['email'] ?? "",
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Full Name"),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Get.snackbar("Updated", "Profile updated successfully");
              },
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
