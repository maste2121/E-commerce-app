import 'package:asrat/models/product.dart';
import 'package:asrat/utlits/app_textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/product_controller.dart';

class CartScreen extends StatelessWidget {
  CartScreen({super.key});
  final ProductController controller = Get.put(ProductController());

  // Track product quantities
  final RxMap<int, int> quantities = <int, int>{}.obs;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Fetch products on screen load
    controller.fetchProducts();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios),
          color: isDark ? Colors.white : Colors.black,
        ),
        title: Text(
          'My Cart',
          style: AppTextstyle.withColor(
            AppTextstyle.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.products.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final cartProducts = controller.products;

        // Initialize quantities
        for (var product in cartProducts) {
          quantities.putIfAbsent(product.id, () => 1);
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: cartProducts.length,
                itemBuilder:
                    (context, index) =>
                        _buildCartItem(context, cartProducts[index]),
              ),
            ),
            _buildCartSummary(context, cartProducts),
          ],
        );
      }),
    );
  }

  Widget _buildCartItem(BuildContext context, Product product) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget buildProductImage(String path) {
      if (path.startsWith('http')) {
        return Image.network(
          path,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 50, color: Colors.grey),
        );
      } else {
        return Image.asset(
          path.replaceAll(r'\', '/'),
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 50, color: Colors.grey),
        );
      }
    }

    return Obx(() {
      final qty = quantities[product.id] ?? 1;

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: buildProductImage(product.imagUrl),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: AppTextstyle.withColor(
                              AppTextstyle.bodylarge,
                              Theme.of(context).textTheme.bodyLarge!.color!,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // Delete from controller + quantities
                            controller.deleteProduct(product.id);
                            quantities.remove(product.id);
                          },
                          icon: Icon(
                            Icons.delete_outlined,
                            color: Colors.red[400],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(product.price * qty).toStringAsFixed(2)} birr',
                          style: AppTextstyle.withColor(
                            AppTextstyle.h3,
                            Theme.of(context).primaryColor,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (qty > 1) quantities[product.id] = qty - 1;
                              },
                              icon: Icon(
                                Icons.remove,
                                size: 20,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            Text(
                              '$qty',
                              style: AppTextstyle.withColor(
                                AppTextstyle.bodylarge,
                                Theme.of(context).primaryColor,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                quantities[product.id] = qty + 1;
                              },
                              icon: Icon(
                                Icons.add,
                                size: 20,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCartSummary(BuildContext context, List<Product> cartProducts) {
    return Obx(() {
      final total = cartProducts.fold<double>(
        0,
        (sum, item) => sum + (item.price * (quantities[item.id] ?? 1)),
      );

      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total (${cartProducts.length} items)',
                  style: AppTextstyle.withColor(
                    AppTextstyle.bodymedium,
                    Theme.of(context).textTheme.bodyLarge!.color!,
                  ),
                ),
                Text(
                  '${total.toStringAsFixed(2)} birr',
                  style: AppTextstyle.withColor(
                    AppTextstyle.h2,
                    Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Checkout logic
                  Get.snackbar(
                    'Checkout',
                    'Proceeding to checkout...',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Proceed to Checkout',
                  style: AppTextstyle.withColor(
                    AppTextstyle.buttonmedium,
                    Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
