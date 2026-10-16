import 'package:flutter/foundation.dart';

import 'plate_shape.dart';

/// Anything a flag slot can show: a file a package ships, or a [PlateDrawing]
/// made of const shapes.
@immutable
sealed class PlateGraphic {
  const PlateGraphic();
}

/// A picture built from filled [shapes] in a [width] x [height] space, painted
/// scaled to whatever box it is given. It ships no file and needs no pubspec
/// entry, and it is crisp at any size.
///
/// Later shapes cover earlier ones, so a flag is a full-size field with its
/// stripes laid over it; overlapping like that leaves no hairline between
/// neighbours at fractional scales.
class PlateDrawing extends PlateGraphic {
  const PlateDrawing(this.width, this.height, this.shapes);

  final double width;
  final double height;
  final List<PlateShape> shapes;
}

/// An image a country package ships, addressed by the package that owns it.
@immutable
sealed class PlateAsset extends PlateGraphic {
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
