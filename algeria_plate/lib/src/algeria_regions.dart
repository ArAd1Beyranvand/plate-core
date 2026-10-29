import 'package:plate_core/plate_core.dart';

part 'algeria_regions_data.dart';

/// Locates an Algerian plate from its trailing wilaya code.
abstract final class AlgeriaRegions {
  /// The wilaya of [code], or null while it is incomplete or not issued.
  static String? lookup(String code) =>
      code.length == 2 ? _wilayas[code] : null;

  // TODO(py): [D4-table] lookup table: becomes a dict in the export, no code.
  // TODO(ts): [D4-table] lookup table: becomes data in the export, no code.
  // TODO(kt): [D4-table] lookup table: becomes a map in the export, no code.
  /// A [PlateLabelResolver] for [PlateSpec.resolveRegion].
  static String? captionOf(String Function(String key) group) =>
      lookup(group('wilaya'));
}
