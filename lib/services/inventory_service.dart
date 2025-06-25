// lib/services/inventory_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mycafeinventory/utils/unit_converter.dart'; // Sesuaikan dengan nama proyek Anda

class InventoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Koleksi untuk log inventori (pembelian dan konsumsi)
  // Ini juga AKAN BERFUNGSI sebagai tempat dokumen master untuk update stok.
  static const String _inventoryCollection = 'inventory'; 
  static const String _recipesCollection = 'recipes';
  static const String _salesCollection = 'sales';

  // Map ini menyediakan unit resep default untuk setiap bahan jika unit tidak disimpan di Firebase.
  final Map<String, String> _defaultRecipeIngredientUnits = {
    'biji_kopi': 'g',
    'susu_uht': 'ml',
    'gula_aren_cair': 'ml',
    'kertas_filter': 'g',
    'es_krim': 'ml',
    'sirup_karamel': 'ml',
    'coklat_bubuk': 'g',
    'air': 'ml',
    'lemon': 'g',
    'sirup_vanilla': 'ml',
    // PASTIKAN SEMUA BAHAN BAKU DARI RESEP ANDA ADA DI SINI DENGAN UNIT DEFAULTNYA
  };

  // Mapping nama field bahan baku di resep (misal: 'biji_kopi')
  // ke nilai 'nameInv' di dokumen koleksi 'inventory' (misal: 'Biji Kopi').
  final Map<String, String> _ingredientKeyToInventoryNameInv = {
    'biji_kopi': 'Biji Kopi',
    'susu_uht': 'Susu UHT',
    'gula_aren_cair': 'Gula Aren Cair',
    'kertas_filter': 'Kertas Filter',
    'es_krim': 'Es Krim',
    'sirup_karamel': 'Sirup Karamel',
    'coklat_bubuk': 'Coklat Bubuk',
    'air': 'Air',
    'lemon': 'Lemon',
    'sirup_vanilla': 'Sirup Vanilla',
    // PASTIKAN SEMUA BAHAN BAKU DARI RESEP ANDA ADA DI SINI DENGAN NAMA DI INVENTORI ANDA
  };

  /// Mencari ID dokumen dari entri inventori yang merupakan 'master'
  /// untuk bahan baku tertentu berdasarkan 'nameInv'.
  /// Dalam model ini, kita berasumsi ada satu dokumen yang "merepresentasikan"
  /// stok terkini untuk setiap 'nameInv' di koleksi _inventoryCollection.
  /// Ini BUKAN agregasi, tapi mencari dokumen spesifik.
  Future<DocumentSnapshot?> _findInventoryMasterDoc(String userId, String nameInv) async {
    try {
      // Kita perlu mencari dokumen dengan 'nameInv' yang cocok.
      // Jika Anda memiliki banyak dokumen dengan 'nameInv' yang sama
      // (misalnya, beberapa entri pembelian untuk Biji Kopi),
      // maka strategi ini HARUS diubah.
      // Asumsi saat ini: ada satu dokumen per bahan baku yang akan di-update.
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection(_inventoryCollection)
          .where('nameInv', isEqualTo: nameInv)
          .limit(1) // Ambil hanya satu, berasumsi itu adalah dokumen master
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        print('DEBUG: Ditemukan dokumen master untuk "$nameInv" dengan ID: ${querySnapshot.docs.first.id}');
        return querySnapshot.docs.first;
      } else {
        print('DEBUG: Dokumen master untuk "$nameInv" tidak ditemukan.');
        return null;
      }
    } catch (e) {
      print('ERROR: Gagal mencari dokumen master inventori: $e');
      rethrow;
    }
  }


  /// Memproses pesanan kopi.
  /// Ini akan:
  /// 1. Mengambil resep kopi.
  /// 2. Menghitung stok bahan baku terkini dari _currentAggregatedStock (masih relevan untuk validasi).
  /// 3. Memvalidasi ketersediaan stok.
  /// 4. Jika cukup, MENGURANGI stok langsung pada dokumen inventori yang sudah ada
  ///    menggunakan FieldValue.increment().
  /// 5. Mencatat transaksi penjualan di koleksi 'sales'.
  ///
  /// [coffeeName]: Nama kopi yang dipesan (misal: 'Kopi Susu Kelor').
  /// [userId]: ID pengguna yang melakukan pesanan.
  /// [coffeePrice]: Harga jual kopi tersebut.
  /// [paymentMethod]: Metode pembayaran.
  Future<void> processCoffeeOrder({
    required String coffeeName,
    required String userId,
    required double coffeePrice,
    required String paymentMethod,
  }) async {
    try {
      // 1. Ambil data resep untuk kopi yang dipesan
      DocumentSnapshot recipeDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection(_recipesCollection)
          .doc(coffeeName)
          .get();

      if (!recipeDoc.exists) {
        throw Exception('Resep "$coffeeName" tidak ditemukan. Pastikan resep ada di Firebase.');
      }
      Map<String, dynamic> recipeData = recipeDoc.data() as Map<String, dynamic>;
      print('DEBUG: Recipe data for $coffeeName: $recipeData');

      WriteBatch batch = _firestore.batch(); // Untuk operasi penulisan atomik

      // Map untuk menyimpan jumlah yang akan dikurangkan per bahan baku setelah konversi unit
      Map<String, double> quantitiesToDeduct = {};
      // Map untuk menyimpan ID dokumen inventori master yang akan diupdate
      Map<String, String> masterInventoryDocIds = {};
      // Map untuk menyimpan unit stok sebenarnya dari master dokumen
      Map<String, String> masterInventoryUnits = {};

      // --- Tahap Validasi Stok ---
      for (String ingredientKey in recipeData.keys) {
        if (ingredientKey == 'price' || ingredientKey == 'date_created') continue;

        String? inventoryNameInv = _ingredientKeyToInventoryNameInv[ingredientKey];
        if (inventoryNameInv == null || inventoryNameInv.isEmpty) {
          throw Exception(
              'ERROR: Mapping bahan baku resep "$ingredientKey" ke nama inventori tidak ditemukan atau kosong. '
              'Periksa _ingredientKeyToInventoryNameInv di InventoryService.');
        }

        // Cari dokumen master inventori untuk bahan baku ini
        DocumentSnapshot? masterDoc = await _findInventoryMasterDoc(userId, inventoryNameInv);
        if (masterDoc == null || !masterDoc.exists) {
          throw Exception('Bahan baku "$inventoryNameInv" tidak ditemukan di inventori utama. Harap tambahkan stok.');
        }

        // Ambil stok terkini dan unit dari dokumen master
        num currentStock = (masterDoc.data() as Map<String, dynamic>)['stokInv'] as num? ?? 0.0;
        String? stockUnit = (masterDoc.data() as Map<String, dynamic>)['unitInv'] as String?;

        if (stockUnit == null || stockUnit.isEmpty) {
          throw Exception('ERROR: Unit stok untuk "$inventoryNameInv" tidak ditemukan atau kosong di dokumen inventori utama.');
        }

        double requiredQuantityRecipe = (recipeData[ingredientKey] as num?)?.toDouble() ?? 0.0;
        String? recipeUnit = _defaultRecipeIngredientUnits[ingredientKey];

        if (recipeUnit == null || recipeUnit.isEmpty) {
          throw Exception('ERROR: Satuan resep untuk "$ingredientKey" tidak ditemukan di lookup atau kosong.');
        }

        double quantityToDeduct = UnitConverter.getStockQuantity(
            requiredQuantityRecipe, recipeUnit, stockUnit);

        print('DEBUG: $inventoryNameInv - Butuh: $requiredQuantityRecipe $recipeUnit, Konversi: ${quantityToDeduct.toStringAsFixed(2)} $stockUnit. Stok Tersedia: ${currentStock.toStringAsFixed(2)} $stockUnit');

        if (currentStock < quantityToDeduct) {
          throw Exception('Stok "$inventoryNameInv" tidak cukup. Dibutuhkan: ${quantityToDeduct.toStringAsFixed(2)} $stockUnit, Tersedia: ${currentStock.toStringAsFixed(2)} $stockUnit');
        }

        // Simpan informasi untuk operasi batch setelah semua validasi berhasil
        quantitiesToDeduct[inventoryNameInv] = quantityToDeduct;
        masterInventoryDocIds[inventoryNameInv] = masterDoc.id;
        masterInventoryUnits[inventoryNameInv] = stockUnit;
      }

      // --- Tahap Pengurangan Stok dan Pencatatan Penjualan (Jika Validasi Berhasil) ---
      for (String inventoryNameInv in quantitiesToDeduct.keys) {
        double quantityToDeduct = quantitiesToDeduct[inventoryNameInv]!;
        String masterDocId = masterInventoryDocIds[inventoryNameInv]!;
        String stockUnit = masterInventoryUnits[inventoryNameInv]!;

        // Kurangi stok langsung pada dokumen inventori yang sudah ada
        batch.update(
          _firestore.collection('users').doc(userId).collection(_inventoryCollection).doc(masterDocId),
          {
            'stokInv': FieldValue.increment(-quantityToDeduct), // Kuantitas negatif untuk konsumsi
            // Tidak perlu update date atau type karena ini bukan log baru, melainkan update master stok
          },
        );
        print('DEBUG: Mengurangi stok inventori "$inventoryNameInv": -${quantityToDeduct.toStringAsFixed(2)} $stockUnit pada dokumen ID: $masterDocId');
      }

      // Tambahkan operasi penjualan ke batch
      DocumentReference newSaleDocRef = _firestore
          .collection('users')
          .doc(userId)
          .collection(_salesCollection)
          .doc();

      batch.set(
        newSaleDocRef,
        {
          'date': Timestamp.now(),
          'menu': coffeeName,
          'method': paymentMethod,
          'price': coffeePrice,
        },
      );
      print('DEBUG: Menambahkan entri penjualan untuk $coffeeName.');

      // Commit semua operasi penulisan (pengurangan stok dan penjualan) secara atomik
      await batch.commit();
      print('DEBUG: Semua operasi berhasil di-commit.');

      print('SUCCESS: Pesanan "$coffeeName" berhasil diproses, stok inventori diperbarui, dan penjualan dicatat!');
    } catch (e) {
      print('ERROR: Gagal memproses pesanan: $e');
      rethrow;
    }
  }

  /// Menambahkan stok baru (pembelian) ke dokumen inventori yang sudah ada
  /// atau membuat dokumen baru jika belum ada.
  ///
  /// [materialName]: Nama bahan baku (misal: 'Biji Kopi') - ini akan jadi nilai 'nameInv'.
  /// [userId]: ID pengguna.
  /// [stock]: Jumlah stok yang ditambahkan (positif).
  /// [unit]: Satuan stok (misal: 'kg', 'l', 'g').
  /// [priceInv]: Harga pembelian per satuan.
  /// [total]: Total harga pembelian.
  Future<void> addInventoryPurchase({
    required String materialName,
    required String userId,
    required double stock,
    required String unit,
    required double priceInv,
    required double total,
  }) async {
    try {
      // Cari apakah sudah ada dokumen master untuk bahan baku ini
      DocumentSnapshot? existingDoc = await _findInventoryMasterDoc(userId, materialName);

      if (existingDoc != null && existingDoc.exists) {
        // Jika dokumen sudah ada, update stoknya
        await _firestore
            .collection('users')
            .doc(userId)
            .collection(_inventoryCollection)
            .doc(existingDoc.id) // Update dokumen yang sudah ada
            .update({
              'stokInv': FieldValue.increment(stock), // Tambahkan stok
              'date': Timestamp.now(), // Update tanggal pembelian terakhir
              'unitInv': unit, // Pastikan unit konsisten
              'priceInv': priceInv,
              'total': total,
              'type': 'purchase', // Tetap tandai sebagai pembelian terakhir
            });
        print('Stok inventori "$materialName" diperbarui sejumlah $stock $unit pada dokumen ID: ${existingDoc.id}.');
      } else {
        // Jika dokumen belum ada, buat dokumen baru (ini akan menjadi master pertama)
        await _firestore
            .collection('users')
            .doc(userId)
            .collection(_inventoryCollection)
            .add({
              'date': Timestamp.now(),
              'nameInv': materialName,
              'stokInv': stock,
              'unitInv': unit,
              'priceInv': priceInv,
              'total': total,
              'type': 'purchase',
            });
        print('Dokumen master inventori baru untuk "$materialName" dibuat sejumlah $stock $unit.');
      }
    } catch (e) {
      print('Error mencatat pembelian inventori: $e');
      rethrow;
    }
  }

  // Fungsi untuk mendapatkan stok terkini yang akan ditampilkan di UI (misal di halaman inventori)
  // Fungsi ini masih menggunakan logika agregasi dari semua dokumen di _inventoryCollection
  // jika _inventoryCollection masih berfungsi sebagai log transaksi.
  // Jika setiap bahan baku hanya memiliki SATU dokumen (master) di _inventoryCollection,
  // maka fungsi ini bisa disederhanakan untuk membaca langsung setiap dokumen.
  Future<Map<String, Map<String, dynamic>>> getCurrentStocks({required String userId}) async {
    return _calculateCurrentAggregatedStock(userId);
  }

  /// Menghitung stok terkini dari setiap bahan baku dengan mengagregasi
  /// semua entri di koleksi 'inventory'.
  ///
  /// Mengembalikan Map<String, Map<String, dynamic>>
  /// di mana key adalah 'nameInv' (misal: "Biji Kopi")
  /// dan value adalah Map yang berisi 'stock' (double) dan 'unit' (String).
  ///
  /// CATATAN: Dengan model di mana Anda langsung memperbarui dokumen stok yang ada,
  /// fungsi ini mungkin tidak lagi diperlukan dan bisa diganti dengan membaca
  /// langsung dokumen master. Namun, jika Anda masih memiliki campuran log dan master,
  /// fungsi ini mungkin tetap relevan untuk gambaran agregat.
  /// Untuk tujuan Opsi 2 ini, fungsi ini akan diadaptasi untuk hanya membaca
  /// dokumen master (dokumen yang ada dengan 'nameInv' unik), bukan mengagregasi log.
  Future<Map<String, Map<String, dynamic>>> _calculateCurrentAggregatedStock(String userId) async {
    Map<String, Map<String, dynamic>> currentStocks = {};

    try {
      QuerySnapshot inventorySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection(_inventoryCollection)
          .get();

      print('DEBUG: Total dokumen di master inventori: ${inventorySnapshot.docs.length}');

      for (var doc in inventorySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Asumsi: setiap dokumen di sini adalah master untuk satu nameInv
        // Karena kita hanya update dokumen yang ada (bukan membuat log baru untuk setiap transaksi)
        String? nameInv = data['nameInv'] as String?;
        if (nameInv == null || nameInv.isEmpty) {
          print('WARNING: Dokumen inventori dengan ID ${doc.id} tidak memiliki field "nameInv" atau kosong.');
          continue;
        }

        double stokInv = (data['stokInv'] as num?)?.toDouble() ?? 0.0;
        String? unitInv = data['unitInv'] as String?;
        if (unitInv == null || unitInv.isEmpty) {
          print('WARNING: Dokumen inventori dengan ID ${doc.id} tidak memiliki field "unitInv" atau kosong.');
          unitInv = 'N/A'; // Default jika tidak ada
        }

        // Karena kita asumsikan _inventoryCollection sekarang menyimpan dokumen master (bukan log banyak entri),
        // kita cukup mengambil nilai stok dari setiap dokumen.
        currentStocks[nameInv] = {
          'stock': stokInv,
          'unit': unitInv,
        };
        print('DEBUG: Stok master: $nameInv, stokInv: $stokInv, unitInv: $unitInv');
      }
      print('DEBUG: Stok terkini dari _inventoryCollection (master): $currentStocks');
      return currentStocks;
    } catch (e) {
      print('ERROR: Gagal mendapatkan stok terkini dari _inventoryCollection: $e');
      rethrow;
    }
  }
}