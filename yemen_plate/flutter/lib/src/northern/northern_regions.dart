import 'package:plate_core/plate_core.dart';

import '../common/yemen_governorates.dart';

/// Locates a northern-format plate from its governorate register.
abstract final class YemenRegions {
  /// The governorate whose code [digits] pins down, or null while a longer
  /// code could still follow (`1` may become `12`) or when unissued.
  static String? lookup(String digits) {
    if (digits.isEmpty || digits.startsWith('0')) return null;
    final List<YemenGovernorate> hits = <YemenGovernorate>[
      for (final YemenGovernorate g in YemenGovernorate.values)
        if ('${g.code}'.startsWith(digits)) g,
    ];
    return hits.length == 1 ? hits.single.englishName : null;
  }

  /// A [PlateLabelResolver] for [PlateSpec.resolveRegion].
  static String? captionOf(String Function(String key) group) =>
      lookup(group('governorate'));
}
