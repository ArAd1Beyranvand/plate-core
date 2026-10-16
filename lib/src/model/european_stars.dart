import 'dart:ui';

import 'plate_asset.dart';
import 'plate_shape.dart';

/// The EU's twelve gold stars, drawn rather than shipped, for every EU country
/// package to share.
abstract final class EuropeanStars {
  static const Color _gold = Color(0xFFFFCC00);

  /// Just the ring, on no field, for a panel that is already blue. Proportions
  /// of the band printed on an EU plate (46 x 70.4).
  static const PlateDrawing band = PlateDrawing(46, 70.4, <PlateShape>[
    PlateStarRingShape(23, 35.2, 14.36, 2.9, 12, _gold),
  ]);

  /// The EU flag: 3:2, blue, ring of twelve stars at its centre.
  static const PlateDrawing flag = PlateDrawing(900, 600, <PlateShape>[
    PlateRectShape(0, 0, 900, 600, Color(0xFF003399)),
    PlateStarRingShape(450, 300, 200, 37.5, 12, _gold),
  ]);
}
