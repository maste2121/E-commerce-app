import 'dart:io';
import 'package:asrat/controllers/product_controller.dart';
import 'package:asrat/models/product.dart';
import 'package:asrat/utlits/app_textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
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

    return Obx(() {
      // Use reactive products list to reflect isFavorite changes
      final currentProduct = controller.products.firstWhere(
        (p) => p.id == product.id,
        orElse: () => product,
      );

      return Container(
        constraints: BoxConstraints(maxWidth: screenWidth * 0.9),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color:
                  isDark
                      ? Colors.black.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: buildProductImage(currentProduct.imagUrl),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: IconButton(
                      icon: Icon(
                        currentProduct.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border_outlined,
                        color:
                            currentProduct.isFavorite
                                ? Theme.of(context).primaryColor
                                : isDark
                                ? Colors.grey[400]
                                : Colors.grey,
                      ),
                      onPressed: () {
                        controller.toggleFavorite(currentProduct);
                      },
                    ),
                  ),
                  if (currentProduct.oldPrice != null)
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${calculateDiscount(currentProduct.price, currentProduct.oldPrice!)}% off',
                          style: AppTextstyle.withColor(
                            AppTextstyle.withWeight(
                              AppTextstyle.bodysmall,
                              FontWeight.bold,
                            ),
                            Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.02),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentProduct.name,
                      style: AppTextstyle.withColor(
                        AppTextstyle.withWeight(
                          AppTextstyle.h3,
                          FontWeight.bold,
                        ),
                        Theme.of(context).textTheme.bodyLarge!.color!,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: screenWidth * 0.01),
                    Text(
                      currentProduct.category,
                      style: AppTextstyle.withColor(
                        AppTextstyle.bodylarge,
                        isDark ? Colors.grey[400]! : Colors.grey[600]!,
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.01),
                    Text(
                      '${currentProduct.price.toStringAsFixed(2)} birr',
                      style: AppTextstyle.withColor(
                        AppTextstyle.withWeight(
                          AppTextstyle.bodylarge,
                          FontWeight.bold,
                        ),
                        Theme.of(context).textTheme.bodyLarge!.color!,
                      ),
                    ),
                    if (currentProduct.oldPrice != null) ...[
                      SizedBox(height: screenWidth * 0.01),
                      Text(
                        '${currentProduct.oldPrice!.toStringAsFixed(2)} birr',
                        style: AppTextstyle.withColor(
                          AppTextstyle.bodysmall,
                          isDark ? Colors.grey[400]! : Colors.grey[600]!,
                        ).copyWith(decoration: TextDecoration.lineThrough),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  int calculateDiscount(double currentPrice, double oldPrice) {
    return (((oldPrice - currentPrice) / oldPrice) * 100).round();
  }
}
