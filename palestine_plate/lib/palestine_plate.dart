/// Palestine's licence plates for `plate_core`: the West Bank (`ف / P` block)
/// and Gaza (flag) are two designs, each with its own specs and validators.
/// Colour is derived from usage via `PSThemes.forUsage`.
///
/// ```dart
/// PlateCanvas(
///   spec: PSWestBankPlates.modernCar,
///   theme: PSThemes.forUsage(PSUsage.private),
///   onChooseCharacter: showMyPicker,
/// );
/// ```
library;

export 'src/gaza_plates.dart';
export 'src/palestine_alphabets.dart';
export 'src/palestine_colors.dart';
export 'src/palestine_country.dart';
export 'src/palestine_governorates.dart';
export 'src/palestine_serial_generator.dart';
export 'src/palestine_themes.dart';
export 'src/palestine_usage.dart';
export 'src/palestine_validators.dart';
export 'src/west_bank_plates.dart';
