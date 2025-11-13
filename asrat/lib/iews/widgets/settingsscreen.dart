import 'package:asrat/iews/widgets/privacy_policy_page.dart';
import 'package:asrat/iews/widgets/terms_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:asrat/controllers/theme_controller.dart';
import 'package:asrat/utlits/app_textstyle.dart';

class Settingsscreen extends StatelessWidget {
  const Settingsscreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Register the ThemeController
    Get.put(ThemeController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        title: Text(
          'Settings',
          style: AppTextstyle.withColor(
            AppTextstyle.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(context, 'Appearance', [_buildThemeToggle(context)]),
            _buildSection(context, 'Notifications', [
              _buildSwitchTile(
                context,
                'Push Notifications',
                'Receive push notifications about orders and promotions',
                true, // default value
              ),
              _buildSwitchTile(
                context,
                'Email Notifications',
                'Receive email updates about your orders',
                false, // default value
              ),
            ]),
            _buildSection(context, 'Privacy', [
              _buildNavigationTile(
                context,
                'Privacy policy',
                'View our privacy policy',
                Icons.privacy_tip_outlined,
              ),
              _buildNavigationTile(
                context,
                'Terms of service',
                'Read our terms of service',
                Icons.description_outlined,
              ),
            ]),
            _buildSection(context, 'About', [
              _buildNavigationTile(
                context,
                'App version',
                '1.0.0',
                Icons.info_outline,
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

Widget _buildSection(
  BuildContext context,
  String title,
  List<Widget> children,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        child: Text(
          title,
          style: AppTextstyle.withColor(
            AppTextstyle.h3,
            isDark ? Colors.grey[400]! : Colors.grey[600]!,
          ),
        ),
      ),
      ...children,
    ],
  );
}

Widget _buildThemeToggle(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return GetBuilder<ThemeController>(
    builder:
        (controller) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              controller.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(
              'Dark Mode',
              style: AppTextstyle.withColor(
                AppTextstyle.bodymedium,
                Theme.of(context).textTheme.bodyLarge!.color!,
              ),
            ),
            trailing: Switch.adaptive(
              value: controller.isDarkMode,
              onChanged: (value) => controller.toggleMode(),
              activeColor: Theme.of(context).primaryColor,
            ),
          ),
        ),
  );
}

Widget _buildSwitchTile(
  BuildContext context,
  String title,
  String subtitle,
  bool initialValue,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  bool value = initialValue;

  return StatefulBuilder(
    builder:
        (context, setState) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            leading: const Icon(Icons.notifications_active),
            title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
            subtitle: Text(subtitle),
            trailing: Switch.adaptive(
              value: value,
              onChanged: (newValue) {
                setState(() => value = newValue);
              },
              activeColor: Theme.of(context).primaryColor,
            ),
          ),
        ),
  );
}

Widget _buildNavigationTile(
  BuildContext context,
  String title,
  String subtitle,
  IconData icon,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(
        title,
        style: AppTextstyle.withColor(
          AppTextstyle.bodymedium,
          Theme.of(context).textTheme.bodyLarge!.color!,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextstyle.withColor(
          AppTextstyle.bodysmall,
          isDark ? Colors.grey[400]! : Colors.grey[600]!,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: () {
        if (title == 'Privacy policy') {
          Get.to(() => const PrivacyPolicyPage());
        } else if (title == 'Terms of service') {
          Get.to(() => const TermsPage());
        }
      },
    ),
  );
}
