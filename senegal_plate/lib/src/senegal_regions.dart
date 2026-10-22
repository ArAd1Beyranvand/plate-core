import 'package:plate_core/plate_core.dart';

/// Locates a Senegalese plate from its two-letter region code. No department
/// codes are documented, so the caption stops at the region.
abstract final class SenegalRegions {
  static const Map<String, String> _regions = <String, String>{
    'DK': 'Dakar',
    'DB': 'Diourbel',
    'FK': 'Fatick',
    'KA': 'Kaffrine',
    'KL': 'Kaolack',
    'KE': 'Kédougou',
    'KD': 'Kolda',
    'LG': 'Louga',
    'MT': 'Matam',
    'SL': 'Saint-Louis',
    'SE': 'Sédhiou',
    'TC': 'Tambacounda',
    'TH': 'Thiès',
    'ZG': 'Ziguinchor',
  };

  /// The region of [code] (one or two letters), or null when it matches no
  /// code or several (`D`, `K`, `S`, `T`).
  static String? lookup(String code) {
    if (code.isEmpty) return null;
    final Set<String> names = <String>{
      for (final MapEntry<String, String> e in _regions.entries)
        if (e.key.startsWith(code)) e.value,
    };
    return names.length == 1 ? names.single : null;
  }

  /// A [PlateLabelResolver] for [PlateSpec.resolveRegion].
  static String? captionOf(String Function(String key) group) => lookup(group('region'));
}
