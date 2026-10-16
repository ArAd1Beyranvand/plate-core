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

  final double left;
  final double top;
  final double width;
  final double height;

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

  final double cx;
  final double cy;
  final double radius;

  @override
  Path toPath() =>
      Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: radius));
}

/// The outline of a circle: a band [width] wide centred on [radius].
class PlateRingShape extends PlateShape {
  const PlateRingShape(this.cx, this.cy, this.radius, this.width, super.color);

  final double cx;
  final double cy;
  final double radius;
  final double width;

  @override
  Path toPath() => Path.combine(
    PathOperation.difference,
    Path()
      ..addOval(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius + width / 2),
      ),
    Path()
      ..addOval(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius - width / 2),
      ),
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

  final double cx;
  final double cy;
  final double radius;
  final double biteDx;
  final double biteRadius;

  @override
  Path toPath() => Path.combine(
    PathOperation.difference,
    Path()
      ..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: radius)),
    Path()
      ..addOval(
        Rect.fromCircle(center: Offset(cx + biteDx, cy), radius: biteRadius),
      ),
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

  final double cx;
  final double cy;
  final double radius;
  final int points;
  final double innerRatio;
  final double rotation;

  @override
  Path toPath() => _starPath(
    cx: cx,
    cy: cy,
    radius: radius,
    points: points,
    innerRatio: innerRatio,
    rotation: rotation,
  );
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

  final double cx;
  final double cy;
  final double ringRadius;
  final double starRadius;
  final int count;
  final int points;
  final double innerRatio;

  @override
  Path toPath() {
    final path = Path();
    for (var i = 0; i < count; i++) {
      final angle = 2 * math.pi * i / count;
      path.addPath(
        _starPath(
          cx: cx + ringRadius * math.sin(angle),
          cy: cy - ringRadius * math.cos(angle),
          radius: starRadius,
          points: points,
          innerRatio: innerRatio,
          rotation: 0,
        ),
        Offset.zero,
      );
    }
    return path;
  }
}

Path _starPath({
  required double cx,
  required double cy,
  required double radius,
  required int points,
  required double innerRatio,
  required double rotation,
}) {
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
