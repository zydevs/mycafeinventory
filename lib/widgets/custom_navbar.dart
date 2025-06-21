import 'package:flutter/material.dart';
import 'package:get/get.dart'; // <== PENTING
import '../utils/image_constant.dart';
import '../widgets/custom_image_view.dart';

class CustomNavbar extends StatelessWidget {
  final int currentIndex;

  const CustomNavbar({
    super.key,
    this.currentIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final navItems = [
      [ImageConstant.imgNavHome, ImageConstant.imgNavHomeOn],
      [ImageConstant.imgNavTransaction, ImageConstant.imgNavTransactionOn],
      [ImageConstant.imgNavChatbot, ImageConstant.imgNavChatbot],
      [ImageConstant.imgNavAnalysis, ImageConstant.imgNavAnalysisOn],
      [ImageConstant.imgNavProfile, ImageConstant.imgNavProfilenOn],
    ];

    final List<String> routes = [
      '/home',
      '/transaction/income',
      '/chatbot',
      '/inventory',
      '/invmanager',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36),
      decoration: const BoxDecoration(
        color: Color(0xFFDFF7E2),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(70),
          topRight: Radius.circular(70),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(navItems.length, (index) {
          final isActive = index == currentIndex;
          final imagePath = isActive && navItems[index].length > 1
              ? navItems[index][1]
              : navItems[index][0];

          return GestureDetector(
            onTap: () {
              if (index != currentIndex) {
                Get.toNamed(routes[index]); // <-- Gunakan Get.toNamed
              }
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (isActive)
                  Container(
                    width: 47,
                    height: 43,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D09E),
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                CustomImageView(
                  imagePath: imagePath,
                  height: 40,
                  width: 40,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}