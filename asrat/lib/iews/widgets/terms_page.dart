import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:asrat/utlits/app_textstyle.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

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
          'Terms & Conditions',
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
                '1. Acceptance of Terms',
                style: AppTextstyle.withColor(
                  AppTextstyle.h3,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'By using our e-commerce platform, you agree to comply with these Terms & Conditions. '
                'If you do not agree, please do not use our services.',
                style: AppTextstyle.withColor(
                  AppTextstyle.bodymedium,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                '2. Account Responsibilities',
                style: AppTextstyle.withColor(
                  AppTextstyle.h3,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '- You are responsible for maintaining the confidentiality of your account credentials.\n'
                '- You must provide accurate and up-to-date information.\n'
                '- Unauthorized access or misuse of accounts is prohibited.',
                style: AppTextstyle.withColor(
                  AppTextstyle.bodymedium,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                '3. Orders & Payments',
                style: AppTextstyle.withColor(
                  AppTextstyle.h3,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '- All orders are subject to availability and confirmation.\n'
                '- Prices are subject to change without notice.\n'
                '- Payment processing is handled securely via trusted third parties.',
                style: AppTextstyle.withColor(
                  AppTextstyle.bodymedium,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                '4. Shipping & Delivery',
                style: AppTextstyle.withColor(
                  AppTextstyle.h3,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '- Delivery times are estimated and may vary.\n'
                '- Risk of loss transfers upon delivery.\n'
                '- We are not liable for delays caused by delivery partners or unforeseen events.',
                style: AppTextstyle.withColor(
                  AppTextstyle.bodymedium,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                '5. Returns & Refunds',
                style: AppTextstyle.withColor(
                  AppTextstyle.h3,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '- Returns must comply with our return policy.\n'
                '- Refunds will be issued according to the payment method used.\n'
                '- Damaged or defective items must be reported within the specified period.',
                style: AppTextstyle.withColor(
                  AppTextstyle.bodymedium,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                '6. Intellectual Property',
                style: AppTextstyle.withColor(
                  AppTextstyle.h3,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'All content, logos, images, and trademarks are the property of our platform or our partners. '
                'You may not copy, distribute, or use them without permission.',
                style: AppTextstyle.withColor(
                  AppTextstyle.bodymedium,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                '7. Limitation of Liability',
                style: AppTextstyle.withColor(
                  AppTextstyle.h3,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We are not liable for any indirect, incidental, or consequential damages arising from the use of our platform. '
                'Our liability is limited to the maximum extent permitted by law.',
                style: AppTextstyle.withColor(
                  AppTextstyle.bodymedium,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                '8. Changes to Terms',
                style: AppTextstyle.withColor(
                  AppTextstyle.h3,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We may update these Terms & Conditions periodically. Changes will be posted in this app, '
                'and the revised date will appear at the top of the page.',
                style: AppTextstyle.withColor(
                  AppTextstyle.bodymedium,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                '9. Contact Us',
                style: AppTextstyle.withColor(
                  AppTextstyle.h3,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'For questions about these Terms & Conditions, please contact us at support@yourecommerceapp.com.',
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
