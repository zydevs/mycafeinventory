import 'package:mycafeinventory/widgets/custom_image_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:mycafeinventory/utils/image_constant.dart';
import 'package:google_generative_ai/google_generative_ai.dart'; // Import paket Gemini

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatbot',
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
            width: 480, // Sesuaikan lebar sesuai kebutuhan desain Anda
            child: ChatbotScreen(),
          ),
        ),
      ),
    );
  }
}

// main class
// ignore: must_be_immutable
class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _BodyWidget()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          color: const Color(0xFF00D09E),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderTopBar(),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderTopBar() {
    return Stack(
      children: [
        // Ikon-ikon di kiri
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: CustomImageView(
                imagePath: ImageConstant.imgBack,
                height: 30,
                width: 50,
              ),
            ),
            const SizedBox(width: 10),
            CustomImageView(
              imagePath: ImageConstant.imgChatbot,
              height: 45,
              width: 45,
            ),
            const SizedBox(width: 10),
            const Text(
              'Chatbot My Cafe Inventory',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ],
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
  final EdgeInsets pagePadding = const EdgeInsets.symmetric(horizontal: 20);
  final List<Map<String, dynamic>> _chatMessages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false; // State untuk loading indicator

  // --------------------------------------------------------------------------
  // TAHAP 5: PENGEMBANGAN MODEL CHATBOT (INTEGRASI GEMINI API)
  // --------------------------------------------------------------------------
  final String _geminiApiKey = "AIzaSyAEq89rbegEVk1-g3XCHwRA21viZL_8UqQ";
  late final GenerativeModel _model;

  @override
  void initState() {
    super.initState();
    // Inisialisasi model Gemini
    _model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: _geminiApiKey);
    // Pesan sambutan awal dari bot
    _chatMessages.add({
      'text': 'Halo! Saya asisten kafe Anda. Apa yang bisa saya bantu terkait keuangan dan inventaris?',
      'isBot': true
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading) return; // Jangan kirim jika kosong atau sedang loading

    setState(() {
      // Tambahkan pesan user ke daftar chat
      _chatMessages.add({'text': text.trim(), 'isBot': false});
      _controller.clear();
      _isLoading = true; // Set loading menjadi true
    });

    _scrollToBottom();

    String botReply = 'Maaf, terjadi kesalahan saat memproses permintaan Anda. Silakan coba lagi.'; // Pesan default error
    try {
      // Panggil fungsi untuk mendapatkan respons dari bot (Gemini)
      botReply = await _getBotResponse(text.trim());
    } catch (e) {
      print('Error getting bot response: $e'); // Log error untuk debugging
    } finally {
      setState(() {
        // Tambahkan respons bot ke daftar chat
        _chatMessages.add({
          'text': botReply,
          'isBot': true,
        });
        _isLoading = false; // Set loading menjadi false setelah respons diterima
      });
      _scrollToBottom();
    }
  }

  // Fungsi untuk mendapatkan respons dari bot (sekarang didukung Gemini)
  // Ini mencakup TAHAP 2: PENGUMPULAN & PRA-PEMROSESAN DATA (Data Real-time dari Firestore)
  // Serta TAHAP 3: ANOTASI DATA (Implicit via Prompt Engineering Gemini)
  // Dan TAHAP 4: DESAIN SISTEM & ARSITEKTUR (Retrieval-Augmented Generation)
  // Dan TAHAP 5: PENGEMBANGAN MODEL CHATBOT (Memanfaatkan LLM Gemini melalui API)
  Future<String> _getBotResponse(String question) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return 'Anda belum login. Silakan login untuk menggunakan fitur ini.';
    }

    final firestore = FirebaseFirestore.instance;
    // Mengatur userId secara eksplisit ke ID yang diminta untuk demo.
    // PERHATIAN: Di produksi, ini harus dinamai berdasarkan user yang sedang login.
    final String userId = 'Ft1UBlWgyvuFbfnVZ9od';

    // --- PENGUMPULAN DATA REAL-TIME DARI FIRESTORE ---
    // Data Pengguna (balance, limitSpend, username)
    DocumentSnapshot userDoc;
    try {
      userDoc = await firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        return 'Data pengguna untuk ID $userId tidak ditemukan. Pastikan Anda memiliki entri di koleksi "users" dengan ID ini.';
      }
    } catch (e) {
      print('Error fetching user document: $e');
      return 'Terjadi kesalahan saat mengambil data pengguna.';
    }

    final userData = userDoc.data() as Map<String, dynamic>;
    final balance = (userData['balance'] is num) ? userData['balance'] : num.tryParse(userData['balance'].toString()) ?? 0;
    final limitSpend = (userData['limitSpend'] is num) ? userData['limitSpend'] : num.tryParse(userData['limitSpend']?.toString() ?? '0') ?? 0;
    final username = userData['username'] ?? 'Pengguna';

    // Data Pemasukan & Pengeluaran Mingguan & Total
    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7));

    num weeklyIncome = 0;
    try {
      final incomeSnapshot = await firestore.collection('users').doc(userId).collection('income').get();
      for (var doc in incomeSnapshot.docs) {
        final date = (doc['date'] as Timestamp).toDate();
        if (date.isAfter(oneWeekAgo)) {
          final amount = doc['amount'];
          weeklyIncome += (amount is num ? amount : num.tryParse(amount.toString()) ?? 0);
        }
      }
    } catch (e) {
      print('Error fetching income data: $e');
    }

    num weeklySpending = 0;
    num totalSpending = 0;
    try {
      final spendingSnapshot = await firestore.collection('users').doc(userId).collection('spending').get();
      for (var doc in spendingSnapshot.docs) {
        final date = (doc['date'] as Timestamp).toDate();
        final amount = doc['amount'];
        final currentAmount = (amount is num ? amount : num.tryParse(amount.toString()) ?? 0);
        totalSpending += currentAmount;
        if (date.isAfter(oneWeekAgo)) {
          weeklySpending += currentAmount;
        }
      }
    } catch (e) {
      print('Error fetching spending data: $e');
    }

    // Data Inventaris (stok saat ini dari pencatatan inventaris baru)
    Map<String, num> currentInventoryStock = {};
    num totalInventoryPurchaseValue = 0;
    try {
      // Ambil log inventaris dan hitung stok saat ini
      final inventorySnapshot = await firestore.collection('users').doc(userId).collection('inventory').get();
      for (var doc in inventorySnapshot.docs) {
        final data = doc.data();
        final nameInv = data['nameInv'].toString();
        final stokChange = (data['stokInv'] is num ? data['stokInv'] : num.tryParse(data['stokInv'].toString()) ?? 0);
        final itemTotal = (data['total'] is num ? data['total'] : num.tryParse(data['total']?.toString() ?? '0') ?? 0);

        // Update stok saat ini: asumsi stokInv merepresentasikan perubahan, dan kita ingin tahu stok kumulatif
        currentInventoryStock.update(nameInv, (value) => value + stokChange, ifAbsent: () => stokChange);
        totalInventoryPurchaseValue += itemTotal;
      }
    } catch (e) {
      print('Error fetching inventory data: $e');
    }

    // Data Resep
    List<Map<String, dynamic>> recipes = [];
    try {
      final recipesSnapshot = await firestore.collection('users').doc(userId).collection('recipes').get();
      for (var doc in recipesSnapshot.docs) {
        final data = doc.data();
        Map<String, dynamic> recipe = {'name': doc.id, 'price': data['price']};
        data.forEach((key, value) {
          if (key != 'price') {
            recipe[key] = value;
          }
        });
        recipes.add(recipe);
      }
    } catch (e) {
      print('Error fetching recipes data: $e');
    }

    // Data Penjualan (dari setiap transaksi kasir)
    num totalSalesRevenue = 0;
    List<Map<String, dynamic>> sales = [];
    try {
      final allSalesSnapshot = await firestore.collection('users').doc(userId).collection('sales').get();
      for (var doc in allSalesSnapshot.docs) {
        final data = doc.data();
        final itemPrice = (data['price'] is num ? data['price'] : num.tryParse(data['price'].toString()) ?? 0);
        totalSalesRevenue += itemPrice; // Akumulasi total penjualan semua produk

        // Ambil 10 penjualan terakhir untuk konteks umum
        if (sales.length < 10) {
          sales.add({
            'menu': data['menu'],
            'price': itemPrice,
            'date': (data['date'] as Timestamp).toDate(),
          });
        }
      }
      sales.sort((a, b) => b['date'].compareTo(a['date']));
    } catch (e) {
      print('Error fetching sales data: $e');
    }

    // --------------------------------------------------------------------------
    // TAHAP 3: ANOTASI DATA (IMPLICIT VIA PROMPT ENGINEERING GEMINI)
    // TAHAP 4: DESAIN SISTEM & ARSITEKTUR (RETRIEVAL-AUGMENTED GENERATION)
    // TAHAP 5: PENGEMBANGAN MODEL CHATBOT (PROMPT ENGINEERING UNTUK GEMINI)
    // --------------------------------------------------------------------------
    final StringBuffer prompt = StringBuffer();
    prompt.writeln('Anda adalah asisten AI yang cerdas dan informatif untuk manajemen kafe, khusus untuk membantu pengguna dengan data keuangan dan inventaris mereka. ');
    prompt.writeln('Saya akan memberikan Anda informasi terkini mengenai kondisi keuangan dan inventaris kafe saya. ');
    prompt.writeln('Tolong jawab pertanyaan saya dengan akurat berdasarkan data yang diberikan dan berikan saran yang relevan.');
    prompt.writeln('Jawablah dengan bahasa yang ramah, ringkas, dan langsung pada inti pertanyaan. Jangan menambahkan informasi yang tidak diminta.');
    prompt.writeln('Jika pertanyaan tidak relevan dengan data yang tersedia, katakan bahwa Anda tidak dapat membantu atau pertanyaan tidak dikenali.');
    prompt.writeln('Jika ada stok yang hampir habis, sebutkan nama itemnya.');
    prompt.writeln('');
    prompt.writeln('--- Data Kafe Saat Ini ---');
    prompt.writeln('Nama Pengguna: $username');
    prompt.writeln('Saldo Saat Ini: ${formatRupiah(balance)}');
    prompt.writeln('Batas Pengeluaran (jika ada): ${limitSpend > 0 ? formatRupiah(limitSpend) : "Tidak diatur"}');
    prompt.writeln('Pemasukan Minggu Ini: ${formatRupiah(weeklyIncome)}');
    prompt.writeln('Pengeluaran Minggu Ini: ${formatRupiah(weeklySpending)}');
    prompt.writeln('Total Pengeluaran Keseluruhan: ${formatRupiah(totalSpending)}');
    prompt.writeln('Total Biaya Belanja Inventaris Keseluruhan: ${formatRupiah(totalInventoryPurchaseValue)}');
    prompt.writeln('Total Penjualan Produk Keseluruhan: ${formatRupiah(totalSalesRevenue)}');
    prompt.writeln('');

    if (currentInventoryStock.isNotEmpty) {
      prompt.writeln('Stok Inventaris Saat Ini:');
      currentInventoryStock.forEach((name, stock) {
        prompt.writeln('- $name: ${stock.toStringAsFixed(2)}');
      });
      // Logika identifikasi stok hampir habis (threshold bisa disesuaikan)
      List<String> lowStockItems = [];
      currentInventoryStock.forEach((name, stock) {
        if (stock < 5 && stock > 0) { // Contoh: kurang dari 5 unit dianggap hampir habis
          lowStockItems.add(name);
        }
      });
      if (lowStockItems.isNotEmpty) {
        prompt.writeln('Stok Hampir Habis: ${lowStockItems.join(', ')}');
      }
      prompt.writeln('');
    } else {
      prompt.writeln('Tidak ada data stok inventaris yang ditemukan.');
    }

    if (recipes.isNotEmpty) {
      prompt.writeln('Daftar Resep:');
      for (var recipe in recipes) {
        prompt.writeln('- ${recipe['name']} (Harga Jual: ${formatRupiah(recipe['price'])})');
        recipe.forEach((key, value) {
          if (key != 'name' && key != 'price') {
            prompt.writeln('  - Bahan: $key, Jumlah: $value');
          }
        });
      }
      prompt.writeln('');
    } else {
      prompt.writeln('Tidak ada data resep yang ditemukan.');
    }

    if (sales.isNotEmpty) {
      prompt.writeln('10 Penjualan Terakhir:');
      for (var sale in sales) {
        prompt.writeln('- Menu: ${sale['menu']}, Harga: ${formatRupiah(sale['price'])}, Tanggal: ${DateFormat('dd-MM-yyyy HH:mm').format(sale['date'])}');
      }
      prompt.writeln('');
    } else {
      prompt.writeln('Tidak ada data penjualan yang ditemukan.');
    }

    prompt.writeln('--- Pertanyaan Saya ---');
    prompt.writeln(question);
    prompt.writeln('');
    prompt.writeln('--- Balasan Anda (Fokus pada Jawaban Langsung) ---'); // Petunjuk untuk Gemini agar merespons secara langsung

    try {
      final content = [Content.text(prompt.toString())];
      final response = await _model.generateContent(content);
      return response.text ?? 'Maaf, saya tidak dapat menghasilkan respons saat ini. Silakan coba pertanyaan lain.';
    } catch (e) {
      print('Error generating content with Gemini: $e');
      return 'Maaf, terjadi masalah saat berkomunikasi dengan AI. Pastikan API Key Anda benar dan koneksi internet stabil.';
    }
  }

  // format uang
  String formatRupiah(num amount) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 140), // area untuk input
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: pagePadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(_chatMessages.length, (index) {
                    final message = _chatMessages[index];
                    return Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Align(
                        alignment: message['isBot']
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: ChatBubble(
                          message: message['text'],
                          isBot: message['isBot'],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            // Input + kategori
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --------------------------------------------------------------------------
                    // TAHAP 6: PENGUJIAN DAN VALIDASI (Indikator Loading untuk User Experience)
                    // --------------------------------------------------------------------------
                    if (_isLoading) // Tampilkan loading indicator jika isLoading true
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D09E)),
                        ),
                      ),
                    // --------------------------------------------------------------------------
                    // TAHAP 1: ANALISIS KEBUTUHAN & PERENCANAAN SISTEM (Pilihan Pertanyaan Utama)
                    // --------------------------------------------------------------------------
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        _categoryBox("Penjualan", "Berapa total penjualan produk?"),
                        _categoryBox("Biaya Inventaris", "Berapa total biaya belanja inventaris?"),
                        _categoryBox("Stok Biji Kopi", "Berapa stok biji kopi saya saat ini?"),
                        _categoryBox("Resep Latte", "Apa resep untuk membuat Latte?"), // Tambahan contoh resep
                        _categoryBox("Stok Hampir Habis", "Apakah ada stok yang hampir habis?"), // Tambahan
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 70,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFDFF7E2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _controller,
                              onFieldSubmitted: _sendMessage,
                              enabled: !_isLoading, // Nonaktifkan input saat loading
                              decoration: InputDecoration(
                                hintText: 'Pilih atau Ketik Pertanyaanmu!',
                                hintStyle: const TextStyle(
                                  color: Color(0xFF00D09E),
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400,
                                ),
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _isLoading ? null : () => _sendMessage(_controller.text), // Nonaktifkan tombol saat loading
                            icon: const Icon(Icons.send, color: Color(0xFF00D09E)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryBox(String label, String questionText) {
    return GestureDetector(
      onTap: () {
        if (!_isLoading) { // Hanya izinkan tap jika tidak sedang loading
          setState(() {
            _controller.text = questionText; // tampilkan pertanyaan di input field
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF00D09E),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isBot;

  const ChatBubble({
    Key? key,
    required this.message,
    required this.isBot,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = const Color(0xFF00D09E);
    final alignment = isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        CustomPaint(
          painter: BubblePainter(color: color, isBot: isBot),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class BubblePainter extends CustomPainter {
  final Color color;
  final bool isBot;

  BubblePainter({required this.color, required this.isBot});

  @override
  void paint(Canvas canvas, Size size) {
    final radius = 12.0;
    final path = Path();
    final paint = Paint()..color = color;

    // Bubble body
    if (isBot) {
      path.moveTo(radius, 0);
      path.lineTo(size.width - radius, 0);
      path.quadraticBezierTo(size.width, 0, size.width, radius);
      path.lineTo(size.width, size.height - radius);
      path.quadraticBezierTo(size.width, size.height, size.width - radius, size.height);
      path.lineTo(20, size.height);
      path.lineTo(10, size.height + 10); // tail
      path.lineTo(10, size.height);
      path.lineTo(radius, size.height);
      path.quadraticBezierTo(0, size.height, 0, size.height - radius);
      path.lineTo(0, radius);
      path.quadraticBezierTo(0, 0, radius, 0);
    } else {
      path.moveTo(radius, 0);
      path.lineTo(size.width - radius, 0);
      path.quadraticBezierTo(size.width, 0, size.width, radius);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width - 10, size.height);
      path.lineTo(size.width - 10, size.height + 10); // tail
      path.lineTo(size.width - 20, size.height);
      path.lineTo(radius, size.height);
      path.quadraticBezierTo(0, size.height, 0, size.height - radius);
      path.lineTo(0, radius);
      path.quadraticBezierTo(0, 0, radius, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}