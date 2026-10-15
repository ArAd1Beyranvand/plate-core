import 'package:plate_core/plate_core.dart';

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

  /// The region of [code], or null when empty or unissued.
  static String? lookup(String code) => _regions[code];

  /// A [PlateLabelResolver] for [PlateSpec.resolveRegion].
  static String? captionOf(String Function(String key) group) =>
      lookup(group('region'));
}
