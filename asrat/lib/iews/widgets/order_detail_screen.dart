import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:asrat/utlits/app_textstyle.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

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
          'Order Details',
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
              'Order ID: $orderId',
              style: AppTextstyle.withColor(
                AppTextstyle.h3,
                isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Status: Shipped',
              style: AppTextstyle.withColor(
                AppTextstyle.bodymedium,
                isDark ? Colors.grey[300]! : Colors.grey[800]!,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Items:',
              style: AppTextstyle.withColor(
                AppTextstyle.h3,
                isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: Image.asset(
                      'assets/images/product1.jpg',
                      width: 50,
                      height: 50,
                    ),
                    title: Text('Product 1', style: AppTextstyle.bodymedium),
                    subtitle: Text('Qty: 2', style: AppTextstyle.bodysmall),
                    trailing: Text('\$40', style: AppTextstyle.bodymedium),
                  ),
                  ListTile(
                    leading: Image.asset(
                      'assets/images/product2.jpg',
                      width: 50,
                      height: 50,
                    ),
                    title: Text('Product 2', style: AppTextstyle.bodymedium),
                    subtitle: Text('Qty: 1', style: AppTextstyle.bodysmall),
                    trailing: Text('\$25', style: AppTextstyle.bodymedium),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Total: \$105',
              style: AppTextstyle.withColor(
                AppTextstyle.h3,
                Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
