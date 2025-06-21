import 'package:mycafeinventory/routes/app_routes.dart';
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

  double _balance = 0;
  double _totalSpending = 0;

  void signUserOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    // Navigasi ke login screen, hapus semua riwayat halaman
    Navigator.pushNamed(context, AppRoutes.loginScreen);
  }

  @override
  void initState() {
    super.initState();
    _fetchFinancialData();
  }

  Future<void> _fetchFinancialData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    try {
      final userSnapshot = await userDoc.get();
      _balance = (userSnapshot.data()?['balance'] ?? 0).toDouble();

      // final spendingSnapshot = await userDoc.collection('spending').get();
      final spendingSnapshot = await userDoc
          .collection('spending')
          .orderBy('date', descending: true)
          .get();

      _totalSpending = spendingSnapshot.docs.fold(0.0, (sum, doc) {
        return sum + (doc.data()['amount'] ?? 0).toDouble();
      });

      setState(() {});
    } catch (e) {
      print('Gagal mengambil data keuangan: $e');
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
              padding: const EdgeInsets.only(
                  top: 50, left: 30, right: 30, bottom: 30),
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
                            MaterialPageRoute(
                                builder: (context) => NotificationScreen()),
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
                            NumberFormat.currency(
                                    locale: 'id_ID',
                                    symbol: 'Rp ',
                                    decimalDigits: 0)
                                .format(_balance),
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
                            NumberFormat.currency(
                                    locale: 'id_ID',
                                    symbol: 'Rp ',
                                    decimalDigits: 0)
                                .format(_totalSpending),
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
          const Expanded(
            child: _BodyWidget(),
          ),
        ],
      ),
    );
  }
}

class _BodyWidget extends StatefulWidget {
  const _BodyWidget({Key? key}) : super(key: key);

  @override
  State<_BodyWidget> createState() => _BodyWidgetState();
}

// Body
class _BodyWidgetState extends State<_BodyWidget> {
  String _selectedPeriod = 'Penjualan'; // default
  double _limitPengeluaran = 0;
  double _balance = 0;
  double _totalSpending = 0;

  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchFinancialData();
  }

  Future<void> _fetchFinancialData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    try {
      final userSnapshot = await userDoc.get();
      _balance = (userSnapshot.data()?['balance'] ?? 0).toDouble();
      _limitPengeluaran = (userSnapshot.data()?['limitSpend'] ?? 0).toDouble();

      final incomeSnapshot = await userDoc.collection('income').get();
      final spendingSnapshot = await userDoc.collection('spending').get();

      // Gabungkan income dan spending
      _transactions = [
        ...incomeSnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'title': data['source'] ?? '',
            'date': (data['date'] as Timestamp?)?.toDate() != null
                ? DateFormat('dd MMM yyyy')
                    .format((data['date'] as Timestamp).toDate())
                : '',
            'type': 'Penjualan',
            'amount': (data['amount'] ?? 0).toDouble(),
          };
        }),
        ...spendingSnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'title': data['source'] ?? '',
            'date': (data['date'] as Timestamp?)?.toDate() != null
                ? DateFormat('dd MMM yyyy')
                    .format((data['date'] as Timestamp).toDate())
                : '',
            'type': 'Pengeluaran',
            'amount': (data['amount'] ?? 0).toDouble(),
          };
        }),
      ];

      // Hitung total pengeluaran
      _totalSpending = _transactions
          .where((t) => t['type'] == 'Pengeluaran')
          .fold(0.0, (sum, t) => sum + (t['amount'] as double));

      setState(() {}); // Perbarui UI
    } catch (e) {
      print('Gagal mengambil data keuangan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomNavbar(currentIndex: 4),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 0.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildSwitchButtonGroup(),
                        const SizedBox(height: 24),

                        // Cek apakah _transactions berisi data untuk _selectedPeriod
                        ..._transactions
                                .where((tx) => tx['type'] == _selectedPeriod)
                                .isEmpty
                            ? [
                                Center(
                                  child: Text(
                                    "Silahkan catat keuanganmu dahulu",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'Poppins',
                                      color: const Color(0xFF00D09E),
                                    ),
                                  ),
                                ),
                              ]
                            : _transactions
                                .where((tx) => tx['type'] == _selectedPeriod)
                                .map((tx) {
                                final isPenjualan = tx['type'] == 'Penjualan';
                                final amountFormatted = NumberFormat.currency(
                                  locale: 'id_ID',
                                  symbol: isPenjualan ? '+Rp ' : '-Rp ',
                                  decimalDigits: 0,
                                ).format(tx['amount']);
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 14.0),
                                  child: _buildTransactionRow(
                                    title: tx['title'],
                                    date: tx['date'],
                                    type: tx['type'],
                                    amount: amountFormatted,
                                    amountColor: isPenjualan
                                        ? const Color(0xFF0068FF)
                                        : const Color(0xFFFF3B3B),
                                  ),
                                );
                              }).toList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget tambahan untuk ringkas riwayat keuangan
  Widget _buildTransactionRow({
    required String title,
    required String date,
    required String type,
    required String amount,
    required Color amountColor,
  }) {
    // Tentukan ikon berdasarkan tipe transaksi
    final String iconPath =
        type == 'Penjualan' ? ImageConstant.imgN2 : ImageConstant.imgN3;

    return Container(
      width: 400,
      height: 53,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ICON
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

          // Judul dan tanggal
          Column(
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
              const SizedBox(height: 4),
              Text(
                date,
                style: const TextStyle(
                  color: Color(0xFF052224),
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(width: 18),

          // Garis vertikal
          Container(
            width: 1,
            height: 40,
            color: const Color(0xFF00D09E),
          ),
          const SizedBox(width: 18),

          // Jenis transaksi
          Text(
            type,
            style: const TextStyle(
              color: Color(0xFF052224),
              fontSize: 13,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              height: 1.15,
            ),
          ),
          const SizedBox(width: 18),

          // Garis vertikal
          Container(
            width: 1,
            height: 40,
            color: const Color(0xFF00D09E),
          ),
          const SizedBox(width: 18),

          // Jumlah uang
          Expanded(
            child: Text(
              amount,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: amountColor,
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

  Widget _buildSwitchButtonGroup() {
    final List<String> options = ['Re-Stock', 'Terpakai'];

    return Container(
      padding: const EdgeInsets.all(4),
      width: 400,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFDFF7E2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: options.map((option) {
          final bool isSelected = _selectedPeriod == option;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = option;
                  // Aksi sesuai pilihan bisa ditambahkan di sini
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color:
                      isSelected ? const Color(0xFF00D09E) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : const Color(0xFF00D09E),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

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

class GreenRoundedCard extends StatelessWidget {
  final Widget child;

  const GreenRoundedCard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 150,
      decoration: ShapeDecoration(
        color: const Color(0xFF00D09E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: child,
    );
  }
}
