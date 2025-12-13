import 'package:asrat/controllers/auth_controller.dart';
import 'package:asrat/iews/widgets/settingsscreen.dart';
import 'package:asrat/iews/widgets/sign_up_screen.dart';
import 'package:asrat/utlits/app_textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'edit_profile_screen.dart';
import 'my_orders_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final AuthController auth = Get.find<AuthController>();
  final RxBool _isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    _isLoading.value = true;
    await auth.fetchCurrentUser();
    _isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Account',
          style: AppTextstyle.withColor(
            AppTextstyle.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Get.to(() => const Settingsscreen()),
            icon: Icon(
              Icons.settings_outlined,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (_isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final userName = auth.userName;
        final userEmail = auth.userEmail;

        return SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileSection(context, userName, userEmail),
              const SizedBox(height: 24),
              _buildMenuSection(context),
            ],
          ),
        );
      }),
    );
  }
}

Widget _buildProfileSection(
  BuildContext context,
  String userName,
  String userEmail,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final auth = Get.find<AuthController>();

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: isDark ? Colors.grey[850] : Colors.grey[100],
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
    ),
    child: Column(
      children: [
        Obx(() {
          return Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage:
                    auth.user?['avatarPath'] != null
                        ? FileImage(File(auth.user!['avatarPath']))
                            as ImageProvider
                        : const AssetImage('assets/images/im5.jpg'),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: () async {
                    final picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 80,
                    );
                    if (image != null) {
                      auth.updateUser({
                        ...?auth.user,
                        'avatarPath': image.path,
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
        const SizedBox(height: 16),
        Text(
          userName.isNotEmpty ? userName : 'No Name',
          style: AppTextstyle.withColor(
            AppTextstyle.h2,
            Theme.of(context).textTheme.bodyLarge!.color!,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          userEmail.isNotEmpty ? userEmail : 'No Email',
          style: AppTextstyle.withColor(
            AppTextstyle.bodymedium,
            isDark ? Colors.grey[400]! : Colors.grey[600]!,
          ),
        ),
        const SizedBox(height: 20),
        OutlinedButton(
          onPressed: () => Get.to(() => const EditProfileScreen()),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            side: BorderSide(color: isDark ? Colors.white70 : Colors.black12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Edit Profile',
            style: AppTextstyle.withColor(
              AppTextstyle.buttonmedium,
              Theme.of(context).textTheme.bodyLarge!.color!,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildMenuSection(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  final menuItems = [
    {'icon': Icons.shopping_bag_outlined, 'title': 'My Orders'},
    {'icon': Icons.location_on_outlined, 'title': 'Shipping Address'},
    {'icon': Icons.help_outlined, 'title': 'Help Center'},
    {'icon': Icons.logout_outlined, 'title': 'LogOut'},
  ];

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      children:
          menuItems.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color:
                        isDark
                            ? Colors.black.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                leading: Icon(
                  item['icon'] as IconData,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text(
                  item['title'] as String,
                  style: AppTextstyle.withColor(
                    AppTextstyle.bodymedium,
                    Theme.of(context).textTheme.bodyLarge!.color!,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: isDark ? Colors.grey[400]! : Colors.grey[600]!,
                ),
                onTap: () {
                  if (item['title'] == 'LogOut') {
                    _showLogoutDialog(context);
                  } else if (item['title'] == 'My Orders') {
                    Get.to(() => const MyOrdersScreen());
                  }
                },
              ),
            );
          }).toList(),
    ),
  );
}

void _showLogoutDialog(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  Get.dialog(
    AlertDialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.logout_rounded,
              color: Theme.of(context).primaryColor,
              size: 32,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  child: const Text("Cancel"),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final authController = Get.find<AuthController>();
                    authController.logout();
                    Get.offAll(() => SignUpScreen());
                  },
                  child: const Text("Logout"),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
