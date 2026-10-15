import 'package:flutter/foundation.dart';

/// An image a country package ships, addressed by the package that owns it.
@immutable
sealed class PlateAsset {
  const PlateAsset(this.path, {required this.package});

  final String path;

  /// The package that declares [path] in its `pubspec.yaml`, not the one
  /// rendering it.
  final String package;
}

/// Rasterised at device-pixel size, so a detailed emblem stays crisp at plate
/// scale. Prefer it for flags.
class SvgPlateAsset extends PlateAsset {
  const SvgPlateAsset(super.path, {required super.package});
}

class RasterPlateAsset extends PlateAsset {
  const RasterPlateAsset(super.path, {required super.package});
}
