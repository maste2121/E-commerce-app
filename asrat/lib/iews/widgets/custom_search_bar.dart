import 'package:asrat/iews/widgets/home_controller.dart';
import 'package:asrat/utlits/app_textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final HomeController homeController = Get.put(HomeController());
    return Padding(
      padding: EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) {
          homeController.searchQuery.value = value;
        },
        style: AppTextstyle.withColor(
          AppTextstyle.buttonmedium,
          Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
        ),
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: AppTextstyle.withColor(
            AppTextstyle.buttonmedium,
            isDark ? Colors.grey[400]! : Colors.grey[600]!,
          ),
          prefix: Icon(
            Icons.search,
            color: isDark ? Colors.grey[400]! : Colors.grey[600]!,
          ),
          suffix: Icon(
            Icons.tune,
            color: isDark ? Colors.grey[400]! : Colors.grey[600]!,
          ),
          filled: true,
          fillColor: isDark ? Colors.grey[800]! : Colors.grey[100]!,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark ? Colors.grey[800]! : Colors.grey[100]!,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}
