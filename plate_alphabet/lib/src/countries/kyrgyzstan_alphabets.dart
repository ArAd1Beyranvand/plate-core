import 'package:plate_core/plate_core.dart';

/// The alphabets behind Kyrgyz slots.
///
/// Region codes are the eleven the article tabulates (01 Bishkek … 11
/// Temporary). Mission codes are its tables of countries (01–19) and
/// international organisations (50–64). The article states no restriction on
/// the serial letters of a private plate, so [letters] is the Latin capitals.
abstract final class KyrgyzstanAlphabets {
  /// The class letter of a diplomatic plate: C consular, D diplomatic,
  /// T technical staff.
  static const List<String> diplomaticClasses = <String>['C', 'D', 'T'];

  /// The class letter of a foreign-owned vehicle: H citizen, K media, M firm,
  /// P resident more than six months.
  static const List<String> foreignClasses = <String>['H', 'K', 'M', 'P'];

  static const List<String> regionCodes = <String>[
    '01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', //
  ];

  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static final List<String> missionCodes = <String>[
    for (var i = 1; i <= 19; i++) i.toString().padLeft(2, '0'),
    for (var i = 50; i <= 64; i++) '$i',
  ];

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'kg.letters',
    include: 'A-Z',
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
