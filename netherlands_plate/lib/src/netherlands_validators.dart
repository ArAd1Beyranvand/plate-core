import 'package:plate_alphabet/plate_alphabet.dart';
import 'package:plate_core/plate_core.dart';

/// Judges a Dutch plate, field by field. Reports, never bars a keystroke.
///
/// Fields are the groups `a`, `b`, `c` of the plate. Each is letters or digits
/// as its slot's alphabet says. Ordinary registrations use only the
/// consonants `BDFGHJKLNPRSTVXZ`; the special series (`CD`, `AA`, `OK`, `WX`,
/// `EM`, `GV`, `BN`) print other letters, so a letter outside the consonants
/// is only reported when a field mixes it into an otherwise ordinary run of
/// three letters. The other article rules (no double zero in some sidecodes,
/// no SD/SS pairs) are series-specific and not enforced.
class NetherlandsValidator extends GatedPlateValidator {
  const NetherlandsValidator();

  @override
  String get gateGroup => 'a';

  static const String reasonCharacters = 'A field is letters A–Z or digits 0–9 only.';
  static const String reasonLetters =
      'Ordinary plates use only the letters B D F G H J K L N P R S T V X Z.';

  static final RegExp _alphanumeric = RegExp(r'^[A-Z0-9]+$');
  static final RegExp _upper = RegExp(r'^[A-Z]+$');

  @override
  PlateValidation judge(PlateEntry entry) {
    for (final String key in const <String>['a', 'b', 'c']) {
      final String field = entry.group(key);
      if (field.isNotEmpty && !_alphanumeric.hasMatch(field)) {
        return const PlateValidation.invalid(reasonCharacters);
      }
      if (field.length == 3 &&
          _upper.hasMatch(field) &&
          field != 'CDJ' &&
          field != 'BFG' &&
          !field.split('').every(NetherlandsAlphabets.consonants.contains)) {
        return const PlateValidation.invalid(reasonLetters);
      }
    }
    return const PlateValidation.valid();
  }
}
