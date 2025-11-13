import 'dart:io';
import 'package:asrat/controllers/product_controller.dart';
import 'package:asrat/iews/widgets/order_form_dialog.dart';
import 'package:asrat/iews/widgets/size_selector.dart';
import 'package:asrat/models/product.dart';
import 'package:asrat/utlits/app_textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final screensize = MediaQuery.of(context).size;
    final screenheight = screensize.height;
    final screenwidth = screensize.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ProductController controller = Get.find<ProductController>();
    Widget buildProductImage(String path) {
      if (path.startsWith('http')) {
        return Image.network(
          path,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
          },
        );
      } else if (path.startsWith('/') || path.contains(':\\')) {
        return Image.file(
          File(path),
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
          },
        );
      } else {
        return Image.asset(
          path.replaceAll(r'\', '/'),
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
          },
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back),
          color: isDark ? Colors.white : Colors.black,
        ),
        title: Text(
          'Details',
          style: AppTextstyle.withColor(
            AppTextstyle.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed:
                () => _ShareProduct(context, product.name, product.description),
            icon: Icon(
              Icons.share,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
      body: Obx(() {
        // Make currentProduct reactive
        final currentProduct = controller.products.firstWhere(
          (p) => p.id == product.id,
          orElse: () => product,
        );

        return SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: buildProductImage(currentProduct.imagUrl),
                  ),
                  Positioned(
                    top: 8,
                    child: IconButton(
                      onPressed: () {
                        controller.toggleFavorite(currentProduct);
                      },
                      icon: Icon(
                        currentProduct.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color:
                            currentProduct.isFavorite
                                ? Theme.of(context).primaryColor
                                : (isDark ? Colors.white : Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(screenwidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            currentProduct.name,
                            style: AppTextstyle.withColor(
                              AppTextstyle.h2,
                              Theme.of(
                                context,
                              ).textTheme.headlineMedium!.color!,
                            ),
                          ),
                        ),
                        Text(
                          '${currentProduct.price.toStringAsFixed(2)} birr',
                          style: AppTextstyle.withColor(
                            AppTextstyle.h2,
                            Theme.of(context).textTheme.headlineMedium!.color!,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      currentProduct.category,
                      style: AppTextstyle.withColor(
                        AppTextstyle.bodymedium,
                        isDark ? Colors.grey[400]! : Colors.grey[600]!,
                      ),
                    ),
                    SizedBox(height: screenwidth * 0.02),
                    Text(
                      'Select size',
                      style: AppTextstyle.withColor(
                        AppTextstyle.labelmedium,
                        Theme.of(context).textTheme.bodyLarge!.color!,
                      ),
                    ),
                    SizedBox(height: screenwidth * 0.02),
                    const SizeSelector(),
                    SizedBox(height: screenwidth * 0.02),
                    Text(
                      'Description',
                      style: AppTextstyle.withColor(
                        AppTextstyle.labelmedium,
                        Theme.of(context).textTheme.bodyLarge!.color!,
                      ),
                    ),
                    SizedBox(height: screenwidth * 0.01),
                    Text(
                      currentProduct.description,
                      style: AppTextstyle.withColor(
                        AppTextstyle.bodysmall,
                        isDark ? Colors.grey[400]! : Colors.grey[600]!,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(screenwidth * 0.04),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: screenheight * 0.02,
                    ),
                    side: BorderSide(
                      color: isDark ? Colors.white70 : Colors.black12,
                    ),
                  ),
                  onPressed: () {},
                  child: Text(
                    'Add to Cart',
                    style: AppTextstyle.withColor(
                      AppTextstyle.buttonmedium,
                      Theme.of(context).textTheme.bodyLarge!.color!,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenwidth * 0.04),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: screenheight * 0.02,
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => OrderFormDialog(product: product),
                    );
                  },
                  child: Text(
                    'Buy Now',
                    style: AppTextstyle.withColor(
                      AppTextstyle.buttonmedium,
                      Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _ShareProduct(
    BuildContext context,
    String productName,
    String description,
  ) async {
    final box = context.findRenderObject() as RenderBox?;
    const String shopLink = 'https://website.com/product/t-shirt';
    final String shareMessage = '$description\n\nShop now at $shopLink';

    try {
      final ShareResult result = await Share.share(
        shareMessage,
        subject: productName,
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
      if (result.status == ShareResultStatus.success) {
        debugPrint('Thank you for sharing!');
      }
    } catch (e) {
      debugPrint('Error sharing: $e');
    }
  }
}
