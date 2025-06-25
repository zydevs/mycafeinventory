import 'package:mycafeinventory/routes/app_routes.dart';
import 'package:mycafeinventory/widgets/custom_image_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/image_constant.dart';
import '../widgets/custom_navbar.dart';
import 'package:mycafeinventory/screens/notification_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Pastikan ini ada
import 'package:firebase_auth/firebase_auth.dart';

// MyApp Class (Tidak berubah)
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
            child: HomeScreen(),
          ),
        ),
      ),
    );
  }
}

// HomeScreen Class (Tidak berubah, karena perubahan di _BodyWidgetState)
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void signUserOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.loginScreen, (route) => false);
  }

  double _balance = 0;
  double _totalSpending = 0;

  @override
  void initState() {
    super.initState();
    _fetchFinancialData();
  }

  Future<void> _fetchFinancialData() async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc('Ft1UBlWgyvuFbfnVZ9od');

    try {
      final saleSnapshot = await userDoc.collection('sales').get();
      final inventorySnapshot = await userDoc.collection('inventory').get();

      double totalSale = saleSnapshot.docs.fold(0.0, (sum, doc) {
        return sum + (doc.data()['price'] ?? 0).toDouble();
      });

      double totalInventory = inventorySnapshot.docs.fold(0.0, (sum, doc) {
        return sum + (doc.data()['total'] ?? 0).toDouble();
      });

      setState(() {
        _balance = totalSale;
        _totalSpending = totalInventory;
      });
    } catch (e) {
      print('Gagal mengambil data header: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Column(
        children: [
          // Header dengan clip (Tidak berubah)
          ClipPath(
            clipper: BottomConcaveClipper(),
            child: Container(
              color: const Color(0xFF00D09E),
              width: double.infinity,
              padding: const EdgeInsets.only(top: 50, left: 30, right: 30, bottom: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo, teks dan notifikasi (Tidak berubah)
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
                            'Selamat Datang\ndi My Cafe Inventory',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
                      // Notif (Tidak berubah)
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

                      // Logout (Tidak berubah)
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

                  // Saldo dan pengeluaran (Tidak berubah)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Saldo (Tidak berubah)
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
                            NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(_balance),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 21,
                            ),
                          ),
                        ],
                      ),

                      // Garis pemisah (Tidak berubah)
                      Container(width: 2, height: 50, color: Colors.white),

                      // Pengeluaran (Tidak berubah)
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

          // Body konten lainnya (Bagian yang direvisi)
          const Expanded(
            child: _BodyWidget(),
          ),
        ],
      ),
    );
  }
}

// _BodyWidget Class
class _BodyWidget extends StatefulWidget {
  const _BodyWidget({Key? key}) : super(key: key);

  @override
  State<_BodyWidget> createState() => _BodyWidgetState();
}

// Body State
class _BodyWidgetState extends State<_BodyWidget> {
  String _selectedPeriod = 'Penjualan'; // default
  double _limitPengeluaran = 0; // Anda mungkin perlu menginisialisasi atau mengambil ini dari Firestore juga
  double _balance = 0; // Sebaiknya ini diambil dari state _HomeScreenState jika memang data yang sama
  double _totalSpending = 0; // Sebaiknya ini diambil dari state _HomeScreenState jika memang data yang sama

  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchFinancialData();
  }

  Future<void> _fetchFinancialData() async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc('Ft1UBlWgyvuFbfnVZ9od');

    try {
      final saleSnapshot = await userDoc.collection('sales').get();
      final inventorySnapshot = await userDoc.collection('inventory').get();

      double totalSale = saleSnapshot.docs.fold(0.0, (sum, doc) {
        return sum + (doc.data()['price'] ?? 0).toDouble();
      });

      double totalInventory = inventorySnapshot.docs.fold(0.0, (sum, doc) {
        return sum + (doc.data()['total'] ?? 0).toDouble();
      });

      final List<Map<String, dynamic>> transactions = [];

      // Penjualan
      for (var doc in saleSnapshot.docs) {
        final data = doc.data();
        final Timestamp? timestamp = data['date'];
        String timeLabel = '-';
        String dateLabel = '-';
        DateTime? rawDateTime; // **PENTING: Tambahkan ini**

        if (timestamp != null) {
          rawDateTime = timestamp.toDate(); // **PENTING: Simpan DateTime asli**
          timeLabel = DateFormat.Hm().format(rawDateTime) + ' WIB'; // jam
          dateLabel = DateFormat('dd MMM yyyy').format(rawDateTime); // tanggal (gunakan yyyy agar konsisten)
        }

        transactions.add({
          'title': data['menu'] ?? 'Penjualan',
          'date': dateLabel,
          'rawDate': rawDateTime, // **PENTING: Simpan DateTime asli untuk sorting**
          'amount': data['price'] ?? 0,
          'type': timeLabel, // tampilan: jam
          'category': 'Penjualan', // untuk switch filter
        });
      }

      // Pengeluaran
      for (var doc in inventorySnapshot.docs) {
        final data = doc.data();
        final stok = data['stokInv']?.toString() ?? '-';
        final unit = data['unitInv']?.toString() ?? '';
        final stokLabel = '$stok $unit';
        final Timestamp? timestamp = data['date'];
        String dateLabel = '-';
        DateTime? rawDateTime; // **PENTING: Tambahkan ini**

        if (timestamp != null) {
          rawDateTime = timestamp.toDate(); // **PENTING: Simpan DateTime asli**
          dateLabel = DateFormat('dd MMM yyyy').format(rawDateTime); // tanggal (gunakan yyyy agar konsisten)
        }

        transactions.add({
          'title': data['nameInv'] ?? 'Pengeluaran',
          'date': dateLabel,
          'rawDate': rawDateTime, // **PENTING: Simpan DateTime asli untuk sorting**
          'amount': data['total'] ?? 0,
          'type': stokLabel, // tampilan: "1 Kg"
          'category': 'Pengeluaran', // untuk switch filter
        });
      }

      setState(() {
        _balance = totalSale;
        _totalSpending = totalInventory;
        _transactions = transactions;
      });
    } catch (e) {
      print('Gagal mengambil data keuangan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter transaksi berdasarkan _selectedPeriod
    final filteredTransactions = _transactions
        .where((tx) => tx['category'] == _selectedPeriod)
        .toList(); // Konversi ke list untuk bisa diurutkan

    // Urutkan transaksi dari terbaru ke lama berdasarkan 'rawDate'
    // Perhatikan penanganan null jika ada transaksi yang rawDate-nya null (misal, data lama tanpa timestamp)
    filteredTransactions.sort((a, b) {
      final DateTime? dateA = a['rawDate'] as DateTime?;
      final DateTime? dateB = b['rawDate'] as DateTime?;

      // Handle kasus di mana rawDate bisa null
      if (dateA == null && dateB == null) return 0; // Keduanya null, dianggap sama
      if (dateA == null) return 1; // a null, b non-null -> b lebih dulu (a ke belakang)
      if (dateB == null) return -1; // b null, a non-null -> a lebih dulu (b ke belakang)

      // Urutkan dari TERBARU ke LAMA (Descending)
      return dateB.compareTo(dateA);
    });

    return Scaffold(
      bottomNavigationBar: CustomNavbar(currentIndex: 0),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 0.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildSwitchButtonGroup(),
                        const SizedBox(height: 24),
                        // Menampilkan daftar transaksi yang sudah difilter dan diurutkan
                        if (filteredTransactions.isEmpty)
                          Center(
                            child: Text(
                              "Silahkan catat penjualanmu dahulu",
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                color: const Color(0xFF00D09E),
                              ),
                            ),
                          )
                        else
                          ...filteredTransactions.map((tx) {
                          final isPenjualan = tx['category'] == 'Penjualan';
                          // Dapatkan apakah ini transaksi 'Pengeluaran'
                          final isPengeluaran = tx['category'] == 'Pengeluaran'; // <-- Tambahkan ini

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
                              type: !isPenjualan ? '' : tx['type'], // Logika ini sudah kita diskusikan sebelumnya
                              amount: amountFormatted,
                              amountColor: isPenjualan
                                  ? const Color(0xFF0068FF)
                                  : const Color(0xFFFF3B3B),
                              hideSeparators: isPengeluaran, // <-- Teruskan parameter baru ini
                            ),
                          );
                        }).toList(), // Pastikan ini dikonversi ke list untuk spread operator
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

  // Widget _buildTransactionRow (Tidak berubah)
  Widget _buildTransactionRow({
    required String title,
    required String date,
    required String type,
    required String amount,
    required Color amountColor,
    required bool hideSeparators,
  }) {
    final String iconPath = type.isEmpty
        ? ImageConstant.imgN2 // Ikon untuk Penjualan
        : ImageConstant.imgN3; // Ikon untuk Pengeluaran

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

          // --- PERBAIKAN UNTUK GARIS PEMISAH PERTAMA ---
          // Gunakan conditional operator (ternary) atau collection-if
          // Saya akan menggunakan ternary untuk lebih ringkas di sini.
          // Jika hideSeparators adalah true, tampilkan SizedBox(width: 1)
          // Jika hideSeparators adalah false, tampilkan Container garis pemisah
          hideSeparators
              ? const SizedBox(width: 1)
              : Container(
                  width: 1,
                  height: 40,
                  color: const Color(0xFF00D09E),
                ),

          const SizedBox(width: 18),

          // Kondisional untuk menampilkan teks 'type'
          Expanded(
            flex: type.isNotEmpty ? 1 : 0,
            child: type.isNotEmpty
                ? Text(
                    type,
                    style: const TextStyle(
                      color: Color(0xFF052224),
                      fontSize: 13,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      height: 1.15,
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // Jika type kosong, tambahkan spasi ekstra agar kolom amount tidak terlalu jauh
          if (type.isEmpty)
            const SizedBox(width: 18),

          // --- PERBAIKAN UNTUK GARIS PEMISAH KEDUA ---
          hideSeparators
              ? const SizedBox(width: 1)
              : Container(
                  width: 1,
                  height: 40,
                  color: const Color(0xFF00D09E),
                ),

          const SizedBox(width: 18),
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

  // Widget _buildSwitchButtonGroup (Tidak berubah)
  Widget _buildSwitchButtonGroup() {
    final List<String> options = ['Penjualan', 'Pengeluaran'];

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
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF00D09E) : Colors.transparent,
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

// Custom Clipper for the header (Tidak berubah)
class BottomConcaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double curveHeight = 70.0;

    Path path = Path();
    path.moveTo(0, 0); // kiri atas

    path.lineTo(0, size.height);
    path.quadraticBezierTo(
      0, size.height - curveHeight,
      curveHeight, size.height - curveHeight,
    );

    path.lineTo(size.width - curveHeight, size.height - curveHeight);

    path.quadraticBezierTo(
      size.width, size.height - curveHeight,
      size.width, size.height,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// GreenRoundedCard (Tidak berubah)
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