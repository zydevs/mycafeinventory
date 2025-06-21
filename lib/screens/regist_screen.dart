import 'package:acisku/routes/app_routes.dart';
import 'package:acisku/widgets/custom_image_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../utils/image_constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:acisku/auth_page/auth_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Regist App',
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
            child: RegistScreen(),
          ),
        ),
      ),
    );
  }
}

class RegistScreen extends StatelessWidget {
  const RegistScreen({Key? key}) : super(key: key);

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
              padding: const EdgeInsets.only(top: 30.0, left: 20.0, right: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tombol kembali
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: CustomImageView(
                      imagePath: ImageConstant.imgBack,
                      height: 40,
                      width: 50,
                    ),
                  ),
                  // Logo utama (center secara horizontal di Row)
                  CustomImageView(
                    imagePath: ImageConstant.imgMainLogo,
                    height: 91,
                    width: 100,
                    fit: BoxFit.contain,
                  ),
                  // Spacer kanan (kosong untuk menjaga keseimbangan visual)
                  const SizedBox(width: 50), // Sama lebar dengan tombol back
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 40.0),
              child: Text(
                'Daftar Akun',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: _RegistFormWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegistFormWidget extends StatefulWidget {
  const _RegistFormWidget({Key? key}) : super(key: key);

  @override
  State<_RegistFormWidget> createState() => _RegistFormWidgetState();
}

class _RegistFormWidgetState extends State<_RegistFormWidget> {
  // Controllers untuk input field
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Obscure state untuk password dan konfirmasi password
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

 @override
  void dispose() {
    _fullNameController.dispose();
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Toggle untuk visibilitas password
  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  // Fungsi Registrasi
  Future<void> _registerUser(BuildContext context) async {
    final fullName = _fullNameController.text.trim();
    final userName = _userNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      Get.snackbar(
        "Maaf",
        "Password tidak cocok!",
        colorText: Colors.white,
        backgroundColor: Colors.orange,
      );
      return;
    }

    try {
      // Cek apakah username sudah digunakan
      final usernameQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('userName', isEqualTo: userName)
          .get();

      if (usernameQuery.docs.isNotEmpty) {
        Get.snackbar(
          "Maaf",
          "Username sudah digunakan. Silakan pilih username lain.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Cek apakah email sudah digunakan (di Firestore, bukan Auth)
      final emailQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (emailQuery.docs.isNotEmpty) {
        Get.snackbar(
          "Maaf",
          "Email sudah digunakan. Silakan gunakan email lain.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Buat akun di Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Simpan data ke Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user?.uid)
          .set({
        'fullName': fullName,
        'userName': userName,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.loginScreen,
        (route) => false,
      );

      Get.snackbar(
        "Selamat!",
        "Akun berhasil dibuat! Silakan login.",
        backgroundColor: const Color(0xFF00D09E),
        colorText: Colors.white,
      );
    } catch (e) {
      print("Gagal daftar: $e");
      Get.snackbar(
        "Gagal Daftar!",
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(70),
        ),
        border: const Border(
          top: BorderSide(color: Color(0xFF00D09E), width: 2),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 56.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _CustomTextField(
              controller: _fullNameController,
              label: 'Nama Lengkap',
              leftIconPath: ImageConstant.imgUsername,
            ),
            const SizedBox(height: 20),
            _CustomTextField(
              controller: _userNameController,
              label: 'Nama Pengguna',
              leftIconPath: ImageConstant.imgUsername,
            ),
            const SizedBox(height: 20),
            _CustomTextField(
              controller: _emailController,
              label: 'Email',
              leftIconPath: ImageConstant.imgEmail,
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
            const SizedBox(height: 20),
            _CustomTextField(
              controller: _confirmPasswordController,
              label: 'Konfirmasi Kata Sandi',
              obscureText: _obscureConfirmPassword,
              leftIconPath: ImageConstant.imgPassword,
              rightIconPath: _obscureConfirmPassword
                  ? ImageConstant.imgEyeOff
                  : ImageConstant.imgEyeOn,
              onRightIconTap: _toggleConfirmPasswordVisibility,
            ),
            const SizedBox(height: 35),
            _buildButton(
              label: 'Daftar',
              onPressed: () => _registerUser(context),
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
              textAlignVertical: TextAlignVertical.center, // << Tambahan penting
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: label,
                hintStyle: const TextStyle(
                  color: Color(0xFF00D09E),
                  fontSize: 16,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 14),
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
