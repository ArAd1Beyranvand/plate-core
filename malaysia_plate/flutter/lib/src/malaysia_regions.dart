import 'package:plate_core/plate_core.dart';

/// Names the state, federal territory or division from the letter prefix.
///
/// `SG` is left out: the source gives it to both the Sarawak and the Sabah
/// government.
abstract final class MalaysiaRegions {
  static const Map<String, String> _prefixes = <String, String>{
    'A': 'Perak',
    'B': 'Selangor',
    'C': 'Pahang',
    'D': 'Kelantan',
    'F': 'Putrajaya',
    'J': 'Johor',
    'K': 'Kedah',
    'KV': 'Langkawi',
    'L': 'Labuan',
    'M': 'Malacca',
    'N': 'Negeri Sembilan',
    'P': 'Penang',
    'R': 'Perlis',
    'T': 'Terengganu',
    'V': 'Kuala Lumpur',
    'W': 'Kuala Lumpur',
    'QA': 'Kuching',
    'QB': 'Sri Aman / Betong',
    'QC': 'Samarahan / Serian',
    'QD': 'Bintulu',
    'QE': 'Sibu / Mukah',
    'QK': 'Kuching',
    'QL': 'Limbang',
    'QM': 'Miri',
    'QP': 'Kapit',
    'QR': 'Sarikei',
    'QS': 'Sibu / Mukah',
    'QSG': 'Sarawak Government',
    'QT': 'Bintulu',
    'SA': 'Kota Kinabalu',
    'SB': 'Beaufort',
    'SD': 'Lahad Datu',
    'SJ': 'Kota Kinabalu',
    'SK': 'Kudat',
    'SL': 'Labuan',
    'SM': 'Sandakan',
    'SMJ': 'Sabah Government',
    'SP': 'Lahad Datu',
    'SS': 'Sandakan',
    'ST': 'Tawau',
    'SU': 'Keningau',
    'SW': 'Tawau',
    'SY': 'Kota Kinabalu',
  };

  /// The place of the letters [prefix]: the longest code it starts with, else
  /// the one place every code beginning with it shares, else null (`Q` is
  /// several divisions).
  static String? lookup(String prefix) {
    if (prefix.isEmpty) return null;
    for (int n = prefix.length < 3 ? prefix.length : 3; n > 0; n--) {
      final String? name = _prefixes[prefix.substring(0, n)];
      if (name != null) return name;
    }
    final Set<String> names = <String>{
      for (final MapEntry<String, String> e in _prefixes.entries)
        if (e.key.startsWith(prefix)) e.value,
    };
    return names.length == 1 ? names.single : null;
  }

  /// A [PlateLabelResolver] for [PlateSpec.resolveRegion].
  static String? captionOf(String Function(String key) group) =>
      lookup(group('prefix'));
}
