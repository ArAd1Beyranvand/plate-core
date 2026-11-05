/// Lebanon's licence plates for the `plate_core` library.
///
/// Usage (the field colour) and [LebanonLetter] (town or class code) are
/// separate axes by design: `B 123456` and `Z 123456` are the same usage with
/// different letters, while a red and a yellow `M` plate share a letter but
/// differ in usage. A usage selects a theme and band via `LebanonThemes.forUsage`
/// and `LebanonCountry.forUsage`, not a spec. Dimensions and colours marked
/// `// CALIBRATE` come from photographs, not standards.
library;

export 'package:plate_alphabet/plate_alphabet.dart' show LebanonAlphabets;
export 'src/lebanon_alphabets.dart';
export 'src/lebanon_colors.dart';
export 'src/lebanon_country.dart';
export 'src/lebanon_letters.dart';
export 'src/lebanon_plates.dart';
export 'src/lebanon_regions.dart';
export 'src/lebanon_serial_generator.dart';
export 'src/lebanon_themes.dart';
export 'src/lebanon_usage.dart';
export 'src/lebanon_validators.dart';
