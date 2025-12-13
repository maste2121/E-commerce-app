import 'package:asrat/controllers/auth_controller.dart';
import 'package:asrat/controllers/theme_controller.dart';
import 'package:asrat/iews/widgets/all_product_screen.dart';
import 'package:asrat/iews/widgets/cart_screen.dart';
import 'package:asrat/iews/widgets/category_chips.dart';
import 'package:asrat/iews/widgets/custom_search_bar.dart';
import 'package:asrat/iews/widgets/home_controller.dart';
import 'package:asrat/iews/widgets/notification_schreen.dart';
import 'package:asrat/iews/widgets/product_grid.dart';
import 'package:asrat/iews/widgets/sale_banner.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final AuthController auth = Get.find<AuthController>();
    final HomeController homeController = Get.put(HomeController());
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Obx(() {
                    // Dynamic user avatar
                    final avatarImage = auth.getAvatarImage();
                    return CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.grey[300],
                      backgroundImage:
                          avatarImage is MemoryImage ? avatarImage : null,
                      child:
                          avatarImage is MemoryImage
                              ? null
                              : const Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.white70,
                              ),
                    );
                  }),
                  const SizedBox(width: 12),
                  Obx(() {
                    // Dynamic user name
                    final userName =
                        auth.userName.isNotEmpty ? auth.userName : 'Guest';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello $userName',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _getGreeting(),
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  }),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Get.to(() => NotificationScreen()),
                    icon: const Icon(Icons.notifications_outlined),
                  ),
                  IconButton(
                    onPressed: () => Get.to(() => CartScreen()),
                    icon: const Icon(Icons.shopping_bag_outlined),
                  ),
                  GetBuilder<ThemeController>(
                    builder:
                        (controller) => IconButton(
                          onPressed: () => controller.toggleMode(),
                          icon: Icon(
                            controller.isDarkMode
                                ? Icons.light_mode
                                : Icons.dark_mode,
                          ),
                        ),
                  ),
                ],
              ),
            ),
            CustomSearchBar(),
            const CategoryChips(),
            const SaleBanner(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Popular Products',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () => Get.to(() => AllProductScreen()),
                    child: Text(
                      'See All',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: ProductGrid()),
          ],
        ),
      ),
    );
  }
}
