import 'package:asrat/controllers/product_controller.dart';
import 'package:asrat/models/product.dart';
import 'package:asrat/utlits/app_textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WishlistScreen extends StatelessWidget {
  WishlistScreen({super.key});
  final ProductController controller = Get.put(ProductController());

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ FIX: Delay the call until after the first frame (avoids Obx rebuild conflict)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchProducts();
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'My WishList',
          style: AppTextstyle.withColor(
            AppTextstyle.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.search,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.products.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final favoriteProducts =
            controller.products.where((p) => p.isFavorite).toList();

        if (favoriteProducts.isEmpty) {
          return Center(
            child: Text(
              'No items in your wishlist',
              style: AppTextstyle.withColor(
                AppTextstyle.bodymedium,
                isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildSummarySection(context, favoriteProducts),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      _buildWishListItem(context, favoriteProducts[index]),
                  childCount: favoriteProducts.length,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSummarySection(
    BuildContext context,
    List<Product> favoriteProducts,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850]! : Colors.grey[100]!,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${favoriteProducts.length} items in your wishlist',
            style: AppTextstyle.withColor(
              AppTextstyle.h2,
              Theme.of(context).textTheme.bodyLarge!.color!,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              for (var product in favoriteProducts) {
                controller.addProduct(product);
              }
              Get.snackbar(
                'Cart',
                'All items added to cart',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Add All to Cart',
              style: AppTextstyle.withColor(
                AppTextstyle.bodymedium,
                Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWishListItem(BuildContext context, Product product) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget buildProductImage(String path) {
      if (path.startsWith('http')) {
        return Image.network(
          path,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 50, color: Colors.grey),
        );
      } else {
        return Image.asset(
          path.replaceAll(r'\', '/'),
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 50, color: Colors.grey),
        );
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(12),
            ),
            child: buildProductImage(product.imagUrl),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTextstyle.withColor(
                      AppTextstyle.bodylarge,
                      Theme.of(context).textTheme.bodyLarge!.color!,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.category,
                    style: AppTextstyle.withColor(
                      AppTextstyle.bodysmall,
                      isDark ? Colors.grey[400]! : Colors.grey[600]!,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${product.price.toStringAsFixed(2)} birr',
                        style: AppTextstyle.withColor(
                          AppTextstyle.h3,
                          Theme.of(context).textTheme.bodyLarge!.color!,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              controller.addProduct(product);
                              Get.snackbar(
                                'Cart',
                                '${product.name} added',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            },
                            icon: Icon(
                              Icons.shopping_cart_outlined,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              final updated = Product(
                                id: product.id,
                                name: product.name,
                                category: product.category,
                                price: product.price,
                                oldPrice: product.oldPrice,
                                imagUrl: product.imagUrl,
                                description: product.description,
                                isFavorite: false,
                              );
                              controller.updateProduct(updated);
                            },
                            icon: Icon(
                              Icons.delete_outlined,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
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
  }
}
