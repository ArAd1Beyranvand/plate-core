import 'india_alphabets.dart';

/// Names the state or union territory from the two-letter state code.
abstract final class IndiaRegions {
  static final Map<String, String> _states = <String, String>{
    ...IndiaAlphabets.stateNames,
    // Former codes are named by their current state.
    'UA': 'Uttarakhand',
    'OR': 'Odisha',
    'DN': 'Dadra and Nagar Haveli',
    'TS': 'Telangana',
  };

  static String? lookup(String code) => _states[code.toUpperCase()];

  // TODO(py): [D4-table] lookup table: becomes a dict in the export, no code.
  // TODO(ts): [D4-table] lookup table: becomes data in the export, no code.
  // TODO(kt): [D4-table] lookup table: becomes a map in the export, no code.
  static String? captionOf(String Function(String key) group) =>
      lookup(group('state'));
}
