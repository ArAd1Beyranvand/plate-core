/// India's licence plates for the `plate_core` library.
///
/// One 500×120 layout for every current format; the colour class (private,
/// transport, rental, electric, diplomatic, ...) is a theme, never a spec.
library;

// TODO(py): [D5] one module `plates.countries.india`; assets via importlib.resources.
// TODO(ts): [D5] one subpath export `./countries/india`; tree-shakable.
// TODO(kt): [D5] package `countries.india` in the countries module.
export 'src/india_alphabets.dart';
export 'src/india_colors.dart';
export 'src/india_country.dart';
export 'src/india_missions.dart';
export 'src/india_plates.dart';
export 'src/india_regions.dart';
export 'src/india_themes.dart';
export 'src/india_validators.dart';
