import 'package:asrat/iews/admin_management/change_password_page.dart';
import 'package:asrat/iews/admin_management/edit_admin_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:asrat/controllers/auth_controller.dart';

class AdminProfilePage extends StatelessWidget {
  const AdminProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController auth = Get.find<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // appBar: AppBar(title: const Text('Admin Profile'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// ================= AVATAR =================
            Obx(() {
              final avatar = auth.getAvatarImage();
              return CircleAvatar(
                radius: 55,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: avatar is MemoryImage ? avatar : null,
                child:
                    avatar is MemoryImage
                        ? null
                        : const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ),
              );
            }),

            const SizedBox(height: 16),

            /// ================= NAME =================
            Obx(
              () => Text(
                auth.userName.isNotEmpty ? auth.userName : 'Admin',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 6),

            /// ================= EMAIL =================
            Obx(
              () => Text(
                auth.userEmail.isNotEmpty ? auth.userEmail : 'admin@email.com',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ),

            const SizedBox(height: 10),

            /// ================= ROLE BADGE =================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'ADMIN',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// ================= INFO CARDS =================
            _infoTile(
              icon: Icons.security,
              title: 'Role',
              value: auth.userRole.toUpperCase(),
              isDark: isDark,
            ),

            _infoTile(
              icon: Icons.verified_user,
              title: 'Account Status',
              value: 'Active',
              isDark: isDark,
            ),

            _infoTile(
              icon: Icons.settings,
              title: 'Permissions',
              value: 'Full Access',
              isDark: isDark,
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
              onPressed: () => Get.to(() => const EditAdminProfilePage()),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              icon: const Icon(Icons.lock),
              label: const Text('Change Password'),
              onPressed: () => Get.to(() => const ChangePasswordPage()),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// ================= REUSABLE TILE =================
  Widget _infoTile({
    required IconData icon,
    required String title,
    required String value,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.redAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(value, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
