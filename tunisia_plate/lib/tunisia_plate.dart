/// Tunisia's licence plates for the `plate_core` library.
///
/// The ordinary plate is `NNN تونس NNNN` — series, the word "Tunisia",
/// registration — on one line or, at the rear, on two. Rental, government,
/// diplomatic, military and temporary plates complete the set.
library;

// TODO(py): [D5] one module `plates.countries.tunisia`; assets via importlib.resources.
// TODO(ts): [D5] one subpath export `./countries/tunisia`; tree-shakable.
// TODO(kt): [D5] package `countries.tunisia` in the countries module.
export 'src/tunisia_alphabets.dart';
export 'src/tunisia_colors.dart';
export 'src/tunisia_country.dart';
export 'src/tunisia_plates.dart';
export 'src/tunisia_serial_generator.dart';
export 'src/tunisia_themes.dart';
export 'src/tunisia_validators.dart';
