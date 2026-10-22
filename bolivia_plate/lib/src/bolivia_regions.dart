import 'package:plate_core/plate_core.dart';

/// Locates a plate from its department letter.
///
/// Source: the "Current format 1000AAA" section of
/// https://en.wikipedia.org/wiki/Vehicle_registration_plates_of_Bolivia
abstract final class BoliviaRegions {
  static const Map<String, String> _codes = <String, String>{
    'C': 'Cochabamba',
    'H': 'Chuquisaca',
    'B': 'El Beni',
    'L': 'La Paz',
    'O': 'Oruro',
    'N': 'Pando',
    'P': 'Potosí',
    'S': 'Santa Cruz',
    'T': 'Tarija',
  };

  /// The name for [code], or null when it matches no code or several.
  static String? lookup(String code) {
    if (code.isEmpty) return null;
    final Set<String> names = <String>{
      for (final MapEntry<String, String> e in _codes.entries)
        if (e.key.startsWith(code)) e.value,
    };
    return names.length == 1 ? names.single : null;
  }

  /// A [PlateLabelResolver] for [PlateSpec.resolveRegion].
  static String? captionOf(String Function(String key) group) => lookup(group('department'));
}
