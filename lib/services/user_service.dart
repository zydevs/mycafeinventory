// lib/services/user_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Nama koleksi Firebase Firestore untuk users
  static const String _usersCollection = 'users';

  /// Mendapatkan data profil pengguna.
  ///
  /// [userId]: ID pengguna yang datanya ingin diambil.
  Future<Map<String, dynamic>?> getUserProfile({required String userId}) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        return null; // Pengguna tidak ditemukan
      }
    } catch (e) {
      print('Error mendapatkan profil pengguna: $e');
      rethrow;
    }
  }

  /// Memperbarui data profil pengguna (username, email, balance).
  ///
  /// [userId]: ID pengguna yang datanya ingin diperbarui.
  /// [data]: Map berisi field yang ingin diperbarui (misal: {'username': 'newuser'}).
  Future<void> updateUserProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .update(data);
      print('Profil pengguna $userId berhasil diperbarui.');
    } catch (e) {
      print('Error memperbarui profil pengguna: $e');
      rethrow;
    }
  }

  /// Menambah atau mengurangi saldo (balance) pengguna.
  ///
  /// [userId]: ID pengguna.
  /// [amount]: Jumlah yang akan ditambahkan (positif) atau dikurangi (negatif).
  Future<void> updateBalance({
    required String userId,
    required double amount,
  }) async {
    try {
      // Menggunakan transaksi untuk memastikan operasi atomik pada balance
      await _firestore.runTransaction((transaction) async {
        DocumentReference userRef = _firestore.collection(_usersCollection).doc(userId);
        DocumentSnapshot userSnapshot = await transaction.get(userRef);

        if (!userSnapshot.exists) {
          throw Exception('Pengguna tidak ditemukan untuk update saldo.');
        }

        double currentBalance = (userSnapshot['balance'] as num?)?.toDouble() ?? 0.0;
        double newBalance = currentBalance + amount;

        if (newBalance < 0) {
          // Opsional: Jika Anda tidak ingin saldo menjadi negatif
          throw Exception('Saldo tidak mencukupi untuk melakukan transaksi ini.');
        }

        transaction.update(userRef, {'balance': newBalance});
      });
      print('Saldo pengguna $userId berhasil diperbarui.');
    } catch (e) {
      print('Error memperbarui saldo pengguna: $e');
      rethrow;
    }
  }

  // Anda bisa menambahkan fungsi lain di sini, misalnya:
  // - createUserProfile (saat pendaftaran user baru)
  // - deleteUser (jarang dilakukan)
}