import 'package:plate_core/plate_core.dart';

/// Locates a Lebanese plate from its registration letter.
///
/// Source: the "Codes" table of
/// https://en.wikipedia.org/wiki/Vehicle_registration_plates_of_Lebanon
/// `K` (Baalbek) is marked "Not in use" there and is left out; the letters of
/// judges, clergy, parliament, motorcycles and service plates name no town.
abstract final class LebanonRegions {
  static const Map<String, String> _towns = <String, String>{
    'B': 'Beirut',
    'Y': 'Aley, Mount Lebanon',
    'G': 'Jounieh, Mount Lebanon',
    'N': 'Nabatiye',
    'O': 'Ouzai, Mount Lebanon',
    'S': 'Sidon, South Lebanon',
    'T': 'Tripoli, North Lebanon',
    'Z': 'Zahleh, Beqaa',
  };

  /// The town of [letter], or null when empty or not a town letter.
  static String? lookup(String letter) => _towns[letter];

  /// A [PlateLabelResolver] for [PlateSpec.resolveRegion].
  static String? captionOf(String Function(String key) group) =>
      lookup(group('letter'));
}
