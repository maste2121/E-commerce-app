import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'notification_service.dart';

class SocketService extends GetxService {
  late IO.Socket socket;

  @override
  void onInit() {
    super.onInit();

    // Initialize socket immediately
    socket = IO.io(
      'http://10.161.171.184:8080',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect() // manual connect
          .build(),
    );
  }

  /// Connect to server as admin or customer
  void connect({required bool isAdmin, String? customerId}) {
    socket.connect();

    socket.onConnect((_) {
      print('🟢 Connected: ${socket.id}');

      // Register socket role
      if (isAdmin) {
        socket.emit('register_admin');
        print('👤 Registered as Admin');
      } else if (customerId != null) {
        socket.emit('register_customer', customerId);
        print('👤 Registered as Customer: $customerId');
      }
    });

    // Listen for admin notifications
    socket.on('new_order', (data) {
      print('🟢 New order received: $data');
      NotificationService.showNotification(
        title: 'New Order',
        body:
            '${data['customerName']} ordered ${data['productName']} (\$${data['totalPrice']})',
      );
    });

    // Listen for customer notifications
    socket.on('order_status_update', (data) {
      print('🟢 Order status update: $data');
      NotificationService.showNotification(
        title: 'Order Update',
        body: 'Order #${data['orderId']} status: ${data['status']}',
      );
    });

    socket.onDisconnect((_) => print('🔴 Disconnected from server'));
  }

  /// Disconnect socket
  void disconnect() {
    socket.disconnect();
    print('🔴 Socket disconnected manually');
  }
}
