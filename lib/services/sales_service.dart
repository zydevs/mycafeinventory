// lib/services/sales_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class SalesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Nama koleksi Firebase Firestore untuk sales
  static const String _salesCollection = 'sales';

  /// Mendapatkan semua data penjualan untuk user tertentu.
  /// Data akan diurutkan berdasarkan tanggal secara descending.
  ///
  /// [userId]: ID pengguna yang ingin diambil data penjualannya.
  Future<List<Map<String, dynamic>>> getSalesHistory({required String userId}) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection(_salesCollection)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error mendapatkan riwayat penjualan: $e');
      rethrow;
    }
  }

  /// Mendapatkan total penjualan (pendapatan) untuk user tertentu.
  ///
  /// [userId]: ID pengguna.
  Future<double> getTotalSales({required String userId}) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection(_salesCollection)
          .get();

      double total = 0.0;
      for (var doc in snapshot.docs) {
        // Asumsi 'price' disimpan sebagai num (int atau double)
        total += (doc['price'] as num).toDouble();
      }
      return total;
    } catch (e) {
      print('Error mendapatkan total penjualan: $e');
      rethrow;
    }
  }

  // Anda bisa menambahkan fungsi lain di sini, misalnya:
  // - getSalesByDateRange()
  // - deleteSaleRecord()
  // - addSale (jika ada skenario penambahan manual selain dari processCoffeeOrder)
}