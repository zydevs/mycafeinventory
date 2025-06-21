import 'dart:async';
import 'package:acisku/routes/app_routes.dart';
import 'package:acisku/widgets/custom_image_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/image_constant.dart'; // Pastikan path dan value-nya benar

class SplashscreenController extends GetxController {

  @override
  void onReady() {
    Future.delayed(const Duration(milliseconds: 5000), () {
      Get.offNamed(
        AppRoutes.loginScreen,
      );
    });
  }
}

class SplashscreenScreen extends GetWidget<SplashscreenController> {
  const SplashscreenScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Timer untuk transisi ke AuthPage setelah 3 detik
    Timer(const Duration(seconds: 3), () {
      Get.offNamed(AppRoutes.loginScreen);
    });

    return Scaffold(
      backgroundColor: const Color(0xFF00D09E),// Sesuai dengan pattern kamu
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomImageView(
                imagePath: ImageConstant.imgMainLogo,
                height: 204,
                width: 186,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
