import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:asrat/utlits/app_textstyle.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

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
        title: Text(
          'Privacy Policy',
          style: AppTextstyle.withColor(
            AppTextstyle.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Last Updated: October 2025',
                style: AppTextstyle.withColor(
                  AppTextstyle.bodysmall,
                  isDark ? Colors.grey[400]! : Colors.grey[600]!,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '1. Introduction',
                style: AppTextstyle.withColor(
                  AppTextstyle.h3,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Welcome to our e-commerce platform. Your privacy is important to us. '
                'This Privacy Policy explains how we collect, use, and protect your personal information '
                'when you use our app or website.',
                style: AppTextstyle.withColor(
                  AppTextstyle.bodymedium,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                '2. Information We Collect',
                style: AppTextstyle.withColor(
                  AppTextstyle.h3,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '- Personal details (name, email, phone number, and shipping address)\n'
                '- Payment information (processed securely through trusted third parties)\n'
                '- Device and usage data (e.g., app version, IP address, and activity logs)',
                style: AppTextstyle.withColor(
                  AppTextstyle.bodymedium,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                '3. How We Use Your Information',
                style: AppTextstyle.withColor(
                  AppTextstyle.h3,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '- To process and deliver your orders\n'
                '- To communicate about your account or purchases\n'
                '- To provide customer support and improve user experience\n'
                '- To send promotional offers (only if you consent)',
                style: AppTextstyle.withColor(
                  AppTextstyle.bodymedium,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                '4. Data Protection & Security',
                style: AppTextstyle.withColor(
                  AppTextstyle.h3,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We use strong encryption and secure servers to protect your personal data. '
                'Access to user information is restricted to authorized employees only.',
                style: AppTextstyle.withColor(
                  AppTextstyle.bodymedium,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                '5. Sharing Your Information',
                style: AppTextstyle.withColor(
                  AppTextstyle.h3,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We do not sell or rent your information. However, we may share limited data with:\n'
                '- Payment gateways (for processing orders)\n'
                '- Delivery partners (to fulfill shipments)\n'
                '- Legal authorities (if required by law)',
                style: AppTextstyle.withColor(
                  AppTextstyle.bodymedium,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                '6. Your Rights',
                style: AppTextstyle.withColor(
                  AppTextstyle.h3,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You can:\n'
                '- Access or update your profile information\n'
                '- Request data deletion\n'
                '- Opt out of marketing communications at any time',
                style: AppTextstyle.withColor(
                  AppTextstyle.bodymedium,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                '7. Changes to This Policy',
                style: AppTextstyle.withColor(
                  AppTextstyle.h3,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We may update this Privacy Policy periodically. Updates will be posted in this app, '
                'and the revised date will appear at the top of the page.',
                style: AppTextstyle.withColor(
                  AppTextstyle.bodymedium,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                '8. Contact Us',
                style: AppTextstyle.withColor(
                  AppTextstyle.h3,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'If you have any questions or concerns about our privacy practices, '
                'please contact us at support@yourecommerceapp.com.',
                style: AppTextstyle.withColor(
                  AppTextstyle.bodymedium,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
