import 'package:asrat/controllers/navigation_controller.dart';
import 'package:asrat/controllers/theme_controller.dart';
import 'package:asrat/iews/widgets/account_screen.dart';
import 'package:asrat/iews/widgets/custom_botton_nav_bar.dart';
import 'package:asrat/iews/widgets/home_screen.dart';
import 'package:asrat/iews/widgets/shopping_screen.dart';
import 'package:asrat/iews/widgets/wishlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:get/state_manager.dart';
import 'package:get/utils.dart';

class MainShreen extends StatelessWidget {
  const MainShreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController navigationController = Get.put(
      NavigationController(),
    );
    return GetBuilder<ThemeController>(
      builder:
          (themeController) => Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: AnimatedSwitcher(
              duration: Duration(milliseconds: 200),
              child: Obx(
                () => IndexedStack(
                  key: ValueKey(navigationController.currentIndex.value),
                  index: navigationController.currentIndex.value,
                  children: [
                    HomeScreen(),
                    ShoppingScreen(),
                    WishlistScreen(),
                    AccountScreen(),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: const CustomBottonNavBar(),
          ),
    );
  }
}
