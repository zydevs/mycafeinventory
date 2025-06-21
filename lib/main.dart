import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart'; // pastikan sizer sudah ditambahkan di pubspec.yaml
import 'routes/app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'My Cafe Inventory',
          locale: Locale('en', 'US'), // default locale
          fallbackLocale: Locale('en', 'US'),
          initialRoute: AppRoutes.initialRoute,
          getPages: AppRoutes.pages,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(
                    1.0), // pastikan Flutter SDK mendukung ini
              ),
              child: child!,
            );
          },
        );
      },
    );
  }
}
