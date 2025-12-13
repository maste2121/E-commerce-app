import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:asrat/controllers/auth_controller.dart';

class EditAdminProfilePage extends StatefulWidget {
  const EditAdminProfilePage({super.key});

  @override
  State<EditAdminProfilePage> createState() => _EditAdminProfilePageState();
}

class _EditAdminProfilePageState extends State<EditAdminProfilePage> {
  final AuthController auth = Get.find<AuthController>();
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = auth.userName;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      await auth.updateAvatar(File(picked.path));
      setState(() {});
    }
  }

  void _saveProfile() {
    final updatedUser = Map<String, dynamic>.from(auth.user ?? {});
    updatedUser['name'] = nameController.text.trim();
    auth.updateUser(updatedUser);

    Get.back();
    Get.snackbar('Success', 'Profile updated successfully');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// ================= AVATAR =================
            GestureDetector(
              onTap: _pickImage,
              child: Obx(() {
                final avatar = auth.getAvatarImage();
                return CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: avatar is MemoryImage ? avatar : null,
                  child:
                      avatar is MemoryImage
                          ? null
                          : const Icon(Icons.camera_alt, size: 30),
                );
              }),
            ),

            const SizedBox(height: 20),

            /// ================= NAME =================
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Admin Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            /// ================= SAVE =================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProfile,
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
