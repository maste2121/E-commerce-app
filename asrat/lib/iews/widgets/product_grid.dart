import 'package:asrat/controllers/product_controller.dart';
import 'package:asrat/iews/widgets/product_card.dart';
import 'package:asrat/iews/widgets/product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductGrid extends StatelessWidget {
  ProductGrid({super.key});
  final ProductController controller = Get.put(ProductController());

  @override
  Widget build(BuildContext context) {
    // ✅ Fetch products only once when widget is first displayed
    if (controller.products.isEmpty) {
      controller.fetchProducts();
    }

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.products.isEmpty) {
        return const Center(child: Text('No products available'));
      }

      // ✅ Responsive grid layout
      final screenWidth = MediaQuery.of(context).size.width;
      int crossAxisCount;

      if (screenWidth < 600) {
        crossAxisCount = 2; // phones
      } else if (screenWidth < 900) {
        crossAxisCount = 3; // tablets
      } else {
        crossAxisCount = 4; // desktops or large screens
      }

      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: controller.products.length,
        itemBuilder: (context, index) {
          final product = controller.products[index];
          return GestureDetector(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ProductDetailsScreen(product: product),
                  ),
                ),
            child: ProductCard(product: product),
          );
        },
      );
    });
  }
}
