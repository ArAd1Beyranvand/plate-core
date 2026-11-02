/// Yemen's licence plates for `plate_core`.
///
/// Two plate systems are current side by side: A, the 2026 unified white plate
/// with a light-blue side panel, and B, the 1993 northern format of stacked
/// registers coloured by usage. The south issues its own (Aden, Taiz, and the
/// coloured-strip plates of Hadhramaut, Al Mahrah, Shabwah and Marib), as does
/// Riyadh. The southern colours and artwork dimensions are measured from the
/// Wikipedia artwork; every other dimension and colour is `CALIBRATE`,
/// proportioned from photographs.
library;

// TODO(py): [D5] one module `plates.countries.yemen`; assets via importlib.resources.
// TODO(ts): [D5] one subpath export `./countries/yemen`; tree-shakable.
// TODO(kt): [D5] package `countries.yemen` in the countries module.
export 'package:plate_alphabet/plate_alphabet.dart' show RiyadhAlphabets;
export 'src/common/yemen_alphabets.dart';
export 'src/common/yemen_colors.dart';
export 'src/common/yemen_country.dart';
export 'src/common/yemen_governorates.dart';
export 'src/common/yemen_serial_generator.dart';
export 'src/common/yemen_themes.dart';
export 'src/common/yemen_usage.dart';
export 'src/common/yemen_validators.dart';
export 'src/northern/northern_plates.dart';
export 'src/northern/northern_regions.dart';
export 'src/riyadh/riyadh_colors.dart';
export 'src/riyadh/riyadh_country.dart';
export 'src/riyadh/riyadh_plates.dart';
export 'src/riyadh/riyadh_themes.dart';
export 'src/riyadh/riyadh_validators.dart';
export 'src/southern/aden_taiz_plates.dart';
export 'src/southern/governorate_plates.dart';
export 'src/unified/unified_plates.dart';
