/// Cuba's 2013 licence plates for the `plate_core` library.
///
/// Three specs, one theme: a car for natural persons (white CUBA strip), a car
/// for legal entities (blue strip), and a motorcycle. Every plate is black on
/// white; colours marked `// CALIBRATE` are from photographs.
library;

// TODO(py): [D5] one module `plates.countries.cuba`; assets via importlib.resources.
// TODO(ts): [D5] one subpath export `./countries/cuba`; tree-shakable.
// TODO(kt): [D5] package `countries.cuba` in the countries module.
export 'src/cuba_alphabets.dart';
export 'src/cuba_colors.dart';
export 'src/cuba_country.dart';
export 'src/cuba_plates.dart';
export 'src/cuba_themes.dart';
export 'src/cuba_validators.dart';
