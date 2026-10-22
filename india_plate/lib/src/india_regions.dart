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

  static String? captionOf(String Function(String key) group) => lookup(group('state'));
}
