import 'package:plate_core/plate_core.dart';

// TODO(py): [D4-code] hand-port; reason strings are the contract, keep them byte-identical.
// TODO(ts): [D4-code] hand-port; reason strings are the contract, keep them byte-identical.
// TODO(kt): [D4-code] hand-port; reason strings are the contract, keep them byte-identical.
/// Judges a Riyadh plate: three letters from the seventeen issued and one to
/// four digits. The combinations banned since 2009 are not checked; only
/// examples are published, not the list.
class RiyadhValidator extends GatedPlateValidator {
  const RiyadhValidator();

  @override
  String get gateGroup => 'serial';

  static const String reasonLetters = 'The register is three letters.';
  static const String reasonSerial = 'The number is one to four digits.';

  // TODO(py): [H9] Python re: \d/\w match Unicode; keep explicit [0-9]/[A-Z] classes (or re.ASCII).
  // TODO(ts): [H9] same flavour as Dart; port as is, cover accept/reject in the vectors (D9).
  // TODO(kt): [H9] Regex engine differs per target (JVM/JS/Native): keep to portable syntax.
  static final RegExp _letters = RegExp(r'^[ABJDRSXTEGKLZNHUV]{3}$');

  @override
  PlateValidation judge(PlateEntry entry) {
    if (!_letters.hasMatch(entry.group('letters'))) {
      return const PlateValidation.invalid(reasonLetters);
    }
    final String serial = entry.group('serial');
    if (!isDigits(serial) || serial.length > 4) {
      return const PlateValidation.invalid(reasonSerial);
    }
    return const PlateValidation.valid();
  }
}
