import 'package:mycafeinventory/routes/app_routes.dart';
import 'package:mycafeinventory/screens/notification_screen.dart';
import 'package:mycafeinventory/services/sales_service.dart';
import 'package:mycafeinventory/services/user_service.dart';
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

// --- Model Data Inventaris ---
class Inventory {
  String? id; // ID dokumen dari Firestore, bisa null jika baru
  String nameInv;
  double stokInv;
  String unitInv;
  double priceInv;
  DateTime date; // Tanggal ditambahkan ke model

  Inventory({
    this.id,
    required this.nameInv,
    required this.stokInv,
    required this.unitInv,
    required this.priceInv,
    required this.date,
  });

  // Factory constructor untuk membuat objek Inventory dari Firestore DocumentSnapshot
  factory Inventory.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Inventory(
      id: doc.id,
      nameInv: data['nameInv'] ?? '',
      stokInv: (data['stokInv'] ?? 0).toDouble(),
      unitInv: data['unitInv'] ?? '',
      priceInv: (data['priceInv'] ?? 0).toDouble(),
      // Konversi Timestamp dari Firestore ke DateTime
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Metode untuk mengkonversi objek Inventory ke Map untuk Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nameInv': nameInv,
      'stokInv': stokInv,
      'unitInv': unitInv,
      'priceInv': priceInv,
      'date': Timestamp.fromDate(date), // Konversi DateTime ke Timestamp
    };
  }
}
// --- Akhir Model Data Inventaris ---


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
      home: SafeArea(
        child: Center(
          child: SizedBox(
            width: 480,
            child: InventoryScreen(),
          ),
        ),
      ),
    );
  }
}

// Main class InventoryScreen
// ignore: must_be_immutable
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _selectedPeriod = 'Pemasukan'; // default period

  // Inisiasi UID secara langsung seperti yang diminta
  final String _currentUserId = 'Ft1UBlWgyvuFbfnVZ9od';

  final UserService _userService = UserService();
  final SalesService _salesService = SalesService();

  double _totalIncome = 0;
  double _totalSpending = 0;
  double _balance = 0;

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
    final userDoc = FirebaseFirestore.instance.collection('users').doc(_currentUserId);

    try {
      final saleSnapshot = await userDoc.collection('sale').get();
      final inventorySnapshot = await userDoc.collection('inventory').get();

      double totalSale = saleSnapshot.docs.fold(0.0, (sum, doc) {
        return sum + (doc.data()['price'] ?? 0).toDouble();
      });

      double totalInventory = inventorySnapshot.docs.fold(0.0, (sum, doc) {
        return sum + (doc.data()['total'] ?? 0).toDouble();
      });

      // Fetch total sales (income) using SalesService
      double totalSales = await _salesService.getTotalSales(userId: userId);
      print('Total Sales (Income): $totalSales'); // Debug print

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
                            'Catat Inventory',
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

                  // Info Saldo dan Pengeluaran
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

                  SizedBox(height: 70),
                ],
              ),
            ),
          ),

          // Body selanjutnya (widget lainnya)
          Expanded(
            child: _FormWidget(
              selectedPeriod: _selectedPeriod,
              userId: _currentUserId, // Meneruskan UID yang diinisiasi langsung
            ),
          ),
        ],
      ),
    );
  }
}

// class body
class _FormWidget extends StatefulWidget {
  final String selectedPeriod;
  final String userId; // Menerima userId dari parent

  const _FormWidget({Key? key, required this.selectedPeriod, required this.userId}) : super(key: key);

  @override
  State<_FormWidget> createState() => _FormWidgetState();
}

// Form Widget
class _FormWidgetState extends State<_FormWidget> {
  // Controllers for all input fields
  final _stokController = TextEditingController();
  // Tidak perlu controller untuk unit lagi karena akan jadi dropdown
  final _priceController = TextEditingController();
  final _dateController = TextEditingController();
  final _currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  final List<String> _unitCategory = ['kg', 'liter']; // Pilihan untuk satuan
  String? _selectedUnit; // Nilai terpilih untuk dropdown satuan

  List<String> _inventoryNames = []; // List of all unique inventory names
  String? _selectedInventoryName; // Currently selected inventory name from dropdown

  @override
  void initState() {
    super.initState();
    // Set default date to today
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    // Atur nilai default untuk dropdown satuan
    _selectedUnit = _unitCategory.first; // Pilih 'kg' sebagai default
    // Fetch unique inventory names when the widget initializes
    _fetchInventoryNames();
  }

  // Fetches all unique inventory names from Firestore's 'inventory' collection
  Future<void> _fetchInventoryNames() async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(widget.userId);

    try {
      final querySnapshot = await userDoc.collection('inventory').get();
      Set<String> uniqueNames = {}; // Use a Set to store unique names
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('nameInv') && data['nameInv'] is String && (data['nameInv'] as String).isNotEmpty) {
          uniqueNames.add(data['nameInv']);
        }
      }
      setState(() {
        _inventoryNames = uniqueNames.toList()..sort(); // Convert to List and sort alphabetically
        print('Fetched inventory names: $_inventoryNames'); // Debug: Cek nama yang diambil

        // Atur nilai default untuk dropdown jika ada nama inventaris
        if (_inventoryNames.isNotEmpty) {
          _selectedInventoryName = _inventoryNames.first;
          print('Default selected inventory name: $_selectedInventoryName'); // Debug: Cek nama yang dipilih default
        } else {
          _selectedInventoryName = null;
          print('No inventory names found, dropdown will be empty.'); // Debug: Tidak ada nama
        }
        // Kosongkan field lainnya saat daftar nama inventaris dimuat atau diperbarui
        _clearFormFields();
      });
    } catch (e) {
      print('Gagal mengambil daftar nama inventaris: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat daftar nama inventaris: ${e.toString()}')),
      );
    }
  }

  // Clears all form fields (stok, harga satuan, tanggal)
  void _clearFormFields() {
    _stokController.clear();
    _priceController.clear();
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now()); // Set tanggal ke hari ini
    _selectedUnit = _unitCategory.first; // Reset dropdown satuan ke default
  }

  Future<void> saveInventory() async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(widget.userId);
    final inventoryCollectionRef = userDoc.collection('inventory');

    try {
      if (_selectedInventoryName == null || _selectedInventoryName!.isEmpty) {
        Get.snackbar("Input Gagal", "Mohon pilih nama inventori dari daftar.", backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
      if (_selectedUnit == null || _selectedUnit!.isEmpty) {
        Get.snackbar("Input Gagal", "Mohon pilih satuan.", backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      final name = _selectedInventoryName!; // Nama inventori diambil dari yang dipilih di dropdown
      final priceText = _priceController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final stokText = _stokController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final unit = _selectedUnit!; // Satuan diambil dari dropdown
      final dateString = _dateController.text.trim();

      final price = double.tryParse(priceText) ?? 0;
      final stok = double.tryParse(stokText) ?? 0;
      final total = price * stok;
      final date = DateTime.tryParse(dateString);

      if (price == 0 || stok == 0 || date == null) { // 'unit' sudah dicek null/empty di atas
        Get.snackbar("Input Gagal", "Mohon lengkapi Stok, Harga Satuan, dan Tanggal dengan benar.", backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      final inventoryData = {
        'nameInv': name,
        'priceInv': price,
        'stokInv': stok,
        'unitInv': unit, // Simpan nilai dari dropdown satuan
        'total': total,
        'date': Timestamp.fromDate(date),
      };

      // Tambahkan dokumen baru ke koleksi 'inventory'
      await inventoryCollectionRef.add(inventoryData);

      Get.snackbar("Inventaris", "Data berhasil disimpan.", backgroundColor: const Color(0xFF00D09E), colorText: Colors.white);

      // Setelah berhasil disimpan, kosongkan kembali form untuk input selanjutnya
      _clearFormFields();
      // Jaga agar _selectedInventoryName tetap terpilih jika diinginkan, atau set ke null
      // setState(() { _selectedInventoryName = null; }); // Jika ingin dropdown kembali ke "Pilih Nama Inventori"
    } catch (e) {
      print('Gagal menyimpan data inventaris: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat menyimpan data: $e')),
      );
    }
  }

  @override
  void dispose() {
    _stokController.dispose();
    // _unitController.dispose(); // Tidak lagi dibutuhkan karena unit adalah dropdown
    _priceController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomNavbar(currentIndex: 3),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Dropdown untuk Nama Inventori
              Container(
                width: 400,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF00D09E)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: DropdownButtonHideUnderline(
                  child: DropdownButtonFormField<String>(
                    value: _selectedInventoryName,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Pilih Nama Inventori',
                      hintStyle: const TextStyle(
                        color: Color(0xFF00D09E),
                        fontSize: 16,
                      ),
                      prefixIcon: CustomImageView(
                        imagePath: ImageConstant.imgIn1, // Ikon untuk nama inventori
                        width: 50,
                        height: 50,
                      ),
                      prefixIconConstraints: BoxConstraints(minWidth: 48, minHeight: 48),
                    ),
                    isExpanded: true,
                    style: const TextStyle(
                      color: Color(0xFF00D09E),
                      fontSize: 16,
                    ),
                    items: _inventoryNames.map((String name) {
                      return DropdownMenuItem<String>(
                        value: name,
                        child: Text(name),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedInventoryName = newValue;
                        // Kosongkan field lainnya saat pemilihan nama inventori berubah
                        _clearFormFields();
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Mohon pilih nama inventori';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _CustomTextField(
                controller: _stokController,
                label: 'Stok',
                leftIconPath: ImageConstant.imgIn1,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 20),
              // Dropdown untuk Satuan
              Container(
                width: 400,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF00D09E)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: DropdownButtonHideUnderline(
                  child: DropdownButtonFormField<String>(
                    value: _selectedUnit,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Pilih Satuan',
                      hintStyle: const TextStyle(
                        color: Color(0xFF00D09E),
                        fontSize: 16,
                      ),
                      prefixIcon: CustomImageView(
                        imagePath: ImageConstant.imgIn2, // Ikon untuk satuan
                        width: 50,
                        height: 50,
                      ),
                      prefixIconConstraints: BoxConstraints(minWidth: 48, minHeight: 48),
                    ),
                    isExpanded: true,
                    style: const TextStyle(
                      color: Color(0xFF00D09E),
                      fontSize: 16,
                    ),
                    items: _unitCategory.map((String unit) {
                      return DropdownMenuItem<String>(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedUnit = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Mohon pilih satuan';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _CustomTextField(
                controller: _priceController,
                label: 'Harga Satuan',
                leftIconPath: ImageConstant.imgIn2,
                keyboardType: TextInputType.number,
                inputFormatters: [currencyInputFormatter()],
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
                    initialDate: _dateController.text.isNotEmpty
                        ? DateTime.parse(_dateController.text)
                        : DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: Color(0xFF00D09E),
                            onPrimary: Colors.white,
                            onSurface: Colors.black,
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: Color(0xFF00D09E),
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (pickedDate != null) {
                    String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                    setState(() {
                      _dateController.text = formattedDate;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              _buildButton(
                label: 'Simpan Data Baru',
                onPressed: () {
                  saveInventory();
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi helper untuk tombol dan formatter
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
      String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
      if (newText.isEmpty) {
        return newValue.copyWith(text: '');
      }
      final formatted = _currencyFormatter.format(int.parse(newText));
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    });
  }
}

// _CustomTextField (tidak berubah)
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

// Custom Clipper for the header
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
