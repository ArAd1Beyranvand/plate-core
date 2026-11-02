import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// The alphabets behind Swiss slots.
///
/// [letters] is all of A–Z: which pairs are cantons (and that military plates
/// open with a lone `M`) is a registry rule, reported by `SwitzerlandValidator`
/// rather than barred here.
abstract final class SwitzerlandAlphabets {
  static const PlateAlphabet digits = PlateAlphabetDigits.english;

  static const PlateAlphabet letters = PlateAlphabetLatin.typed;

  /// The `U` printed after a dealer's number. Fixed, so the slot offers
  /// nothing else.
  static const PlateAlphabet dealerMark = PlateAlphabet(
    id: 'ch.dealer_mark',
    characters: <String>['U'],
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// The `Z` after a duty-unpaid plate's control mark.
  static const PlateAlphabet customsMark = PlateAlphabet(
    id: 'ch.customs_mark',
    characters: <String>['Z'],
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// The white prefix on the blue band of a diplomatic plate.
  static const PlateAlphabet diplomaticCd = PlateAlphabet(
    id: 'ch.diplomatic_cd',
    characters: <String>['CD'],
    input: AlphabetInput.chosen,
    isNumeric: false,
  );

  /// The white prefix on the green band of a consular plate. The article also
  /// names an `AT` prefix (administrative and technical staff) but shows no
  /// plate for it, so it is not drawn.
  static const PlateAlphabet diplomaticCc = PlateAlphabet(
    id: 'ch.diplomatic_cc',
    characters: <String>['CC'],
    input: AlphabetInput.chosen,
    isNumeric: false,
  );
}
