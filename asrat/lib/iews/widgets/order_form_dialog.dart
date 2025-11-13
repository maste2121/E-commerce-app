import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/order_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/product.dart';

class OrderFormDialog extends StatefulWidget {
  final Product product;
  const OrderFormDialog({Key? key, required this.product}) : super(key: key);

  @override
  State<OrderFormDialog> createState() => _OrderFormDialogState();
}

class _OrderFormDialogState extends State<OrderFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(text: '1');

  final OrderController orderController = Get.find<OrderController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    // Prefill customer name if user is logged in
    _customerNameController.text = authController.user?['user']?['name'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Order ${widget.product.name}"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _customerNameController,
              decoration: const InputDecoration(labelText: "Your Name"),
              validator: (value) => (value == null || value.isEmpty) ? "Enter your name" : null,
            ),
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: "Quantity"),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return "Enter quantity";
                if (int.tryParse(value) == null || int.parse(value) <= 0) return "Invalid quantity";
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // Get customerId if logged in, otherwise 0
              final customerId = authController.user?['user']?['id'] ?? 0;

              orderController.addOrder(
                customerId: customerId,
                customerName: _customerNameController.text,
                productId: widget.product.id,
                productName: widget.product.name,
                productPrice: widget.product.price,
                quantity: int.parse(_quantityController.text),
              );

              Navigator.pop(context);
            }
          },
          child: const Text("Confirm"),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
}
