import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';

/// One filled shape of a [PlateDrawing], in the drawing's own coordinate
/// space. Shapes paint in list order, so a later one covers an earlier one.
@immutable
sealed class PlateShape {
  const PlateShape(this.color);

  final Color color;

  Path toPath();
}

class PlateRectShape extends PlateShape {
  const PlateRectShape(
    this.left,
    this.top,
    this.width,
    this.height,
    super.color,
  );

  final double left, top, width, height;

  @override
  Path toPath() => Path()..addRect(Rect.fromLTWH(left, top, width, height));
}

class PlatePolygonShape extends PlateShape {
  const PlatePolygonShape(this.points, super.color);

  final List<Offset> points;

  @override
  Path toPath() => Path()..addPolygon(points, true);
}

class PlateCircleShape extends PlateShape {
  const PlateCircleShape(this.cx, this.cy, this.radius, super.color);

  final double cx, cy, radius;

  @override
  Path toPath() => _circle(cx, cy, radius);
}

/// The outline of a circle: a band [width] wide centred on [radius].
class PlateRingShape extends PlateShape {
  const PlateRingShape(this.cx, this.cy, this.radius, this.width, super.color);

  final double cx, cy, radius, width;

  @override
  Path toPath() => Path.combine(
    PathOperation.difference,
    _circle(cx, cy, radius + width / 2),
    _circle(cx, cy, radius - width / 2),
  );
}

/// A circle with a second circle taken out of it: a crescent. The bite is
/// [biteRadius] wide and sits [biteDx] to the right of the disc's centre (left
/// when negative).
class PlateCrescentShape extends PlateShape {
  const PlateCrescentShape(
    this.cx,
    this.cy,
    this.radius,
    this.biteDx,
    this.biteRadius,
    super.color,
  );

  final double cx, cy, radius, biteDx, biteRadius;

  @override
  Path toPath() => Path.combine(
    PathOperation.difference,
    _circle(cx, cy, radius),
    _circle(cx + biteDx, cy, biteRadius),
  );
}

/// A regular star. [rotation] turns it clockwise, in degrees, from one point
/// straight up. [innerRatio] is the inner radius over [radius]; the default is
/// the pentagram's.
class PlateStarShape extends PlateShape {
  const PlateStarShape(
    this.cx,
    this.cy,
    this.radius,
    super.color, {
    this.points = 5,
    this.innerRatio = pentagramRatio,
    this.rotation = 0,
  });

  /// Inner over outer radius of a five-pointed star drawn as one continuous
  /// line.
  static const double pentagramRatio = 0.3819660112501051;

  final double cx, cy, radius, innerRatio, rotation;
  final int points;

  @override
  Path toPath() => _star(cx, cy, radius, points, innerRatio, rotation);
}

/// [count] equal stars on a circle of [ringRadius], the first straight above
/// the centre and the rest clockwise from it, each one upright.
class PlateStarRingShape extends PlateShape {
  const PlateStarRingShape(
    this.cx,
    this.cy,
    this.ringRadius,
    this.starRadius,
    this.count,
    super.color, {
    this.points = 5,
    this.innerRatio = PlateStarShape.pentagramRatio,
  });

  final double cx, cy, ringRadius, starRadius, innerRatio;
  final int count, points;

  @override
  Path toPath() {
    final path = Path();
    for (var i = 0; i < count; i++) {
      final angle = 2 * math.pi * i / count;
      final x = cx + ringRadius * math.sin(angle);
      final y = cy - ringRadius * math.cos(angle);
      path.addPath(_star(x, y, starRadius, points, innerRatio, 0), Offset.zero);
    }
    return path;
  }
}

Path _circle(double cx, double cy, double radius) =>
    Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: radius));

Path _star(
  double cx,
  double cy,
  double radius,
  int points,
  double innerRatio,
  double rotation,
) {
  final path = Path();
  final turn = rotation * math.pi / 180;
  for (var i = 0; i < points * 2; i++) {
    final r = i.isEven ? radius : radius * innerRatio;
    final angle = turn + math.pi * i / points;
    final x = cx + r * math.sin(angle);
    final y = cy - r * math.cos(angle);
    i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
  }
  return path..close();
}
