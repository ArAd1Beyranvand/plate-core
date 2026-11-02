/// Malaysia's licence plates for the `plate_core` library.
///
/// Four geometries: single-row (width follows the registration), two-row,
/// diplomatic `NN-NN-DC` and the 2024 JPJePlate. Taxi, military and consular
/// plates are the single-row geometry on another theme.
library;

// TODO(py): [D5] one module `plates.countries.malaysia`; assets via importlib.resources.
// TODO(ts): [D5] one subpath export `./countries/malaysia`; tree-shakable.
// TODO(kt): [D5] package `countries.malaysia` in the countries module.
export 'src/malaysia_alphabets.dart';
export 'src/malaysia_colors.dart';
export 'src/malaysia_country.dart';
export 'src/malaysia_plates.dart';
export 'src/malaysia_regions.dart';
export 'src/malaysia_serial_generator.dart';
export 'src/malaysia_themes.dart';
export 'src/malaysia_validators.dart';
