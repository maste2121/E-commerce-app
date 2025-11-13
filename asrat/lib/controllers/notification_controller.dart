import 'package:asrat/notification/socket_service.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  // Store notifications
  var notifications = <Map<String, dynamic>>[].obs;

  // Add a notification
  void addNotification(Map<String, String> notif) {
    notifications.add(notif);
  }

  @override
  void onInit() {
    super.onInit();

    // Use the instance from GetX
    final socketService = Get.find<SocketService>();

    // Subscribe to socket events
    socketService.socket.on('new_order', (data) {
      print('🟢 New order added to controller: $data');
      notifications.insert(0, {
        'title': 'New Order',
        'subtitle':
            '${data['customerName']} ordered ${data['productName']} (\$${data['totalPrice']})',
        'time': DateTime.now().toString(),
      });
    });
  }

  @override
  void onClose() {
    print('[NotificationController] closed');
    // No socket disconnect here! We want it persistent
    super.onClose();
  }
}
