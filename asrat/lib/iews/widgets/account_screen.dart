// ignore_for_file: deprecated_member_use

import 'package:asrat/controllers/auth_controller.dart';
import 'package:asrat/iews/widgets/settingsscreen.dart';
import 'package:asrat/iews/widgets/sign_up_screen.dart';
import 'package:asrat/utlits/app_textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileSection(context),
            const SizedBox(height: 24),
            _buildMenuSection(context),
          ],
        ),
      ),
    );
  }
}

Widget _buildProfileSection(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: isDark ? Colors.grey[850] : Colors.grey[100],
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
    ),
    child: Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage('assets/images/im5.jpg'),
        ),
        const SizedBox(height: 16),
        Text(
          'Mastewal Kihnet',
          style: AppTextstyle.withColor(
            AppTextstyle.h2,
            Theme.of(context).textTheme.bodyLarge!.color!,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'mastewalkihnet@gmail.com',
          style: AppTextstyle.withColor(
            AppTextstyle.bodymedium,
            isDark ? Colors.grey[400]! : Colors.grey[600]!,
          ),
        ),
        const SizedBox(height: 20),
        OutlinedButton(
          onPressed: () {},
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
    {'icon': Icons.location_on_outlined, 'title': 'Shipping Adress'},
    {'icon': Icons.help_outlined, 'title': 'Helps Centers'},
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
                  } else if (item['title'] == 'Shipping Adress') {
                  } else if (item['title'] == 'Helps Centers') {}
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
      contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
            style: AppTextstyle.withColor(
              AppTextstyle.bodymedium,
              isDark ? Colors.grey[400]! : Colors.grey[600]!,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(
                      color: isDark ? Colors.grey[700]! : Colors.grey[100]!,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: AppTextstyle.withColor(
                      AppTextstyle.buttonmedium,
                      Theme.of(context).textTheme.bodyLarge!.color!,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final AuthController authController =
                        Get.find<AuthController>();
                    authController.logout();
                    Get.offAll(() => SignUpScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(
                      color: isDark ? Colors.grey[700]! : Colors.grey[100]!,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Logout',
                    style: AppTextstyle.withColor(
                      AppTextstyle.buttonmedium,
                      Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
