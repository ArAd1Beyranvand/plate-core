import 'package:plate_core/plate_core.dart';

/// The alphabets behind an Irish slot.
///
/// The county code is one or two letters, but only the sixteen letters that
/// the article's code tables use ever appear, so [countyLetters] is that set
/// and no other is accepted.
abstract final class RepublicOfIrelandAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet countyLetters = PlateAlphabet(
    id: 'ie.county.letters',
    characters: <String>[
      'C', 'D', 'E', 'G', 'H', 'K', 'L', 'M', //
      'N', 'O', 'R', 'S', 'T', 'W', 'X', 'Y',
    ],
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// Code to the Irish-language county name printed above the number, upper
  /// case. The current codes (article table 1) followed by the four formerly
  /// issued ones, which are still issued for imported vehicles first used
  /// abroad before 2014 (`LK`, `TN`, `TS`, `WD`; the article gives no Irish
  /// name for them, so each takes its county's).
  static const Map<String, String> countyNames = <String, String>{
    'C': 'CORCAIGH',
    'CE': 'AN CLÁR',
    'CN': 'AN CABHÁN',
    'CW': 'CEATHARLACH',
    'D': 'BAILE ÁTHA CLIATH',
    'DL': 'DÚN NA NGALL',
    'G': 'GAILLIMH',
    'KE': 'CILL DARA',
    'KK': 'CILL CHAINNIGH',
    'KY': 'CIARRAÍ',
    'L': 'LUIMNEACH',
    'LD': 'AN LONGFORT',
    'LH': 'LÚ',
    'LM': 'LIATROIM',
    'LS': 'LAOIS',
    'MH': 'AN MHÍ',
    'MN': 'MUINEACHÁN',
    'MO': 'MAIGH EO',
    'OY': 'UÍBH FHAILÍ',
    'RN': 'ROS COMÁIN',
    'SO': 'SLIGEACH',
    'T': 'TIOBRAID ÁRANN',
    'W': 'PORT LÁIRGE',
    'WH': 'AN IARMHÍ',
    'WX': 'LOCH GARMAN',
    'WW': 'CILL MHANTÁIN',
    'LK': 'LUIMNEACH',
    'TN': 'TIOBRAID ÁRANN',
    'TS': 'TIOBRAID ÁRANN',
    'WD': 'PORT LÁIRGE',
  };
}
