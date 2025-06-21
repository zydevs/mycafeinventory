import 'package:mycafeinventory/utils/notif_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mycafeinventory/routes/app_routes.dart';
import 'package:mycafeinventory/widgets/custom_image_view.dart';
import 'package:mycafeinventory/utils/image_constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mycafeinventory/auth_page/auth_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF00D09E),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00D09E),
          primary: const Color(0xFF00D09E),
        ),
        useMaterial3: true,
      ),
      home: const SafeArea(
        child: Center(
          child: SizedBox(
            width: 480,
            child: LoginScreen(),
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF00D09E),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: CustomImageView(
                imagePath: ImageConstant.imgMainLogo,
                height: 91,
                width: 100,
                fit: BoxFit.contain,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 40.0),
              child: Text(
                'Hallo!\nSilahkan Login dengan Akunmu',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1,
                ),
              ),
            ),
            const Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 30.0),
                child: _LoginFormWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginFormWidget extends StatefulWidget {
  const _LoginFormWidget({Key? key}) : super(key: key);

  @override
  State<_LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<_LoginFormWidget> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void signUserIn() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    try {
      // Cari user berdasarkan username di Firestore
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userName', isEqualTo: username)
          .get();

      if (querySnapshot.docs.isEmpty) {
        Get.snackbar(
          "Gagal",
          "Username tidak ditemukan",
          colorText: Colors.white,
          backgroundColor: Colors.red,
        );
        return;
      }

      final userDoc = querySnapshot.docs.first;
      final userData = userDoc.data();
      final email = userData['email'];

      // Login pakai email dan password
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;

      Get.snackbar(
        "Selamat!",
        "Anda Berhasil Login",
        colorText: Colors.white,
        backgroundColor: Color(0xFF00D09E),
      );

      // Notifikasi Selamat Datang
      await addNotification(
        userId: user!.uid,
        title: 'Hallo Selamat Datang!',
        message: 'Selamat datang di Aplikasi mycafeinventory. Mulai catat keuanganmu dan konsultasikan langkah finanisalmu dengan fitur chatbot mycafeinventory!',
        type: 'welcome',
      );

      Navigator.pushNamed(context, AppRoutes.homeScreen);

    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        Get.snackbar(
          "Maaf",
          "Password Salah!",
          colorText: Colors.white,
          backgroundColor: Colors.orange,
        );
      } else {
        Get.snackbar(
          "Maaf",
          "Email atau Password Anda Salah!",
          colorText: Colors.white,
          backgroundColor: Colors.orange,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Gagal Login!",
        e.toString(),
        colorText: Colors.white,
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(70),
        ),
        border: Border(
          top: BorderSide(color: Color(0xFF00D09E), width: 2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 56.0),
        child: Column(
          children: [
            _CustomTextField(
              controller: _usernameController,
              label: 'Nama Pengguna',
              leftIconPath: ImageConstant.imgUsername,
            ),
            const SizedBox(height: 20),
            _CustomTextField(
              controller: _passwordController,
              label: 'Kata Sandi',
              obscureText: _obscurePassword,
              leftIconPath: ImageConstant.imgPassword,
              rightIconPath: _obscurePassword
                  ? ImageConstant.imgEyeOff
                  : ImageConstant.imgEyeOn,
              onRightIconTap: _togglePasswordVisibility,
            ),
            const SizedBox(height: 25),
            _buildButton(label: 'Login', onPressed: signUserIn),
            const Spacer(),
            _buildButton(
              label: 'Buat akun baru',
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.registScreen);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: 400,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00D09E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final String? leftIconPath;
  final String? rightIconPath;
  final VoidCallback? onRightIconTap;

  const _CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.leftIconPath,
    this.rightIconPath,
    this.onRightIconTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00D09E)),
      ),
      child: Stack(
        children: [
          if (leftIconPath != null)
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: CustomImageView(
                  imagePath: leftIconPath!,
                  width: 24,
                  height: 24,
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.only(
              left: leftIconPath != null ? 48.0 : 16.0,
              right: rightIconPath != null ? 48.0 : 16.0,
            ),
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: label,
                hintStyle: const TextStyle(
                  color: Color(0xFF00D09E),
                  fontSize: 16,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              style: const TextStyle(
                color: Color(0xFF00D09E),
                fontSize: 16,
              ),
            ),
          ),
          if (rightIconPath != null && onRightIconTap != null)
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: onRightIconTap,
                child: Center(
                  child: CustomImageView(
                    imagePath: rightIconPath!,
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
