import 'package:mycafeinventory/routes/app_routes.dart';
import 'package:mycafeinventory/services/sales_service.dart';
import 'package:mycafeinventory/services/user_service.dart';
import 'package:mycafeinventory/widgets/custom_image_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/image_constant.dart';
import '../widgets/custom_navbar.dart';
import 'package:mycafeinventory/screens/notification_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home App',
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
            child: InvManagerScreen(),
          ),
        ),
      ),
    );
  }
}

class InvManagerScreen extends StatefulWidget {
  const InvManagerScreen({Key? key}) : super(key: key);

  @override
  State<InvManagerScreen> createState() => _InvManagerScreenState();
}

class _InvManagerScreenState extends State<InvManagerScreen> {
  // Inisiasi UID secara langsung
  final String _currentUserId = 'Ft1UBlWgyvuFbfnVZ9od';
  final UserService _userService = UserService();
  final SalesService _salesService = SalesService();
  double _balance = 0;
  double _totalSpending = 0;
  double _totalIncome = 0;

  void signUserOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // Navigasi ke login screen, hapus semua riwayat halaman
    Navigator.pushNamed(context, AppRoutes.loginScreen);
  }

  @override
  void initState() {
    super.initState();
    _fetchFinancialData(_currentUserId);
  }

  Future<void> _fetchFinancialData(String userId) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

    try {
      final saleSnapshot = await userDoc.collection('sale').get();
      final inventorySnapshot = await userDoc.collection('inventory').get();

      double totalSale = saleSnapshot.docs.fold(0.0, (sum, doc) {
        return sum + (doc.data()['price'] ?? 0).toDouble();
      });

      double totalInventory = inventorySnapshot.docs.fold(0.0, (sum, doc) {
        return sum + (doc.data()['total'] ?? 0).toDouble();
      });

      double totalSales = await _salesService.getTotalSales(userId: userId);

      setState(() {
        _balance = totalSale;
        _totalSpending = totalInventory;
        _totalIncome = totalSales;
      });
    } catch (e) {
      print('Gagal mengambil data header: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data keuangan: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Column(
        children: [
          // Header dengan clip
          ClipPath(
            clipper: BottomConcaveClipper(),
            child: Container(
              color: const Color(0xFF00D09E),
              width: double.infinity,
              padding: const EdgeInsets.only(top: 50, left: 30, right: 30, bottom: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo, teks dan notifikasi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomImageView(
                        imagePath: ImageConstant.imgLogoTertiary,
                        height: 41,
                        width: 55,
                      ),
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'Riwayat Inventory',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),

                      // Notif
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

                  const SizedBox(height: 25),

                  // Saldo dan pengeluaran
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Saldo
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CustomImageView(
                                imagePath: ImageConstant.imgIncomeMini,
                                height: 14,
                                width: 14,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Total Penjualan',
                                style: TextStyle(
                                  color: Color(0xFFDFF7E2),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(_totalIncome),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 21,
                            ),
                          ),
                        ],
                      ),

                      // Garis pemisah
                      Container(width: 2, height: 50, color: Colors.white),

                      // Pengeluaran
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CustomImageView(
                                imagePath: ImageConstant.imgExpenseMini,
                                height: 14,
                                width: 14,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Total Pengeluaran',
                                style: TextStyle(
                                  color: Color(0xFFDFF7E2),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(_totalSpending),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 21,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 70),
                ],
              ),
            ),
          ),

          // Body konten lainnya
          Expanded(
            child: _BodyWidget(userId: _currentUserId), // Meneruskan userId ke _BodyWidget
          ),
        ],
      ),
    );
  }
}

class _BodyWidget extends StatefulWidget {
  final String userId; // Tambahkan properti userId

  const _BodyWidget({Key? key, required this.userId}) : super(key: key); // Perbarui konstruktor

  @override
  State<_BodyWidget> createState() => _BodyWidgetState();
}

// Body
class _BodyWidgetState extends State<_BodyWidget> {
  // Remove _selectedPeriod as switch button is removed
  // String _selectedPeriod = 'Re-Stok'; // default selected switch
  List<Map<String, dynamic>> _inventoryList = []; // Ganti _transactions menjadi _inventoryList

  @override
  void initState() {
    super.initState();
    _fetchAggregatedInventory(); // Mengganti _fetchInventoryTransactions
  }

  Future<void> _fetchAggregatedInventory() async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(widget.userId);

    try {
      final inventorySnapshot = await userDoc.collection('inventory').get();

      // Gunakan Map untuk mengakumulasi stok berdasarkan nama inventaris
      Map<String, Map<String, dynamic>> aggregatedData = {};

      for (var doc in inventorySnapshot.docs) {
        final data = doc.data();
        final nameInv = data['nameInv'] ?? 'Unknown Item';
        final stokInv = (data['stokInv'] as num?)?.toDouble() ?? 0.0;
        final unitInv = data['unitInv'] ?? '';

        if (nameInv.isNotEmpty) {
          if (aggregatedData.containsKey(nameInv)) {
            // Jika nama inventaris sudah ada, tambahkan stoknya
            aggregatedData[nameInv]!['stok'] = (aggregatedData[nameInv]!['stok'] ?? 0.0) + stokInv;
            // Pastikan unitnya konsisten (ambil unit dari entri terakhir)
            aggregatedData[nameInv]!['unit'] = unitInv;
          } else {
            // Jika nama inventaris belum ada, tambahkan sebagai entri baru
            aggregatedData[nameInv] = {
              'name': nameInv,
              'stok': stokInv,
              'unit': unitInv,
            };
          }
        }
      }

      // Konversi aggregatedData menjadi List untuk ditampilkan
      setState(() {
        _inventoryList = aggregatedData.values.toList();
        // Urutkan berdasarkan nama inventaris
        _inventoryList.sort((a, b) => a['name'].compareTo(b['name']));
      });
    } catch (e) {
      print('Gagal mengambil data inventaris akumulatif: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data inventaris: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomNavbar(currentIndex: 4),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // _buildSwitchButtonGroup() dihapus
                const SizedBox(height: 24), // Memberikan jarak di bagian atas
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _inventoryList.isEmpty
                        ? [
                            const Center(
                              child: Text(
                                "Data inventaris belum tersedia.",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                  color: Color(0xFF00D09E),
                                ),
                              ),
                            ),
                          ]
                        : _inventoryList.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14.0),
                              child: _buildInventoryRow(
                                title: item['name'],
                                stok: item['stok'],
                                unit: item['unit'],
                              ),
                            );
                          }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget baru untuk menampilkan baris inventaris akumulatif
  Widget _buildInventoryRow({
    required String title,
    required double stok,
    required String unit,
  }) {
    final String iconPath = ImageConstant.imgN2; // Menggunakan ikon Re-Stok karena ini tentang stok yang tersedia
    final String stockLabel = '${stok.toStringAsFixed(0)} $unit'; // Format stok

    return Container(
      width: 400,
      height: 53,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 57,
            height: 53,
            child: Center(
              child: CustomImageView(
                imagePath: iconPath,
                height: 40,
                width: 40,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded( // Expanded agar judul bisa mengambil sisa ruang
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF052224),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // Tidak ada lagi tanggal di sini
              ],
            ),
          ),
          const SizedBox(width: 18),
          Container(width: 1, height: 40, color: const Color(0xFF00D09E)), // Divider
          const SizedBox(width: 18),
          // Menampilkan sisa stok
          Text(
            'Sisa Stok', // Label untuk sisa stok
            style: const TextStyle(
              color: Color(0xFF052224),
              fontSize: 13,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              height: 1.15,
            ),
          ),
          const SizedBox(width: 18),
          Container(width: 1, height: 40, color: const Color(0xFF00D09E)), // Divider
          const SizedBox(width: 18),
          Expanded( // Expanded agar stok bisa mengambil sisa ruang dan rata kanan
            child: Text(
              stockLabel,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Color(0xFF0068FF), // Warna biru untuk sisa stok
                fontSize: 15,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // _buildSwitchButtonGroup() dihapus
}

class BottomConcaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double curveHeight = 70.0;

    Path path = Path();
    path.moveTo(0, 0); // top left

    // Line down to the start of the left concave curve
    path.lineTo(0, size.height);
    path.quadraticBezierTo(
      0,
      size.height - curveHeight,
      curveHeight,
      size.height - curveHeight,
    );

    // Straight line in the middle
    path.lineTo(size.width - curveHeight, size.height - curveHeight);

    // Right concave curve
    path.quadraticBezierTo(
      size.width,
      size.height - curveHeight,
      size.width,
      size.height,
    );

    // Line back up to top right
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// GreenRoundedCard dihapus karena tidak digunakan lagi
