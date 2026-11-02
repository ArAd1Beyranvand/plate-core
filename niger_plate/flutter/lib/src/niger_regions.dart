/// Locates a Nigerien plate from its leading regional digit.
///
/// Source: the "Regional Codes" section of
/// https://en.wikipedia.org/wiki/Vehicle_registration_plates_of_Niger
abstract final class NigerRegions {
  static const Map<String, String> _regions = <String, String>{
    '1': 'Agadez',
    '2': 'Diffa',
    '3': 'Dosso',
    '4': 'Maradi',
    '5': 'Tahoua',
    '6': 'Tillabéri',
    '7': 'Zinder',
    '8': 'Niamey',
  };

  static String? lookup(String code) => _regions[code];

  // TODO(py): [D4-table] lookup table: becomes a dict in the export, no code.
  // TODO(ts): [D4-table] lookup table: becomes data in the export, no code.
  // TODO(kt): [D4-table] lookup table: becomes a map in the export, no code.
  static String? captionOf(String Function(String key) group) =>
      lookup(group('region'));
}
