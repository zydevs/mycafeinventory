// lib/utils/unit_converter.dart

class UnitConverter {
  /// Mengonversi kuantitas dan satuan yang diberikan ke dalam **gram** (basis massa).
  /// Mendukung 'g' (gram) dan 'kg' (kilogram).
  static double toGrams(double quantity, String unit) {
    switch (unit.toLowerCase().trim()) { // Tambahkan .trim() untuk robustness
      case 'g':
        return quantity;
      case 'kg':
        return quantity * 1000;
      default:
        // Lebih baik melempar error agar unit yang tidak didukung jelas terlihat
        // Atau, jika Anda yakin ini tidak akan terjadi, Anda bisa mengembalikan quantity
        // dan log warning. Untuk konversi kritis seperti ini, error lebih aman.
        throw ArgumentError('Unknown or unsupported mass unit for conversion to grams: $unit');
    }
  }

  /// Mengonversi kuantitas dan satuan yang diberikan ke dalam **mililiter** (basis volume).
  /// Mendukung 'ml' (mililiter) dan 'l' (liter).
  static double toMilliliters(double quantity, String unit) { // Ubah nama fungsi ke toMilliliters
    switch (unit.toLowerCase().trim()) { // Tambahkan .trim()
      case 'ml':
        return quantity;
      case 'liter':
        return quantity * 1000; // Konversi liter ke mililiter
      default:
        throw ArgumentError('Unknown or unsupported volume unit for conversion to milliliters: $unit');
    }
  }

  /// Mengambil kuantitas resep dan mengonversinya ke dalam satuan stok.
  /// Ini adalah fungsi kunci untuk penyesuaian inventori.
  /// Fungsi ini memastikan konversi dilakukan dengan benar antara unit massa (g/kg)
  /// dan unit volume (ml/l).
  static double getStockQuantity(double recipeQuantity, String recipeUnit, String stockUnit) {
    recipeUnit = recipeUnit.toLowerCase().trim();
    stockUnit = stockUnit.toLowerCase().trim();

    // Tentukan apakah kita berurusan dengan unit massa atau volume
    final Set<String> massUnits = {'g', 'kg'};
    final Set<String> volumeUnits = {'ml', 'liter'};

    // 1. Konversi kuantitas resep ke basis unit yang sama (gram atau mililiter)
    double quantityInBaseUnit;
    String baseUnitType; // 'mass' or 'volume'

    if (massUnits.contains(recipeUnit)) {
      quantityInBaseUnit = toGrams(recipeQuantity, recipeUnit);
      baseUnitType = 'mass';
    } else if (volumeUnits.contains(recipeUnit)) {
      quantityInBaseUnit = toMilliliters(recipeQuantity, recipeUnit); // Gunakan toMilliliters
      baseUnitType = 'volume';
    } else {
      throw ArgumentError('Unsupported recipe unit: "$recipeUnit". Must be a mass (g, kg) or volume (ml, liter) unit.');
    }

    // 2. Konversi dari basis unit ke unit stok yang diinginkan
    if (baseUnitType == 'mass') {
      if (stockUnit == 'g') {
        return quantityInBaseUnit; // Sudah dalam gram
      } else if (stockUnit == 'kg') {
        return quantityInBaseUnit / 1000; // Konversi gram ke kilogram
      } else {
        throw ArgumentError('Mismatched unit types: Recipe unit is mass, but stock unit "$stockUnit" is not a mass unit.');
      }
    } else if (baseUnitType == 'volume') {
      if (stockUnit == 'ml') {
        return quantityInBaseUnit; // Sudah dalam mililiter
      } else if (stockUnit == 'liter') {
        return quantityInBaseUnit / 1000; // Konversi mililiter ke liter
      } else {
        throw ArgumentError('Mismatched unit types: Recipe unit is volume, but stock unit "$stockUnit" is not a volume unit.');
      }
    } else {
      // Ini seharusnya tidak tercapai jika logika di atas sudah benar
      throw StateError('Unexpected error during unit conversion.');
    }
  }
}