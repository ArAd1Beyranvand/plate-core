import 'package:plate_core/plate_core.dart';

/// The alphabets behind Kazakh slots.
///
/// Region codes are the twenty the article tabulates (01 Astana … 20
/// Ulytau). The article states no restriction on the serial letters, so
/// [letters] is the Latin capitals.
abstract final class KazakhstanAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static final List<String> regionCodes = <String>[
    for (var i = 1; i <= 20; i++) i.toString().padLeft(2, '0'),
  ];

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'kz.letters',
    include: 'A-Z',
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
