import 'package:asrat/controllers/order_controller.dart';
import 'package:asrat/iews/widgets/admin_dashboard_page.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrdersManagementPage extends StatelessWidget {
  final OrderController orderController = Get.find<OrderController>();

  OrdersManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final statuses = ['Pending', 'Processing', 'Completed', 'Cancelled'];
    final searchQuery = ''.obs;
    final selectedStatus = 'All'.obs;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Orders Management',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          /// ✅ Summary Cards with automatic status counting
          Obx(() {
            final totalOrders = orderController.orders.length;

            // Count by status dynamically
            Map<String, int> statusCount = {};
            for (var order in orderController.orders) {
              statusCount[order.status] = (statusCount[order.status] ?? 0) + 1;
            }

            final totalRevenue = orderController.totalRevenue;

            // Convert each entry to a stat card
            List<Widget> statCards = [
              StatCard(
                title: 'Total Orders',
                value: '$totalOrders',
                icon: Icons.receipt_long,
                color: const Color(0xFF6B8BF2),
              ),
              const SizedBox(width: 16),
              StatCard(
                title: 'Total Revenue',
                value: '\$${totalRevenue.toStringAsFixed(2)}',
                icon: Icons.attach_money,
                color: const Color(0xFF00BFA6),
              ),
            ];

            // Add one StatCard for each status dynamically
            statusCount.forEach((status, count) {
              statCards.add(const SizedBox(width: 16));
              statCards.add(
                StatCard(
                  title: '$status Orders',
                  value: '$count',
                  icon: _getStatusIcon(status),
                  color: _getStatusColor(status),
                ),
              );
            });

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: statCards),
            );
          }),

          const SizedBox(height: 20),

          // Search & Filter
          ModernSearchBar(
            hintText: 'Search by customer or product...',
            onChanged: (v) => searchQuery.value = v,
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Obx(() {
                final items = ['All', ...statuses];
                if (!items.contains(selectedStatus.value)) {
                  selectedStatus.value = 'All';
                }
                return DropdownButton<String>(
                  value: selectedStatus.value,
                  items:
                      items
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                  onChanged: (v) {
                    if (v != null) selectedStatus.value = v;
                  },
                );
              }),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => orderController.fetchOrders(),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ✅ Orders Table
          Expanded(
            child: Obx(() {
              if (orderController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (orderController.orders.isEmpty) {
                return const Center(child: Text('No orders found'));
              }

              final filtered =
                  orderController.orders.where((order) {
                    final matchesSearch =
                        order.customerName.toLowerCase().contains(
                          searchQuery.value.toLowerCase(),
                        ) ||
                        order.productName.toLowerCase().contains(
                          searchQuery.value.toLowerCase(),
                        );
                    final matchesStatus =
                        selectedStatus.value == 'All'
                            ? true
                            : order.status == selectedStatus.value;
                    return matchesSearch && matchesStatus;
                  }).toList();

              return DataTable2(
                columnSpacing: 12,
                horizontalMargin: 12,
                minWidth: 800,
                columns: const [
                  DataColumn2(label: Text('Order ID'), size: ColumnSize.M),
                  DataColumn2(label: Text('Customer'), size: ColumnSize.L),
                  DataColumn2(label: Text('Product'), size: ColumnSize.L),
                  DataColumn2(label: Text('Price')),
                  DataColumn2(label: Text('Quantity')),
                  DataColumn2(label: Text('Total Price')),
                  DataColumn2(label: Text('Status')),
                  DataColumn2(label: Text('Date')),
                  DataColumn2(label: Text('Actions')),
                ],
                rows:
                    filtered.map((order) {
                      return DataRow(
                        cells: [
                          DataCell(Text('ORD${order.id}')),
                          DataCell(Text(order.customerName)),
                          DataCell(Text(order.productName)),
                          DataCell(
                            Text('\$${order.productPrice.toStringAsFixed(2)}'),
                          ),
                          DataCell(Text('${order.quantity}')),
                          DataCell(
                            Text('\$${order.totalPrice.toStringAsFixed(2)}'),
                          ),
                          DataCell(
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 120),
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value:
                                    statuses.contains(order.status)
                                        ? order.status
                                        : statuses[0],
                                underline: const SizedBox(),
                                items:
                                    statuses
                                        .map(
                                          (s) => DropdownMenuItem(
                                            value: s,
                                            child: Text(
                                              s,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (newStatus) {
                                  if (newStatus != null) {
                                    orderController.updateOrderStatus(
                                      order.id,
                                      newStatus,
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                          DataCell(Text(order.orderDate)),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed:
                                      () =>
                                          orderController.deleteOrder(order.id),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// ✅ Helper: Icon and Color based on status
  static IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Pending':
        return Icons.access_time;
      case 'Processing':
        return Icons.sync;
      case 'Completed':
        return Icons.check_circle;
      case 'Cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  static Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return const Color(0xFFF2A34F);
      case 'Processing':
        return const Color(0xFF64B5F6);
      case 'Completed':
        return const Color(0xFF55B865);
      case 'Cancelled':
        return const Color(0xFFEF5350);
      default:
        return const Color(0xFFBDBDBD);
    }
  }
}
