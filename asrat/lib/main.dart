import 'package:asrat/controllers/auth_controller.dart';
import 'package:asrat/controllers/notification_controller.dart';
import 'package:asrat/controllers/order_controller.dart';
import 'package:asrat/controllers/theme_controller.dart';
import 'package:asrat/notification/socket_service.dart';
import 'package:asrat/utlits/app_theme.dart';
import 'package:asrat/viees/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Initialize controllers
  Get.put(ThemeController());
  Get.put(AuthController());
  Get.put(OrderController());

  // Initialize SocketService permanently
  final socketService = Get.put(SocketService(), permanent: true);
  // Initialize NotificationController permanently
  Get.put(NotificationController(), permanent: true);

  // Example: Connect as admin
  socketService.connect(isAdmin: true);

  // Example: Connect as customer (uncomment when needed)
  final authController = Get.find<AuthController>();
  String? userId = authController.user?['id']?.toString();
  if (userId != null) {
    socketService.connect(isAdmin: false, customerId: userId);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Fashion Store",
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeController.theme,
      defaultTransition: Transition.fade,
      home: SplashScreen(),
    );
  }
}
