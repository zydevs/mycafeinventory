import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mycafeinventory/screens/login_screen.dart';
import 'package:mycafeinventory/screens/home_screen.dart';
import 'package:mycafeinventory/routes/app_routes.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Jika user sudah login
          if (snapshot.hasData) {
            // Navigasi ke HomeScreen menggunakan Get.toNamed()
            Future.delayed(Duration.zero, () {
              Navigator.pushNamed(context, AppRoutes.homeScreen);
            });
            return Container();  // Kembalikan kosong untuk sementara
          }

          // Jika user belum login
          else {
            return LoginScreen();
          }
        },
      ),
    );
  }
}
