import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../model/plate_asset.dart';
import '../model/plate_country.dart';
import 'plate_drawing_view.dart';

// TODO(ts): [D6] SVG <img>/inline svg with preserveAspectRatio="none" (BoxFit.fill); drawings via canvas.
// TODO(kt): [D6] Image(ContentScale.FillBounds); drawings via Canvas.
// TODO(py): [D6] QSvgRenderer into the rect, aspect ignored.
/// A country's flag, or nothing when it has none.
class PlateFlag extends StatelessWidget {
  const PlateFlag({super.key, required this.country, this.borderRadius});

  final PlateCountry country;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final asset = country.flag;
    if (asset == null) return const SizedBox.shrink();

    Widget flag = switch (asset) {
      SvgPlateAsset() => SvgPicture.asset(
        asset.path,
        package: asset.package,
        fit: BoxFit.fill,
      ),
      RasterPlateAsset() => Image.asset(
        asset.path,
        package: asset.package,
        fit: BoxFit.fill,
      ),
      PlateDrawing() => PlateDrawingView(drawing: asset),
    };

    final radius = borderRadius;
    if (radius != null) {
      flag = ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: flag,
      );
    }

    final borderColor = country.flagBorderColor;
    if (borderColor == null) return flag;
    return Container(
      foregroundDecoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 1),
      ),
      child: flag,
    );
  }
}
