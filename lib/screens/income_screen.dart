import 'package:acisku/routes/app_routes.dart';
import 'package:acisku/screens/notification_screen.dart';
import 'package:acisku/utils/notif_service.dart';
import 'package:acisku/widgets/custom_image_view.dart';
import 'package:flutter/material.dart';
import 'package:acisku/utils/image_constant.dart';
import 'package:acisku/widgets/custom_navbar.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transaction',
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
            child: IncomeScreen(),
          ),
        ),
      ),
    );
  }
}

// main class
// ignore: must_be_immutable
class IncomeScreen extends StatefulWidget {
  const IncomeScreen({Key? key}) : super(key: key);

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  String _selectedPeriod = 'Pemasukan'; // default

  double _totalIncome = 0;
  double _totalSpending = 0;
  double _balance = 0;

  void signUserOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    // Navigasi ke login screen, hapus semua riwayat halaman
    Navigator.pushNamed(context, AppRoutes.loginScreen);
  }

  // Header
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Column(
        children: [
          // Bagian header yang di-clip
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
                  // Row atas (logo, teks, notifikasi)
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
                            'Catat\nPenjualan',
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

                  // Info Saldo dan Pengeluaran
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Total Saldo
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
                                'Total Saldo',
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
                      // Pemisah
                      Container(width: 2, height: 50, color: Colors.white),
                      // Total Pemasukan
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
                      // Pemisah
                      Container(width: 2, height: 50, color: Colors.white),
                      // Total Pengeluaran
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

                  SizedBox(height: 70),
                ],
              ),
            ),
          ),

          // Body selanjutnya (widget lainnya)
          Expanded(
             child: _FormWidget(selectedPeriod: _selectedPeriod),
          ),
        ],
      ),
    );
  }

  // Get Data
  @override
  void initState() {
    super.initState();
    _fetchFinancialData();
  }

  Future<void> _fetchFinancialData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

    try {
      // Ambil balance langsung
      final userSnapshot = await userDoc.get();
      _balance = (userSnapshot.data()?['balance'] ?? 0).toDouble();

      // Hitung total income
      final incomeSnapshot = await userDoc.collection('income').get();
      _totalIncome = incomeSnapshot.docs.fold(0, (sum, doc) {
        return sum + (doc.data()['amount'] ?? 0).toDouble();
      });

      // Hitung total spending
      final spendingSnapshot = await userDoc.collection('spending').get();
      _totalSpending = spendingSnapshot.docs.fold(0, (sum, doc) {
        return sum + (doc.data()['amount'] ?? 0).toDouble();
      });

      setState(() {});
    } catch (e) {
      print('Gagal mengambil data keuangan: $e');
    }
  }

}

// class body
class _FormWidget extends StatefulWidget {
  final String selectedPeriod;

  const _FormWidget({Key? key, required this.selectedPeriod}) : super(key: key);

  @override
  State<_FormWidget> createState() => _FormWidgetState();
}

// Form Widget
class _FormWidgetState extends State<_FormWidget> {
  final _incomeController = TextEditingController();
  final _expenseController = TextEditingController();
  final _limitController = TextEditingController();
  final _categoryController = TextEditingController();
  final _dateController = TextEditingController();
  final _currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  Future<void> saveTransaction() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    try {
      final rawIncome = _incomeController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final rawExpense = _expenseController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final rawLimit = _limitController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final source = _categoryController.text;
      final date = _dateController.text.isNotEmpty
          ? DateTime.parse(_dateController.text)
          : DateTime.now();

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);
        double balance = (snapshot.data()?['balance'] ?? 0).toDouble();

        if (widget.selectedPeriod == 'Pemasukan') {
          final amount = double.parse(rawIncome);
          transaction.set(
            userRef.collection('income').doc(),
            {
              'amount': amount,
              'source': source,
              'date': Timestamp.fromDate(date),
            },
          );
          balance += amount;
          transaction.update(userRef, {'balance': balance});
          Get.snackbar(
            "Pemasukan",
            "Berhasil Disimpan",
            colorText: Colors.white,
            backgroundColor: Color(0xFF00D09E),
          );

          // add notif
          await addNotification(
            userId: user.uid,
            title: 'Pemasukanmu dicatat!',
            message: 'Hallo, pemasukanmu bulan ini berhasil dicatat! Kelola keuanganmu dengan baik ya!',
            type: 'income',
          );
        }

        if (widget.selectedPeriod == 'Pengeluaran') {
          final amount = double.parse(rawExpense);
          transaction.set(
            userRef.collection('spending').doc(),
            {
              'amount': amount,
              'source': source,
              'date': Timestamp.fromDate(date),
            },
          );
          balance -= amount;
          transaction.update(userRef, {'balance': balance});
          Get.snackbar(
            "Pengeluaran",
            "Berhasil Disimpan",
            colorText: Colors.white,
            backgroundColor: Color(0xFF00D09E),
          );

          // add notif
          await addNotification(
            userId: user.uid,
            title: 'Pengeluaranmu dicatat!',
            message: 'Hallo, pengeluaranmu berhasil dicatat! Kelola keuanganmu dengan baik ya!',
            type: 'spending',
          );

          // notif warning limit
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (userDoc.exists) {
            double limit = userDoc.data()?['limitSpend']?.toDouble() ?? 0.0;
            if (amount > limit) {
              await addNotification(
                userId: user.uid,
                title: 'Peringatan! Pengeluaran melebihi Limit!',
                message: 'Hallo, Pengeluaran melebihi limit! Kelola keuanganmu lebih baik ya',
                type: 'limit-warning',
              );
            }
          }
          
        }

        if (widget.selectedPeriod == 'Limit') {
          final limit = double.parse(rawLimit);
          transaction.update(userRef, {'limitSpend': limit});
          Get.snackbar(
            "Limit",
            "Berhasil Disimpan",
            colorText: Colors.white,
            backgroundColor: Color(0xFF00D09E),
          );
          // add notif
          await addNotification(
            userId: user.uid,
            title: 'Limit Pengeluaran Tersimpan!',
            message: 'Hallo, Kamu telah menetapkan limit pengeluaran bulan ini.',
            type: 'limit',
          );
        }

      });

      // Bersihkan form
      _incomeController.clear();
      _expenseController.clear();
      _limitController.clear();
      _categoryController.clear();
      _dateController.clear();

      // Navigator.pushNamed(context, AppRoutes.transactionIncome);
    } catch (e) {
      print('Gagal menyimpan data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat menyimpan data.')),
      );
    }
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _expenseController.dispose();
    _limitController.dispose();
    _categoryController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _FormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedPeriod != widget.selectedPeriod) {
      _incomeController.clear();
      _expenseController.clear();
      _limitController.clear();
      _categoryController.clear();
      _dateController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomNavbar(currentIndex: 1),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              if (widget.selectedPeriod == 'Pemasukan')
                _CustomTextField(
                  controller: _incomeController,
                  label: 'Menu',
                  leftIconPath: ImageConstant.imgIn1,
                  keyboardType: TextInputType.number,
                  inputFormatters: [currencyInputFormatter()],
                  // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 20),
                _CustomTextField(
                  controller: _expenseController,
                  label: 'Jumlah',
                  leftIconPath: ImageConstant.imgIn1,
                  keyboardType: TextInputType.number,
                  inputFormatters: [currencyInputFormatter()],
                  // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 20),
                _CustomTextField(
                  controller: _categoryController,
                  label: 'Cash/Card',
                  leftIconPath: ImageConstant.imgIn2,
                ),
                const SizedBox(height: 20),
                _CustomTextField(
                  controller: _dateController,
                  label: 'Tanggal',
                  leftIconPath: ImageConstant.imgIn2,
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                      setState(() {
                        _dateController.text = formattedDate;
                      });
                    }
                  },
                ),

                const SizedBox(height: 25),
              
              _buildButton(
                label: 'Simpan',
                onPressed: () {
                  saveTransaction();
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required VoidCallback onPressed,
  }) {
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

  TextInputFormatter currencyInputFormatter() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      // Hapus semua karakter non-digit
      String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

      // Cegah string kosong atau 0
      if (newText.isEmpty) return newValue.copyWith(text: '');

      // Format ulang ke dalam format uang
      final formatted = _currencyFormatter.format(int.parse(newText));

      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    });
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? leftIconPath;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final VoidCallback? onTap;

  const _CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.leftIconPath,
    this.keyboardType,
    this.inputFormatters,
    this.readOnly = false,
    this.onTap,
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
                  width: 50,
                  height: 50,
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.only(
              left: leftIconPath != null ? 48.0 : 16.0,
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              readOnly: readOnly,
              onTap: onTap,
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
        ],
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