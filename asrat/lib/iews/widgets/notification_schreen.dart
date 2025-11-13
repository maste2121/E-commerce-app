import 'package:asrat/controllers/notification_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationScreen extends StatelessWidget {
  NotificationScreen({super.key});

  final NotificationController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Obx(() {
        if (controller.notifications.isEmpty) {
          return Center(
            child: Text(
              'No notifications yet.',
              style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.notifications.length,
          itemBuilder: (_, index) {
            final notif = controller.notifications[index];
            return Card(
              child: ListTile(
                title: Text(notif['title']!),
                subtitle: Text(notif['subtitle']!),
                trailing: Text(notif['time']!.split(' ')[1]), // show time
              ),
            );
          },
        );
      }),
    );
  }
}
