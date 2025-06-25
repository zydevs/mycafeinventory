// lib/screens/income_screen.dart

import 'package:mycafeinventory/routes/app_routes.dart';
import 'package:mycafeinventory/screens/notification_screen.dart';
import 'package:mycafeinventory/utils/notif_service.dart';
import 'package:mycafeinventory/widgets/custom_image_view.dart';
import 'package:flutter/material.dart';
import 'package:mycafeinventory/utils/image_constant.dart';
import 'package:mycafeinventory/widgets/custom_navbar.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mycafeinventory/services/inventory_service.dart'; // Import InventoryService
import 'package:mycafeinventory/services/user_service.dart'; // Import UserService
import 'package:mycafeinventory/services/sales_service.dart'; // Import SalesService

// MyApp is typically in main.dart, but included here for completeness of context
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
            width: 480, // Adjust width as needed for responsive design
            child: IncomeScreen(),
          ),
        ),
      ),
    );
  }
}

// Main class IncomeScreen
class IncomeScreen extends StatefulWidget {
  const IncomeScreen({Key? key}) : super(key: key);

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  String _selectedPeriod = 'Pemasukan'; // default period

  // --- START PERUBAHAN: UID diinisiasi langsung ---
  final String _currentUserId = 'Ft1UBlWgyvuFbfnVZ9od'; // UID yang diinisiasi langsung
  // --- AKHIR PERUBAHAN ---

  final UserService _userService = UserService();
  final SalesService _salesService = SalesService();

  double _balance = 0;
  double _totalSpending = 0; // Represents total inventory spending
  double _totalIncome = 0;

  @override
  void initState() {
    super.initState();
    // Langsung panggil fetchFinancialData dengan UID yang sudah diinisiasi
    _fetchFinancialData(_currentUserId);
  }

  // Fetch financial data (balance and spending) for the given userId
  Future<void> _fetchFinancialData(String userId) async {
    try {
      // Fetch balance from user profile (assuming it's stored directly under user document)
      Map<String, dynamic>? userProfile = await _userService.getUserProfile(userId: userId);
      double userBalance = (userProfile?['balance'] as num?)?.toDouble() ?? 0.0;
      print('User Balance: $userBalance'); // Debug print

      // Fetch total sales (income) using SalesService
      double totalSales = await _salesService.getTotalSales(userId: userId);
      print('Total Sales (Income): $totalSales'); // Debug print

      // Fetch total inventory spending (assuming 'total' in inventory collection represents cost)
      final inventorySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('inventory') // Assuming 'inventory' stores purchases/spending
          .get();

      double totalInventorySpending = inventorySnapshot.docs.fold(0.0, (sum, doc) {
        return sum + (doc.data()['total'] as num? ?? 0).toDouble(); // Assuming 'total' is spending
      });
      print('Total Inventory Spending: $totalInventorySpending'); // Debug print

      setState(() {
        _balance = userBalance;
        _totalIncome = totalSales;
        _totalSpending = totalInventorySpending;
      });
    } catch (e) {
      print('Gagal mengambil data keuangan: $e'); // Debug print
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data keuangan: ${e.toString()}')),
      );
    }
  }

  // Function to sign out the user
  void signUserOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // Navigate to login screen, clear all page history
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.loginScreen, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Column(
        children: [
          // Header section
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
                  // Top row (logo, text, notification, profile)
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
                      // Notif Icon
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
                      const SizedBox(width: 10), // Spacing between icons
                      // Logout/Profile Icon
                      GestureDetector(
                        onTap: () => signUserOut(context),
                        child: CustomImageView(
                          imagePath: ImageConstant.imgProfile4,
                          height: 57,
                          width: 53,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  // Balance and Spending Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Total Penjualan (Income)
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
                      // Divider
                      Container(width: 2, height: 50, color: Colors.white),
                      // Total Pengeluaran (Spending)
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
          // Body (form widget) - always pass the hardcoded userId
          Expanded(
            child: _FormWidget(
              selectedPeriod: _selectedPeriod,
              userId: _currentUserId, // Pass the hardcoded UID
            ),
          ),
        ],
      ),
    );
  }
}

// _FormWidget class
class _FormWidget extends StatefulWidget {
  final String selectedPeriod;
  final String userId; // userId is now guaranteed to be available

  const _FormWidget({
    Key? key,
    required this.selectedPeriod,
    required this.userId,
  }) : super(key: key);

  @override
  State<_FormWidget> createState() => _FormWidgetState();
}

class _FormWidgetState extends State<_FormWidget> {
  String? _selectedCoffeeMenu; // To store selected coffee name
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _methodController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final NumberFormat _currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  List<Map<String, dynamic>> _coffeeMenus = []; // List to store fetched coffee menus and their prices

  final InventoryService _inventoryService = InventoryService(); // Instantiate InventoryService
  final List<String> _paymentMethods = ['Cash', 'Card'];

  @override
  void initState() {
    super.initState();
    _fetchCoffeeMenus(); // Fetch coffee menus when the widget initializes
    _methodController.text = _paymentMethods.first; 
  }

  // Fetch coffee menus and their prices from Firebase 'recipes' collection
  Future<void> _fetchCoffeeMenus() async {
    print('Fetching menus for user: ${widget.userId}'); // Debug print
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('recipes') // Pastikan path ini benar
          .get();

      print('Snapshot docs count: ${snapshot.docs.length}'); // Debug print: Cek apakah ada dokumen ditemukan

      List<Map<String, dynamic>> fetchedMenus = [];
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>; // Explicit casting
        print('Processing doc: ${doc.id}, data: $data'); // Debug print: Lihat data apa yang dibaca

        // Pastikan field 'price' ada dalam dokumen resep
        if (data.containsKey('price')) {
          fetchedMenus.add({
            'name': doc.id, // ID dokumen adalah nama kopi
            'price': (data['price'] as num?)?.toDouble() ?? 0.0, // Ambil harga
          });
        } else {
          print('Warning: Dokumen ${doc.id} di koleksi recipes tidak memiliki field "price".');
        }
      }

      setState(() {
        _coffeeMenus = fetchedMenus;
        print('Coffee menus after fetch: $_coffeeMenus'); // Debug print: Verifikasi list terisi
        if (_coffeeMenus.isNotEmpty) {
          _selectedCoffeeMenu = _coffeeMenus.first['name']; // Pilih item pertama
          _priceController.text = _currencyFormatter.format(_coffeeMenus.first['price']); // Set harganya
          print('Selected coffee menu (initially): $_selectedCoffeeMenu, Price: ${_priceController.text}'); // Debug print
        } else {
          _selectedCoffeeMenu = null; // Pastikan null jika tidak ada menu
          _priceController.clear();
          print('Tidak ada menu kopi ditemukan, dropdown akan kosong.'); // Debug print
        }
      });
    } catch (e) {
      print('Error fetching coffee menus: $e'); // Debug print
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat menu kopi: ${e.toString()}')),
      );
    }
  }

  // Save transaction and deduct stock
  Future<void> saveTransaction() async {
    if (_selectedCoffeeMenu == null) {
      Get.snackbar(
        "Error",
        "Silakan pilih menu kopi terlebih dahulu.",
        colorText: Colors.white,
        backgroundColor: Colors.red,
      );
      return;
    }

    try {
      final rawPrice = _priceController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final price = double.tryParse(rawPrice) ?? 0.0;
      final method = _methodController.text.trim();
      final date = _dateController.text.isNotEmpty
          ? DateTime.parse(_dateController.text)
          : DateTime.now();

      // Use InventoryService to process the order, which also handles sale recording
      await _inventoryService.processCoffeeOrder(
        coffeeName: _selectedCoffeeMenu!,
        userId: widget.userId,
        coffeePrice: price,
        paymentMethod: method,
      );

      // Refresh financial data in the parent widget after successful transaction
      if (context.findAncestorStateOfType<_IncomeScreenState>() != null) {
        context.findAncestorStateOfType<_IncomeScreenState>()!._fetchFinancialData(widget.userId);
      }

      // Reset form (clear method, date)
      _methodController.clear();
      _dateController.clear();
      // Keep _selectedCoffeeMenu and _priceController.text as they are (last selected menu)
      // or reset them if desired (e.g., _selectedCoffeeMenu = null; _priceController.clear();)

      Get.snackbar(
        "Penjualan Berhasil",
        "Data berhasil disimpan dan stok diperbarui!",
        colorText: Colors.white,
        backgroundColor: const Color(0xFF00D09E),
      );
    } catch (e) {
      print('Gagal menyimpan data atau mengurangi stok: $e'); // Debug print
      Get.snackbar(
        "Terjadi Kesalahan",
        'Gagal memproses pesanan: ${e.toString()}',
        colorText: Colors.white,
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _methodController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _FormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-fetch menus only if userId changes (which is unlikely with hardcoded UID, but good practice)
    if (oldWidget.userId != widget.userId) {
      _methodController.clear();
      _dateController.clear();
      _selectedCoffeeMenu = null; // Clear selected menu
      _priceController.clear(); // Clear price
      _fetchCoffeeMenus(); // Re-fetch menus for the new user
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
              if (widget.selectedPeriod == 'Pemasukan') ...[
                // Dropdown for Coffee Menu
                _CustomDropdownField(
                  label: 'Menu Kopi',
                  leftIconPath: ImageConstant.imgIn1,
                  value: _selectedCoffeeMenu,
                  items: _coffeeMenus.map((menu) {
                    return DropdownMenuItem<String>(
                      value: menu['name'],
                      child: Text(menu['name']),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCoffeeMenu = newValue;
                      // Find the selected coffee's price and update the price controller
                      final selectedMenuData = _coffeeMenus.firstWhere(
                          (menu) => menu['name'] == newValue,
                          orElse: () => {'price': 0.0});
                      _priceController.text = _currencyFormatter.format(selectedMenuData['price']);
                    });
                  },
                ),
                const SizedBox(height: 20),
                // Price field (read-only)
                _CustomTextField(
                  controller: _priceController,
                  label: 'Price',
                  leftIconPath: ImageConstant.imgIn1,
                  keyboardType: TextInputType.number,
                  inputFormatters: [currencyInputFormatter()],
                  readOnly: true, // Make price field read-only
                ),
                const SizedBox(height: 20),
                // Method field
                 _CustomDropdownField(
                  label: 'Cash/Card',
                  leftIconPath: ImageConstant.imgIn2,
                  value: _methodController.text.isEmpty
                      ? null
                      : _methodController.text, // Menggunakan nilai dari controller
                  items: _paymentMethods.map((String method) {
                    return DropdownMenuItem<String>(
                      value: method,
                      child: Text(method),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      if (newValue != null) {
                        _methodController.text = newValue; // Perbarui controller dengan nilai yang dipilih
                      }
                    });
                  },
                ),
                const SizedBox(height: 20),
                // Date field
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
              ],
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

  // Helper for currency formatting
  TextInputFormatter currencyInputFormatter() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
      if (newText.isEmpty) return newValue.copyWith(text: '');
      final formatted = _currencyFormatter.format(int.parse(newText));
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    });
  }
}

// Reusable Custom TextField Widget (updated to fit dropdown)
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

// New Custom Dropdown Field Widget
class _CustomDropdownField extends StatelessWidget {
  final String label;
  final String? leftIconPath;
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  const _CustomDropdownField({
    Key? key,
    required this.label,
    this.leftIconPath,
    required this.value,
    required this.items,
    required this.onChanged,
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
              right: 16.0, // Add right padding for dropdown icon
            ),
            child: DropdownButtonFormField<String>(
              value: value,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: label,
                hintStyle: const TextStyle(
                  color: Color(0xFF00D09E),
                  fontSize: 16,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              dropdownColor: Colors.white, // Background color of the dropdown list
              style: const TextStyle(
                color: Color(0xFF00D09E),
                fontSize: 16,
              ),
              items: items,
              onChanged: onChanged,
              isExpanded: true, // Make dropdown take full width
              iconEnabledColor: const Color(0xFF00D09E), // Color of the dropdown icon
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable Button Widget
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


// Custom Clipper for the header (no changes here)
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