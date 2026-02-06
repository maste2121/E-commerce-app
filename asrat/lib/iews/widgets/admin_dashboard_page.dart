import 'dart:io';
import 'package:asrat/controllers/auth_controller.dart';
import 'package:asrat/controllers/order_controller.dart';
import 'package:asrat/controllers/product_controller.dart';
import 'package:asrat/controllers/user_controller.dart';
import 'package:asrat/iews/admin_management/admin_profile_page.dart';
import 'package:asrat/iews/admin_management/orders_management_page.dart';
import 'package:asrat/iews/widgets/notification_schreen.dart';
import 'package:asrat/iews/widgets/signin_screen.dart';
import 'package:asrat/models/product.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:data_table_2/data_table_2.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

// ----------------- Helper Widgets for Design -----------------

// A custom widget for the four statistic cards at the top of each view
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(icon, color: color.withOpacity(0.7)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

// A widget for the modern search bar
class ModernSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;

  const ModernSearchBar({required this.hintText, this.onChanged, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: onChanged,
            ),
          ),
          const SizedBox(width: 10),
          // Placeholder for the "All" dropdown or filter icon
          TextButton(
            onPressed: () {},
            child: const Text('All', style: TextStyle(color: Colors.grey)),
          ),
          const Icon(Icons.tune, color: Colors.grey, size: 20),
        ],
      ),
    );
  }
}

// ----------------- AdminDashboard State -----------------

class _AdminDashboardState extends State<AdminDashboard> {
  final ProductController productController = Get.put(ProductController());
  final AuthController authController = Get.find<AuthController>();
  final UserController userController = Get.put(UserController());
  final OrderController orderController = Get.put(OrderController());
  final RxString currentRole = ''.obs;

  // Updated to include all items from the sidebar in the images
  // 0: Dashboard, 1: Products, 2: Orders, 3: Customers, 4: Inventory, 5: $ Sales
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    final user = GetStorage().read('user');
    currentRole.value = user?['role'] ?? 'admin'; // use real role if exists

    // Initialize data fetching for all necessary pages
    productController.fetchProducts();
    userController.fetchUsers();
  }

  // --- EXISTING LOGIC (RETAINED) ---
  bool canAdd() =>
      currentRole.value == 'admin' || currentRole.value == 'organizer';
  bool canEdit() =>
      currentRole.value == 'admin' || currentRole.value == 'organizer';
  bool canDelete() => currentRole.value == 'admin';

  // ---------------- ADD OR EDIT PRODUCT FORM ----------------
  Future<void> showProductForm({Product? product}) async {
    final isEdit = product != null;
    final nameCtrl = TextEditingController(text: product?.name ?? '');
    final categoryCtrl = TextEditingController(text: product?.category ?? '');
    final priceCtrl = TextEditingController(
      text: product?.price.toString() ?? '',
    );
    final oldPriceCtrl = TextEditingController(
      text: product?.oldPrice?.toString() ?? '',
    );
    final descCtrl = TextEditingController(text: product?.description ?? '');
    final favorite = (product?.isFavorite ?? false).obs;
    File? selectedImage;
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isEdit ? 'Edit Product' : 'Add Product'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: 'Name'),
                        validator:
                            (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Enter name'
                                    : null,
                      ),
                      TextFormField(
                        controller: categoryCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                      ),
                      TextFormField(
                        controller: priceCtrl,
                        decoration: const InputDecoration(labelText: 'Price'),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Enter price';
                          if (double.tryParse(v) == null)
                            return 'Invalid price';
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: oldPriceCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Old Price (optional)',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              final picker = ImagePicker();
                              final pickedFile = await picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (pickedFile != null) {
                                setState(() {
                                  selectedImage = File(pickedFile.path);
                                });
                              }
                            },
                            icon: const Icon(Icons.image),
                            label: const Text('Pick Image'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              selectedImage != null
                                  ? selectedImage!.path.split('/').last
                                  : (product?.imagUrl ?? 'No image selected'),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: descCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                        maxLines: 2,
                      ),
                      Obx(
                        () => SwitchListTile(
                          value: favorite.value,
                          title: const Text('Favorite'),
                          onChanged: (v) => favorite.value = v,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    final newProduct = Product(
                      id: isEdit ? product.id : _generateTempId(),
                      name: nameCtrl.text.trim(),
                      category: categoryCtrl.text.trim(),
                      price: double.parse(priceCtrl.text.trim()),
                      oldPrice:
                          oldPriceCtrl.text.isNotEmpty
                              ? double.parse(oldPriceCtrl.text)
                              : null,
                      imagUrl: selectedImage?.path ?? (product?.imagUrl ?? ''),
                      isFavorite: favorite.value,
                      description: descCtrl.text.trim(),
                    );

                    Navigator.pop(ctx);
                    if (isEdit) {
                      await productController.updateProduct(newProduct);
                    } else {
                      await productController.addProduct(newProduct);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  int _generateTempId() {
    final existing = productController.products.map((p) => p.id).toList();
    final maxId =
        existing.isEmpty ? 0 : existing.reduce((a, b) => a > b ? a : b);
    return maxId + 1;
  }

  Future<void> confirmDelete(Product product) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: const Text('Delete product'),
                content: Text(
                  'Are you sure you want to delete "${product.name}"?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
        ) ??
        false;

    if (confirmed) await productController.deleteProduct(product.id);
  }

  // ----------------- NEW LAYOUT Methods -----------------
  Widget buildDashboardCharts() {
    final now = DateTime.now();
    final List<String> months = ['Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep'];

    // Map month index to total sales
    final Map<int, double> salesPerMonth = {};
    for (int i = 0; i < 6; i++) {
      final monthDate = DateTime(now.year, now.month - 5 + i, 1);
      final monthSales = orderController.orders
          .where((o) {
            final date = DateTime.tryParse(o.orderDate) ?? now;
            return date.month == monthDate.month && date.year == monthDate.year;
          })
          .fold<double>(0, (sum, o) => sum + o.totalPrice);
      salesPerMonth[i] = monthSales;
    }

    // Prepare revenue distribution by product name
    final Map<String, double> revenueByCategory = {};
    for (var order in orderController.orders) {
      final category = order.productName; // or product category if available
      revenueByCategory[category] =
          (revenueByCategory[category] ?? 0) + order.totalPrice;
    }

    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 📊 Sales Trend Bar Chart
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sales Trend (Last 6 Months)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY:
                            salesPerMonth.values.isEmpty
                                ? 100
                                : salesPerMonth.values.reduce(
                                      (a, b) => a > b ? a : b,
                                    ) *
                                    1.2,
                        gridData: FlGridData(
                          show: true,
                          drawHorizontalLine: true,
                          horizontalInterval: 10,
                          getDrawingHorizontalLine:
                              (value) => FlLine(
                                color: Colors.grey.withOpacity(0.2),
                                strokeWidth: 1,
                              ),
                        ),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval: 10,
                              getTitlesWidget:
                                  (value, _) => Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget:
                                  (value, _) => Text(
                                    months[value.toInt() % months.length],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                            ),
                          ),
                        ),
                        barGroups: List.generate(6, (i) {
                          return BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: salesPerMonth[i] ?? 0,
                                color: Colors.blueAccent,
                                width: 18,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6),
                                ),
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY:
                                      salesPerMonth.values.isEmpty
                                          ? 100
                                          : salesPerMonth.values.reduce(
                                                (a, b) => a > b ? a : b,
                                              ) *
                                              1.2,
                                  color: const Color(0xFFE0E0E0),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                      swapAnimationDuration: const Duration(milliseconds: 800),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          // 🥧 Revenue Distribution Pie Chart
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Revenue Distribution',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sections:
                            revenueByCategory.entries.map((entry) {
                              final colors = Colors.primaries;
                              return PieChartSectionData(
                                value: entry.value,
                                title:
                                    '${entry.key}\n${((entry.value / revenueByCategory.values.fold(0, (a, b) => a + b)) * 100).toStringAsFixed(1)}%',
                                color:
                                    colors[revenueByCategory.keys
                                            .toList()
                                            .indexOf(entry.key) %
                                        colors.length],
                                radius: 40,

                                titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardOverview() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Horizontally Scrollable Stat Cards
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                StatCard(
                  title: 'Total Revenue',
                  value: '\$${orderController.totalRevenue.toStringAsFixed(2)}',
                  icon: Icons.monetization_on,
                  color: const Color(0xFF55B865), // Greenish
                ),
                const SizedBox(width: 16),
                StatCard(
                  title: 'Avg Order Value',
                  value: '${orderController.totalOrders}',
                  icon: Icons.receipt,
                  color: const Color(0xFF6B8BF2), // Bluish
                ),
                const SizedBox(width: 16),
                StatCard(
                  title: 'Total Customers',
                  value: '${userController.users.length}',
                  icon: Icons.people,
                  color: const Color(0xFFFF8AD2), // Pinkish
                ),
                const SizedBox(width: 16),
                Obx(
                  () => StatCard(
                    title: 'Total Products',
                    value: '${productController.products.length}',
                    icon: Icons.shopping_bag,
                    color: const Color(0xFFF2A34F), // Orangish
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // ✅ Charts Section
          buildDashboardCharts(),

          const SizedBox(height: 10),

          // ✅ Search Bar
          ModernSearchBar(hintText: 'Search Product'),

          // ✅ Table Section
          const Text(
            'Top Products Table (Simplified)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          Expanded(child: _buildProductTable(limit: 5)),
        ],
      ),
    );
  }

  Widget buildResponsiveProductsHeader({
    required VoidCallback onRefresh,
    required VoidCallback onAddProduct,
    required bool canAdd,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;

        Widget buildButtons() {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (canAdd)
                ElevatedButton.icon(
                  onPressed: onAddProduct,
                  icon: const Icon(
                    Icons.add_shopping_cart,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Add Product',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 3,
                  ),
                ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.grey),
                tooltip: 'Refresh Products',
                onPressed: onRefresh,
              ),
            ],
          );
        }

        // 🟢 Small Screen (Mobile)
        if (width < 500) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Column(
              key: const ValueKey('mobile-layout'),
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Products Overview',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                buildButtons(),
              ],
            ),
          );
        }

        // 🟡 Medium Screen (Tablet)
        if (width < 900) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: SingleChildScrollView(
              key: const ValueKey('tablet-layout'),
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Products Overview',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  buildButtons(),
                ],
              ),
            ),
          );
        }

        // 🔵 Large Screen (Desktop)
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.05, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Row(
            key: const ValueKey('desktop-layout'),
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Products Overview',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              buildButtons(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductOverview() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildResponsiveProductsHeader(
            onRefresh: productController.fetchProducts,
            onAddProduct: showProductForm,
            canAdd: canAdd(),
          ),

          const SizedBox(height: 20),

          // ✅ Horizontally scrollable stat cards
          Obx(() {
            final totalProducts = productController.products.length;
            final outOfStock =
                productController.products.where((p) => p.stock == 0).length;
            final newProducts =
                productController.products
                    .where(
                      (p) =>
                          DateTime.now().difference(p.createdAt).inDays <= 30,
                    )
                    .length;
            final categories =
                productController.products
                    .map((p) => p.category)
                    .toSet()
                    .length;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  StatCard(
                    title: 'Total Products',
                    value: '$totalProducts',
                    icon: Icons.shopping_bag,
                    color: const Color(0xFFF2A34F),
                  ),
                  const SizedBox(width: 16),
                  StatCard(
                    title: 'Out of Stock',
                    value: '$outOfStock',
                    icon: Icons.remove_shopping_cart,
                    color: const Color(0xFFEF5350),
                  ),
                  const SizedBox(width: 16),
                  StatCard(
                    title: 'New Products',
                    value: '$newProducts',
                    icon: Icons.fiber_new,
                    color: const Color(0xFF6B8BF2),
                  ),
                  const SizedBox(width: 16),
                  StatCard(
                    title: 'Categories',
                    value: '$categories',
                    icon: Icons.category,
                    color: const Color(0xFF55B865),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 10),
          ModernSearchBar(hintText: 'Search Product'),

          // Product List/Table (scrollable in _buildProductTable)
          Expanded(child: _buildProductTable(limit: 100)),
        ],
      ),
    );
  }

  Widget _buildProductTable({int limit = 10}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5),
        ],
      ),
      child: Obx(() {
        if (productController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (productController.products.isEmpty) {
          return const Center(child: Text('No products available'));
        }

        final products = productController.products.take(limit).toList();

        return Column(
          children: [
            Expanded(
              child: DataTable2(
                headingRowColor: MaterialStateProperty.all(
                  Colors.grey.shade100,
                ),
                columnSpacing: 12,
                horizontalMargin: 12,
                minWidth: 800,
                fixedLeftColumns: 1, // Optional: Fix first column
                scrollController: ScrollController(),
                columns: const [
                  DataColumn2(label: Text("Product Name"), size: ColumnSize.L),
                  DataColumn(label: Text("Category")),
                  DataColumn(label: Text("Stock")),
                  DataColumn(label: Text("Price")),
                  DataColumn(label: Text("SKU")),
                  DataColumn(label: Text("Actions")),
                ],
                rows:
                    products.map((product) {
                      return DataRow(
                        cells: [
                          DataCell(Text(product.name)),
                          DataCell(Text(product.category)),
                          const DataCell(Text('20 units')),
                          DataCell(
                            Text('\$${product.price.toStringAsFixed(0)}'),
                          ),
                          DataCell(Text('SKU100${product.id}')),
                          DataCell(
                            Row(
                              children: [
                                if (canEdit())
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      size: 20,
                                      color: Colors.blue,
                                    ),
                                    onPressed:
                                        () => showProductForm(product: product),
                                  ),
                                if (canDelete())
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      size: 20,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => confirmDelete(product),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
              ),
            ),

            // Pagination section
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '1-${products.length} of ${productController.products.length} items',
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.arrow_back_ios, size: 16),
                  const Text('1'),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildCustomersOverview() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'User Management',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // ✅ Make the stats row horizontally scrollable without changing layout
          Obx(() {
            final totalUsers = userController.users.length;
            final activeUsers =
                userController.users.where((u) => u.role == 'user').length;
            final pendingUsers =
                userController.users.where((u) => u.role == 'pending').length;
            final adminsOrOrganizers =
                userController.users
                    .where((u) => u.role == 'admin' || u.role == 'organizer')
                    .length;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  StatCard(
                    title: 'Total Users',
                    value: totalUsers.toString(),
                    icon: Icons.people_alt,
                    color: const Color(0xFF6B8BF2), // Blue
                  ),
                  const SizedBox(width: 16),
                  StatCard(
                    title: 'Active Users',
                    value: activeUsers.toString(),
                    icon: Icons.check_circle,
                    color: const Color(0xFF55B865), // Green
                  ),
                  const SizedBox(width: 16),
                  StatCard(
                    title: 'Pending Users',
                    value: pendingUsers.toString(),
                    icon: Icons.hourglass_bottom,
                    color: const Color(0xFFF2A34F), // Orange
                  ),
                  const SizedBox(width: 16),
                  StatCard(
                    title: 'Admins / Organizers',
                    value: adminsOrOrganizers.toString(),
                    icon: Icons.admin_panel_settings,
                    color: const Color(0xFFEF5350), // Red
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 20),
          Expanded(child: _buildUserManagementContent()),
        ],
      ),
    );
  }

  Widget _buildUserManagementContent() {
    final roles = ['user', 'organizer', 'admin'];
    final searchQuery = ''.obs;
    final selectedRole = 'All'.obs;

    return Obx(() {
      if (userController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (userController.users.isEmpty) {
        return const Center(child: Text('No users found'));
      }

      final filteredUsers =
          userController.users.where((user) {
            final matchesSearch =
                user.name.toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                ) ||
                user.email.toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                );
            final matchesRole =
                selectedRole.value == 'All'
                    ? true
                    : user.role == selectedRole.value;
            return matchesSearch && matchesRole;
          }).toList();

      return Column(
        children: [
          ModernSearchBar(
            hintText: 'Search user by name or email...',
            onChanged: (v) => searchQuery.value = v,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              DropdownButton<String>(
                value: selectedRole.value,
                items:
                    ['All', ...roles]
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                onChanged: (v) {
                  if (v != null) selectedRole.value = v;
                },
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => userController.fetchUsers(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5),
                ],
              ),
              child: DataTable2(
                columnSpacing: 16,
                horizontalMargin: 12,
                minWidth: 800,
                headingRowHeight: 50,
                dataRowHeight: 56,
                showCheckboxColumn: false,
                columns: const [
                  DataColumn(label: Text("User ID")),
                  DataColumn(label: Text("Full Name")),
                  DataColumn(label: Text("Email")),
                  DataColumn(label: Text("Role")),
                  DataColumn(label: Text("Status")),
                  DataColumn(label: Text("Actions")),
                ],
                rows:
                    filteredUsers.map((user) {
                      return DataRow(
                        cells: [
                          DataCell(Text('USR${user.id}')),
                          DataCell(Text(user.name)),
                          DataCell(Text(user.email)),
                          DataCell(
                            currentRole.value == 'admin'
                                ? DropdownButton<String>(
                                  value: user.role,
                                  underline: const SizedBox(),
                                  items:
                                      roles
                                          .map(
                                            (r) => DropdownMenuItem(
                                              value: r,
                                              child: Text(r),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (newRole) {
                                    if (newRole != null &&
                                        newRole != user.role) {
                                      userController.updateUserRole(
                                        user.id,
                                        newRole,
                                      );
                                    }
                                  },
                                )
                                : Text(user.role),
                          ),
                          DataCell(
                            Text(
                              user.role == 'user' ? 'Active' : 'Verified',
                              style: TextStyle(
                                color:
                                    user.role == 'user'
                                        ? Colors.green
                                        : Colors.blueAccent,
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildInventoryOverview() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Inventory Overview',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // ✅ Make stat cards horizontally scrollable on small screens
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: const [
                StatCard(
                  title: 'Total Stock',
                  value: '5000 Units',
                  icon: Icons.inventory,
                  color: Color(0xFF55B865), // Greenish
                ),
                SizedBox(width: 16),
                StatCard(
                  title: 'Low Stock Items',
                  value: '200',
                  icon: Icons.warning,
                  color: Color(0xFFF2A34F), // Orangish
                ),
                SizedBox(width: 16),
                StatCard(
                  title: 'Out of Stock',
                  value: '50',
                  icon: Icons.cancel,
                  color: Color(0xFFEF5350), // Reddish
                ),
                SizedBox(width: 16),
                StatCard(
                  title: 'Reorder Items',
                  value: '10',
                  icon: Icons.reorder,
                  color: Color(0xFF6B8BF2), // Bluish
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          ModernSearchBar(hintText: 'Search Inventory'),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5),
                ],
              ),
              child: const Center(child: Text('Inventory Items Table')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesOverview() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sales Overview',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // ✅ Make stat cards horizontally scrollable on small screens
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: const [
                StatCard(
                  title: 'Total Sales',
                  value: '500',
                  icon: Icons.attach_money,
                  color: Color(0xFF6B8BF2), // Bluish
                ),
                SizedBox(width: 16),
                StatCard(
                  title: 'Total Revenue',
                  value: '\$50,000',
                  icon: Icons.trending_up,
                  color: Color(0xFF55B865), // Greenish
                ),
                SizedBox(width: 16),
                StatCard(
                  title: 'Avg Order Value',
                  value: '\$500',
                  icon: Icons.shopping_basket,
                  color: Color(0xFFF2A34F), // Orangish
                ),
                SizedBox(width: 16),
                StatCard(
                  title: 'Sales Growth',
                  value: '15%',
                  icon: Icons.show_chart,
                  color: Color(0xFFEF5350), // Reddish
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          ModernSearchBar(hintText: 'Search Sales'),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5),
                ],
              ),
              child: const Center(child: Text('Sales Transaction Table')),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------- TAB SWITCH (UPDATED) -----------------
  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardOverview();
      case 1:
        return _buildProductOverview(); // Maps to 'Products'
      case 2:
        return OrdersManagementPage(); // Maps to 'Orders'
      case 3:
        return _buildCustomersOverview(); // Maps to 'Customers'
      case 4:
        return _buildInventoryOverview(); // Maps to 'Inventory'
      case 5:
        return _buildSalesOverview();
      case 6:
        return AdminProfilePage();
      default:
        return const Center(
          child: Text('Welcome to Admin Dashboard! Select a menu item.'),
        );
    }
  }

  // ----------------- DRAWER ITEM (FIXED RETURN TYPE) -----------------
  Widget _drawerItem(IconData icon, String title, int index) {
    // Determine if the current item is selected
    final isSelected = _selectedIndex == index;

    const Color activeColor = Colors.white;
    const Color inactiveColor = Color(0xFFE0E0E0);
    const Color activeTileColor = Color(0xFFD32F2F); // Deep red

    // This Container wraps the ListTile, so the return type must be Widget.
    return Container(
      // Padding and margin to separate the items visually
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      decoration: BoxDecoration(
        color: isSelected ? activeTileColor : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? activeColor : inactiveColor),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? activeColor : inactiveColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onTap: () {
          setState(() => _selectedIndex = index);
          if (MediaQuery.of(context).size.width < 800) Navigator.pop(context);
        },
      ),
    );
  }

  // ----------------- DRAWER CONTENT (UPDATED) -----------------
  Widget _buildDrawerContent() {
    return Container(
      color: const Color(0xFFD32F2F), // Deep Red Color
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header with Circular Image and Name
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFFD32F2F)),
            accountName: Text(
              authController.userName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: Text(
              authController.userRole,
              style: const TextStyle(fontSize: 14),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundImage: AssetImage('assets/images/im5.jpg'),
            ),
          ),

          // Drawer Items
          _drawerItem(Icons.dashboard, 'Statistics', 0),
          _drawerItem(Icons.shopping_bag, 'Products', 1),
          _drawerItem(Icons.shopping_cart, 'Orders', 2),
          _drawerItem(Icons.people, 'Customers', 3),
          _drawerItem(Icons.inventory, 'Inventory', 4),
          _drawerItem(Icons.trending_up, '\$ Sales', 5),
          _drawerItem(Icons.person, 'Profile', 6),
          const SizedBox(height: 50),

          // Logout Section
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextButton.icon(
                onPressed: () => authController.logout(),
                icon: const Icon(Icons.logout, color: Colors.white70),
                label: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------- BUILD (UPDATED) -----------------
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isLargeScreen = constraints.maxWidth >= 800;

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading:
                !isLargeScreen, // Show drawer icon on small screens
            title:
                isLargeScreen
                    ? null // Title handled by the content area for large screens
                    : const Text('Admin Dashboard'),
            backgroundColor: Colors.white,
            elevation: 0.5,
            actions: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: IconButton(
                      icon: const Icon(
                        Icons.notifications_none_outlined,
                        color: Color(0xFFD32F2F),
                      ),
                      onPressed: () => Get.to(() => NotificationScreen()),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: IconButton(
                      icon: const Icon(Icons.logout, color: Color(0xFFD32F2F)),
                      onPressed: () {
                        final AuthController authController =
                            Get.find<AuthController>();
                        authController.logout();
                        Get.offAll(() => SigninScreen());
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          drawer: isLargeScreen ? null : Drawer(child: _buildDrawerContent()),
          body: SafeArea(
            child:
                isLargeScreen
                    ? Row(
                      children: [
                        // Fixed Width Sidebar (Red)
                        SizedBox(width: 250, child: _buildDrawerContent()),
                        // Main Content Area (Light Gray/White)
                        Expanded(
                          child: Container(
                            color: const Color(0xFFF5F5F5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Welcome Back, Admin DashBoard',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Main content of the selected tab
                                Expanded(child: _buildContent()),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                    : _buildContent(), // Mobile view uses the drawer and main content
          ),
        );
      },
    );
  }
}
