import 'package:plate_core/plate_core.dart';

/// Locates a Swiss plate from its two-letter canton code.
///
/// Source: the canton table of
/// https://en.wikipedia.org/wiki/Vehicle_registration_plates_of_Switzerland
abstract final class SwitzerlandRegions {
  static const Map<String, String> _cantons = <String, String>{
    'AG': 'Aargau',
    'AI': 'Appenzell Innerrhoden',
    'AR': 'Appenzell Ausserrhoden',
    'BE': 'Bern',
    'BL': 'Basel-Landschaft',
    'BS': 'Basel-Stadt',
    'FR': 'Fribourg',
    'GE': 'Geneva',
    'GL': 'Glarus',
    'GR': 'Grisons',
    'JU': 'Jura',
    'LU': 'Lucerne',
    'NE': 'Neuchâtel',
    'NW': 'Nidwalden',
    'OW': 'Obwalden',
    'SG': 'St. Gallen',
    'SH': 'Schaffhausen',
    'SO': 'Solothurn',
    'SZ': 'Schwyz',
    'TG': 'Thurgau',
    'TI': 'Ticino',
    'UR': 'Uri',
    'VD': 'Vaud',
    'VS': 'Valais',
    'ZG': 'Zug',
    'ZH': 'Zürich',
  };

  /// The canton of [code], or null when incomplete or unissued.
  static String? lookup(String code) => _cantons[code.toUpperCase()];

  /// A [PlateLabelResolver] for [PlateSpec.resolveRegion].
  static String? captionOf(String Function(String key) group) => lookup(group('canton'));
}
