import 'package:plate_core/plate_core.dart';

/// Names the state or union territory from the two-letter state code.
///
/// Source: "Part 1: Two-letter state code" (current and former codes) in
/// https://en.wikipedia.org/wiki/Vehicle_registration_plates_of_India
abstract final class IndiaRegions {
  static const Map<String, String> _states = <String, String>{
    'AN': 'Andaman and Nicobar Islands',
    'AP': 'Andhra Pradesh',
    'AR': 'Arunachal Pradesh',
    'AS': 'Assam',
    'BR': 'Bihar',
    'CG': 'Chhattisgarh',
    'CH': 'Chandigarh',
    'DD': 'Dadra and Nagar Haveli and Daman and Diu',
    'DL': 'Delhi',
    'GA': 'Goa',
    'GJ': 'Gujarat',
    'HP': 'Himachal Pradesh',
    'HR': 'Haryana',
    'JH': 'Jharkhand',
    'JK': 'Jammu and Kashmir',
    'KA': 'Karnataka',
    'KL': 'Kerala',
    'LA': 'Ladakh',
    'LD': 'Lakshadweep',
    'MH': 'Maharashtra',
    'ML': 'Meghalaya',
    'MN': 'Manipur',
    'MP': 'Madhya Pradesh',
    'MZ': 'Mizoram',
    'NL': 'Nagaland',
    'OD': 'Odisha',
    'PB': 'Punjab',
    'PY': 'Puducherry',
    'RJ': 'Rajasthan',
    'SK': 'Sikkim',
    'TG': 'Telangana',
    'TN': 'Tamil Nadu',
    'TR': 'Tripura',
    'UK': 'Uttarakhand',
    'UP': 'Uttar Pradesh',
    'WB': 'West Bengal',
    // Former codes, still valid on vehicles registered under them.
    'UA': 'Uttarakhand',
    'OR': 'Odisha',
    'DN': 'Dadra and Nagar Haveli',
    'TS': 'Telangana',
  };

  /// The state of [code], or null when short or unissued.
  static String? lookup(String code) => _states[code.toUpperCase()];

  /// A [PlateLabelResolver] for [PlateSpec.resolveRegion].
  static String? captionOf(String Function(String key) group) =>
      lookup(group('state'));
}
