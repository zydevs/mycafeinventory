import 'package:mycafeinventory/routes/app_routes.dart';
import 'package:mycafeinventory/widgets/custom_image_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mycafeinventory/utils/image_constant.dart';
import 'package:mycafeinventory/widgets/custom_navbar.dart';
import 'package:mycafeinventory/screens/notification_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile',
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
            child: ProfileScreen(),
          ),
        ),
      ),
    );
  }
}

// main class
// ignore: must_be_immutable
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
  
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Column(
        children: [
          // Bagian header yang di-clip
          Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              // Background dengan ClipPath
              ClipPath(
                clipper: BottomConcaveClipper(),
                child: Container(
                  color: const Color(0xFF00D09E),
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                      top: 30, left: 30, right: 30, bottom: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Baris atas dengan Stack agar teks Profile benar-benar di tengah
                      Stack(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Logo kiri
                              CustomImageView(
                                imagePath: ImageConstant.imgLogoTertiary,
                                height: 55,
                                width: 55,
                              ),
                              // Notifikasi Btn
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => NotificationScreen()),
                                  );
                                },
                                child: CustomImageView(
                                  imagePath: ImageConstant.imgNotifIcon,
                                  height: 30,
                                  width: 30,
                                ),
                              ),
                            ],
                          ),
                          // Teks Profile ditengah secara absolut
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Profile',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),

              // Foto profil di tengah bawah
              Positioned(
                bottom: 20,
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.grey[300],
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),

          // Body selanjutnya (widget lainnya)
          Expanded(
            child: _BodyWidget(),
          ),
        ],
      ),
    );
  }
}

// body
class _BodyWidget extends StatefulWidget {
  const _BodyWidget({Key? key}) : super(key: key);

  @override
  State<_BodyWidget> createState() => _BodyWidgetState();
}

class _BodyWidgetState extends State<_BodyWidget> {

  void signUserOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    // Navigasi ke login screen, hapus semua riwayat halaman
     Navigator.pushNamed(context, AppRoutes.loginScreen );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      bottomNavigationBar: CustomNavbar(currentIndex: 4),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(currentUser?.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Gagal memuat data pengguna'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;

          final fullName = userData['fullName'] ?? 'Nama Tidak Ditemukan';
          final userName = userData['userName'] ?? 'username';
          final email = userData['email'] ?? 'email';

          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 350,
                            height: 25,
                            child: Text(
                              fullName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF052224),
                                fontSize: 20,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                              ),
                            ),
                          ),
                          Text(
                            '$userName',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF052224),
                              fontSize: 13,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Informasi 1
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CustomImageView(
                                imagePath: ImageConstant.imgProfile1,
                                height: 57,
                                width: 53,
                              ),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 260,
                                child: Text(
                                  email,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                    color: Color(0xFF052224),
                                    fontSize: 15,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Informasi 2
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CustomImageView(
                                imagePath: ImageConstant.imgProfile2,
                                height: 57,
                                width: 53,
                              ),
                              const SizedBox(width: 16),
                              const SizedBox(
                                width: 260,
                                child: Text(
                                  '1.0.0',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Color(0xFF052224),
                                    fontSize: 15,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Informasi 3
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CustomImageView(
                                imagePath: ImageConstant.imgProfile3,
                                height: 57,
                                width: 53,
                              ),
                              const SizedBox(width: 16),
                              const SizedBox(
                                width: 260,
                                child: Text(
                                  'Bantuan',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Color(0xFF052224),
                                    fontSize: 15,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Logout
                          GestureDetector(
                            onTap: () => signUserOut(context),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CustomImageView(
                                  imagePath: ImageConstant.imgProfile4,
                                  height: 57,
                                  width: 53,
                                ),                                
                              ],
                            ),
                          ),

                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

}


// class clip top
class BottomConcaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double curveHeight = 70.0;

    Path path = Path();
    path.moveTo(0, 0); // kiri atas

    // Turun ke bawah sampai cekungan kiri
    path.lineTo(0, size.height);
    path.quadraticBezierTo(
      0,
      size.height - curveHeight,
      curveHeight,
      size.height - curveHeight,
    );

    // Garis lurus tengah
    path.lineTo(size.width - curveHeight, size.height - curveHeight);

    // Cekungan kanan
    path.quadraticBezierTo(
      size.width,
      size.height - curveHeight,
      size.width,
      size.height,
    );

    // Kembali ke atas
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
