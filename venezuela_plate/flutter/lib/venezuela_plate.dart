/// Venezuela's 2008 licence plate for the `plate_core` library.
///
/// One spec, one theme: the car plate, navy on the flag, with the state name
/// under the serial following the last letter. Colours marked `// CALIBRATE`
/// are from photographs.
library;

// TODO(py): [D5] one module `plates.countries.venezuela`; assets via importlib.resources.
// TODO(ts): [D5] one subpath export `./countries/venezuela`; tree-shakable.
// TODO(kt): [D5] package `countries.venezuela` in the countries module.
export 'src/venezuela_alphabets.dart';
export 'src/venezuela_colors.dart';
export 'src/venezuela_country.dart';
export 'src/venezuela_plates.dart';
export 'src/venezuela_themes.dart';
export 'src/venezuela_validators.dart';
