import 'package:mycafeinventory/widgets/custom_image_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:mycafeinventory/utils/image_constant.dart';

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
            width: 480,
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
            Text(
              'Chatbot My Cafe Inventory',
              style: const TextStyle(
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
    if (text.trim().isEmpty) return;

    setState(() {
      // Tambahkan pesan user
      _chatMessages.add({'text': text.trim(), 'isBot': false});
      _controller.clear();
    });

    _scrollToBottom();

    // Tunggu sebentar sebelum bot membalas
    await Future.delayed(const Duration(milliseconds: 500));

    // Ambil respon dari bot (pastikan pakai await)
    String botReply = await _getBotResponse(text.trim());

    setState(() {
      _chatMessages.add({
        'text': botReply,
        'isBot': true,
      });
    });

    _scrollToBottom();
  }

  // RULE - BASED
  Future<String> _getBotResponse(String question) async {
    
    // format uang
    String formatRupiah(num amount) {
      final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
      return formatter.format(amount);
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return 'Anda belum login.';
    }

    final firestore = FirebaseFirestore.instance;
    final userDoc = await firestore.collection('users').doc(user.uid).get();
    if (!userDoc.exists) {
      return 'Data keuangan tidak ditemukan.';
    }

    final data = userDoc.data()!;
    final balanceRaw = data['balance'];
    final limitSpendRaw = data['limitSpend'];
    final balance = (balanceRaw is num)
        ? balanceRaw
        : num.tryParse(balanceRaw.toString()) ?? 0;
    final limitSpend = (limitSpendRaw is num)
        ? limitSpendRaw
        : num.tryParse(limitSpendRaw.toString()) ?? 0;

    // Ambil data income & spending
    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7));

    final incomeSnapshot = await firestore
        .collection('users')
        .doc(user.uid)
        .collection('income')
        .get();

    final spendingSnapshot = await firestore
        .collection('users')
        .doc(user.uid)
        .collection('spending')
        .get();

    num weeklyIncome = 0;
    for (var doc in incomeSnapshot.docs) {
      final amount = doc['amount'];
      final date = (doc['date'] as Timestamp).toDate();
      if (date.isAfter(oneWeekAgo)) {
        weeklyIncome += (amount is num ? amount : num.tryParse(amount.toString()) ?? 0);
      }
    }

    num weeklySpending = 0;
    for (var doc in spendingSnapshot.docs) {
      final amount = doc['amount'];
      final date = (doc['date'] as Timestamp).toDate();
      if (date.isAfter(oneWeekAgo)) {
        weeklySpending += (amount is num ? amount : num.tryParse(amount.toString()) ?? 0);
      }
    }

    final totalSpending = spendingSnapshot.docs.fold<num>(0, (sum, doc) {
      final amount = doc['amount'];
      return sum + (amount is num ? amount : num.tryParse(amount.toString()) ?? 0);
    });

    switch (question.toLowerCase()) {
      case 'bagaimana kondisi keuanganku?':
        if (balance <= 0) {
          return 'Silahkan catat keuangan anda terlebih dahulu.';
        }

        if (balance - totalSpending <= 0) {
          return 'Keuangan anda tidak baik. Silahkan kurangi pengeluaran!';
        }

        if (limitSpendRaw == null) {
          return 'Kondisi keuangan anda baik, Pertahankan!';
        } else {
          if (totalSpending > limitSpend) {
            return 'Keuangan anda tidak baik. Silahkan kurangi pengeluaran!';
          } else {
            return 'Kondisi keuangan anda baik, Pertahankan!';
          }
        }

      case 'apa investasi yang cocok untuk saya?':
        if (balance <= 0) {
          return 'Silahkan catat keuangan anda terlebih dahulu';
        } else if (balance < 1000000) {
          return 'Fokus bangun Dana Darurat, beli kursus atau buku untuk meningkatkan skill dan penghasilan.';
        } else if (balance >= 1000000 && balance <= 5000000) {
          return 'Reksa Dana Pasar Uang. Modal minim, risiko rendah, cair cepat.';
        } else if (balance > 5000000 && balance <= 20000000) {
          return 'Reksa Dana Campuran atau Obligasi. Cocok untuk jangka menengah.';
        } else {
          return 'Deposito, Emas, dan Saham. Cocok untuk jangka panjang.';
        }

      case 'berapa jumlah uang yang bisa saya investasikan?':
        if (balance <= 0) {
          return 'Silahkan catat keuangan anda terlebih dahulu';
        } else {
          final investAmount = (balance * 0.2).round();
          return 'Anda bisa menggunakan uang sejumlah  ${formatRupiah(investAmount)} untuk investasi.';
        }

      case 'berapa pemasukan saya minggu ini?':
        if (balance <= 0) {
          return 'Silahkan catat keuangan anda terlebih dahulu';
        } else if (weeklyIncome == 0) {
          return 'Silahkan catat pemasukan anda minggu ini';
        } else {
          return 'Pemasukan minggu ini adalah ${formatRupiah(weeklyIncome)} Tetap produktif!';
        }

      case 'berapa pengeluaran saya minggu ini?':
        if (balance <= 0) {
          return 'Silahkan catat keuangan anda terlebih dahulu';
        } else if (weeklySpending == 0) {
          return 'Silahkan catat pengeluaran anda minggu ini';
        } else {
          return 'Pengeluaran minggu ini adalah ${formatRupiah(weeklySpending)} Tetap bijak dalam berbelanja!';
        }

      default:
        return 'Maaf, pertanyaan anda tidak valid!';
    }
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
                controller: _scrollController, // pastikan sudah didefinisikan di atas
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
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        _categoryBox("Keuangan", "Bagaimana kondisi keuanganku?"),
                        _categoryBox("Investasi", "Apa investasi yang cocok untuk saya?"),
                        _categoryBox("Jumlah Investasi", "Berapa jumlah uang yang bisa saya investasikan?"),
                        _categoryBox("Pengeluaran", "Berapa pengeluaran saya minggu ini?"),
                        _categoryBox("Pemasukan", "Berapa pemasukan saya minggu ini?"),
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
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _sendMessage(_controller.text),
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
        setState(() {
          _controller.text = questionText; // tampilkan pertanyaan di input field
        });
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
    final tailAlignment = isBot ? Alignment.bottomLeft : Alignment.bottomRight;

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
