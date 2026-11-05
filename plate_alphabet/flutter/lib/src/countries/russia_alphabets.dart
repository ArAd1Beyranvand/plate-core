import 'package:plate_core/plate_core.dart';

/// The alphabets behind Russian slots.
///
/// Plates use only the twelve Cyrillic capitals that have a Latin twin
/// (А В Е К М Н О Р С Т У Х), so a plate reads the same abroad. They are stored
/// as the Latin twins, which print identically.
abstract final class RussiaAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'ru.letters',
    include: 'A B E K M H O P C T Y X',
  );

  /// The letters of a diplomatic plate, picked as a unit: `CD` ambassador,
  /// `D` diplomat, `T` administrative and technical staff.
  static const PlateAlphabet diplomaticStatus = PlateAlphabet(
    id: 'ru.diplomatic_status',
    characters: <String>['CD', 'D', 'T'],
    input: AlphabetInput.chosen,
    placeholder: 'CD',
  );
}
