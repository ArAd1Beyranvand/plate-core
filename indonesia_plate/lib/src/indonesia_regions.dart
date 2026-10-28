/// Names the province (and, where a province has several codes, the area)
/// from the one- or two-letter area code.
///
/// Source: "Registration area codes" in
/// https://en.wikipedia.org/wiki/Vehicle_registration_plates_of_Indonesia
abstract final class IndonesiaRegions {
  static const Map<String, String> _areas = <String, String>{
    'BL': 'Aceh',
    'BB': 'North Sumatra (Western)',
    'BK': 'North Sumatra (Eastern)',
    'BA': 'West Sumatra',
    'BM': 'Riau',
    'BP': 'Riau Islands',
    'BH': 'Jambi',
    'BD': 'Bengkulu',
    'BG': 'South Sumatra',
    'BN': 'Bangka Belitung Islands',
    'BE': 'Lampung',
    'A': 'Banten',
    'B': 'Jakarta',
    'F': 'West Java (western Preanger Regencies)',
    'T': 'West Java (Karawang)',
    'E': 'West Java (Cirebon)',
    'D': 'West Java (central Preanger Regencies)',
    'Z': 'West Java (eastern Preanger Regencies)',
    'R': 'Central Java (Banyumas)',
    'G': 'Central Java (Pekalongan)',
    'H': 'Central Java (Semarang)',
    'K': 'Central Java (Pati)',
    'AA': 'Central Java (Kedu)',
    'AD': 'Central Java (Surakarta)',
    'AB': 'Yogyakarta',
    'AE': 'East Java (Madiun)',
    'AG': 'East Java (Kediri)',
    'S': 'East Java (Bojonegoro)',
    'W': 'East Java (Sidoarjo, Gresik)',
    'L': 'East Java (Surabaya)',
    'M': 'East Java (Madura Island)',
    'N': 'East Java (Malang)',
    'P': 'East Java (Besuki)',
    'KB': 'West Kalimantan',
    'KH': 'Central Kalimantan',
    'DA': 'South Kalimantan',
    'KT': 'East Kalimantan',
    'KU': 'North Kalimantan',
    'DL': 'North Sulawesi (Islands)',
    'DB': 'North Sulawesi (Mainland)',
    'DM': 'Gorontalo',
    'DN': 'Central Sulawesi',
    'DC': 'West Sulawesi',
    'DP': 'South Sulawesi (Northern)',
    'DW': 'South Sulawesi (Central)',
    'DD': 'South Sulawesi (Southern)',
    'DT': 'Southeast Sulawesi',
    'DK': 'Bali',
    'DR': 'West Nusa Tenggara (Lombok)',
    'EA': 'West Nusa Tenggara (Sumbawa)',
    'ED': 'East Nusa Tenggara (Sumba)',
    'EB': 'East Nusa Tenggara (Flores, Alor, Lembata)',
    'DH': 'East Nusa Tenggara (Timor)',
    'DE': 'Maluku',
    'DG': 'North Maluku',
    'PA': 'Papua',
    'PB': 'West Papua',
    'PG': 'Highland Papua',
    'PS': 'South Papua',
    'PT': 'Central Papua',
    'PY': 'Southwest Papua',
  };

  /// The area of [prefix]: the exact code if there is one, else the one area
  /// every code beginning with it shares, else null.
  static String? lookup(String prefix) {
    if (prefix.isEmpty) return null;
    final String? exact = _areas[prefix];
    if (exact != null) return exact;
    final Set<String> names = <String>{
      for (final MapEntry<String, String> e in _areas.entries)
        if (e.key.startsWith(prefix)) e.value,
    };
    return names.length == 1 ? names.single : null;
  }

  static String? captionOf(String Function(String key) group) =>
      lookup(group('prefix'));
}
