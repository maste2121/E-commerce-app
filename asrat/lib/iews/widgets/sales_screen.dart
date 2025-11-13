import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:asrat/utlits/app_textstyle.dart';

class SaleScreen extends StatelessWidget {
  const SaleScreen({super.key});

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
          'Current Sale',
          style: AppTextstyle.withColor(
            AppTextstyle.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Up to 50% Off!',
              style: AppTextstyle.withColor(
                AppTextstyle.h2,
                Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Check out these products currently on sale:',
              style: AppTextstyle.withColor(
                AppTextstyle.bodymedium,
                isDark ? Colors.grey[400]! : Colors.grey[700]!,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  Card(
                    elevation: 2,
                    child: ListTile(
                      leading: Image.asset(
                        'assets/images/product1.jpg',
                        width: 50,
                        height: 50,
                      ),
                      title: Text('Product 1', style: AppTextstyle.bodymedium),
                      subtitle: Text(
                        'Now: \$20 (was \$40)',
                        style: AppTextstyle.bodysmall,
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Navigate to product detail page
                      },
                    ),
                  ),
                  Card(
                    elevation: 2,
                    child: ListTile(
                      leading: Image.asset(
                        'assets/images/product2.jpg',
                        width: 50,
                        height: 50,
                      ),
                      title: Text('Product 2', style: AppTextstyle.bodymedium),
                      subtitle: Text(
                        'Now: \$12 (was \$25)',
                        style: AppTextstyle.bodysmall,
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Navigate to product detail page
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
