import 'package:flutter/widgets.dart';

import '../model/plate_asset.dart';

/// Paints a [PlateDrawing] into whatever box it is given. [BoxFit.fill]
/// stretches it to the box, as a flag is; [BoxFit.contain] keeps its
/// proportions and centres it, as a decal is.
class PlateDrawingView extends StatelessWidget {
  const PlateDrawingView({
    super.key,
    required this.drawing,
    this.fit = BoxFit.fill,
  });

  final PlateDrawing drawing;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _DrawingPainter(drawing, fit),
    child: const SizedBox.expand(),
  );
}

class _DrawingPainter extends CustomPainter {
  const _DrawingPainter(this.drawing, this.fit);

  final PlateDrawing drawing;
  final BoxFit fit;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / drawing.width;
    final sy = size.height / drawing.height;
    final contain = fit == BoxFit.contain;
    final scaleX = contain ? (sx < sy ? sx : sy) : sx;
    final scaleY = contain ? scaleX : sy;
    canvas
      ..save()
      ..translate(
        (size.width - drawing.width * scaleX) / 2,
        (size.height - drawing.height * scaleY) / 2,
      )
      ..scale(scaleX, scaleY);
    final paint = Paint()..isAntiAlias = true;
    for (final shape in drawing.shapes) {
      canvas.drawPath(shape.toPath(), paint..color = shape.color);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_DrawingPainter oldDelegate) =>
      oldDelegate.drawing != drawing || oldDelegate.fit != fit;
}
