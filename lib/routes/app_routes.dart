import 'package:get/get.dart';

// Import screens
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/regist_screen.dart';
import '../screens/home_screen.dart';
import '../screens/chatbot_screen.dart';
import '../screens/inventory_screen.dart';
import '../screens/invmanager_screen.dart';
import '../screens/notification_screen.dart';
import '../screens/income_screen.dart';
// import '../screens/auth_page.dart'; 


class AppRoutes {
  static const String splashscreenScreen = '/splashscreen';
  static const String authPage = '/auth';
  static const String loginScreen = '/login';
  static const String registScreen = '/regist';
  static const String homeScreen = '/home';
  static const String transactionIncome = '/transaction/income';
  static const String transactionSpending = '/transaction/spending';
  static const String transactionLimit = '/transaction/limit';
  static const String chatbotScreen = '/chatbot';
  static const String inventoryScreen = '/inventory';
  static const String invmanagerScreen = '/invmanager';
  static const String notificationScreen = '/notification';
  static const String initialRoute = '/';

  static List<GetPage> pages = [
    GetPage(
      name: splashscreenScreen,
      page: () => SplashscreenScreen(),
    ),
    // GetPage(
    //   name: authPage,
    //   page: () => AuthPage(),
    // ),
    GetPage(
      name: loginScreen,
      page: () => LoginScreen(),
    ),
    GetPage(
      name: registScreen,
      page: () => RegistScreen(),
    ),
    GetPage(
      name: homeScreen,
      page: () => HomeScreen(),
    ),
    GetPage(
      name: transactionIncome,
      page: () => IncomeScreen(),
    ),
    GetPage(
      name: chatbotScreen,
      page: () => ChatbotScreen(),
    ),
    GetPage(
      name: inventoryScreen,
      page: () => InventoryScreen(),
    ),
    GetPage(
      name: invmanagerScreen,
      page: () => InvManagerScreen(),
    ),
    GetPage(
      name: notificationScreen,
      page: () => NotificationScreen(),
    ),
    // Initial Route
    GetPage(
      name: initialRoute,
      page: () => SplashscreenScreen(),
    ),
  ];
}
