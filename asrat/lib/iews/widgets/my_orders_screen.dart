import 'package:flutter/material.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Orders")),
      body: const Center(
        child: Text(
          "No Orders Yet",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
