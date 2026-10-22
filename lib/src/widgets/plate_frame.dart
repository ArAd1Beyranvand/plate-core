import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/widgets.dart';

import '../animation/plate_animation.dart';
import '../animation/plate_part_animator.dart';
import '../model/plate_spec.dart';
import '../theme/plate_theme.dart';
import 'plate_divider.dart';

/// The plate's background: the face divided into [PlateSection] regions, the
/// dividers between them, and the border drawn last over all of it.
///
/// Each of those is its own animated part, but they stay painters on one
/// picture, in that order, each clipped to the same face — which is what
/// keeps a coloured region flush with the border. A region runs out under the
/// border rather than stopping at its inner edge, so the only edge between
/// them is the border's own, and there is no second anti-aliased edge for the
/// field to show through.
class PlateFrame extends StatelessWidget {
  const PlateFrame({
    super.key,
    this.theme,
    this.isCompleted = false,
    this.background = PlateSection.plain,
    this.panelColor = const Color(0x00000000),
  });

  final PlateTheme? theme;
  final bool isCompleted;
  final PlateSection background;

  /// What [PlateFill.panel] resolves to: the rendered country's panel colour.
  final Color panelColor;

  @override
  Widget build(BuildContext context) {
    final theme = this.theme ?? PlateTheme.of(context);
    final regions = plateRegionCount(background);
    final dividers = plateDividerCount(background);
    return _RimParts(
      child: Stack(
        fit: StackFit.expand,
        children: [
          PlatePartAnimator(
            id: PlatePartId.background,
            selfPainted: true,
            child: _FacePaint(theme: theme),
          ),
          for (var i = 0; i < regions; i++)
            PlatePartAnimator(
              id: PlatePartId.region(i),
              selfPainted: true,
              child: _RegionPaint(
                index: i,
                theme: theme,
                background: background,
                panelColor: panelColor,
              ),
            ),
          for (var i = 0; i < dividers; i++)
            PlatePartAnimator(
              id: PlatePartId.divider(i),
              selfPainted: true,
              child: _SectionDividerPaint(index: i, theme: theme, background: background),
            ),
          PlatePartAnimator(
            id: PlatePartId.border,
            selfPainted: true,
            child: _BorderPaint(theme: theme, isCompleted: isCompleted),
          ),
        ],
      ),
    );
  }
}

/// The frames of the rim parts that are not painters of their own: the corner
/// radius, the border colour and the border width.
@immutable
class _RimFrames {
  const _RimFrames({
    this.corner = PlatePartFrame.settled,
    this.borderColor = PlatePartFrame.settled,
    this.borderWidth = PlatePartFrame.settled,
  });

  final PlatePartFrame corner;
  final PlatePartFrame borderColor;
  final PlatePartFrame borderWidth;

  /// Ticks whenever any of the three moves.
  Listenable get progress =>
      Listenable.merge(<Listenable>[corner.progress, borderColor.progress, borderWidth.progress]);

  _RimFrames with_(PlatePartId id, PlatePartFrame frame) => _RimFrames(
    corner: id == PlatePartId.corner ? frame : corner,
    borderColor: id == PlatePartId.borderColor ? frame : borderColor,
    borderWidth: id == PlatePartId.borderWidth ? frame : borderWidth,
  );

  @override
  bool operator ==(Object other) =>
      other is _RimFrames &&
      identical(other.corner, corner) &&
      identical(other.borderColor, borderColor) &&
      identical(other.borderWidth, borderWidth);

  @override
  int get hashCode => Object.hash(corner, borderColor, borderWidth);
}

class _RimScope extends InheritedWidget {
  const _RimScope({required this.rim, required super.child});

  final _RimFrames rim;

  static _RimFrames of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_RimScope>()!.rim;

  @override
  bool updateShouldNotify(_RimScope old) => old.rim != rim;
}

/// Runs [id] (the corner, border colour or border width) over [child] and
/// publishes its frame in [_RimScope] beside the others'.
class _RimPart extends StatelessWidget {
  const _RimPart({required this.id, required this.child});

  final PlatePartId id;
  final Widget child;

  @override
  Widget build(BuildContext context) => PlatePartAnimator(
    id: id,
    selfPainted: true,
    child: _RimCapture(id: id, child: child),
  );
}

class _RimCapture extends StatelessWidget {
  const _RimCapture({required this.id, required this.child});

  final PlatePartId id;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final outer = context.dependOnInheritedWidgetOfExactType<_RimScope>();
    return _RimScope(
      rim: (outer?.rim ?? const _RimFrames()).with_(id, PlatePartAnimator.of(context)),
      child: child,
    );
  }
}

/// Runs the three rim parts over [child].
class _RimParts extends StatelessWidget {
  const _RimParts({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => _RimPart(
    id: PlatePartId.corner,
    child: _RimPart(
      id: PlatePartId.borderColor,
      child: _RimPart(id: PlatePartId.borderWidth, child: child),
    ),
  );
}

/// Clips [child] to the plate's face as the frame draws it, following the
/// corner radius and border width as they animate, so what is printed on the
/// face never pokes past a rim that is still growing.
class PlateRimClip extends StatelessWidget {
  const PlateRimClip({super.key, required this.theme, required this.child});

  final PlateTheme theme;
  final Widget child;

  @override
  Widget build(BuildContext context) => _RimParts(
    child: _RimClip(theme: theme, child: child),
  );
}

class _RimClip extends StatelessWidget {
  const _RimClip({required this.theme, required this.child});

  final PlateTheme theme;
  final Widget child;

  @override
  Widget build(BuildContext context) => ClipRRect(
    clipper: _RimClipper(theme: theme, rim: _RimScope.of(context)),
    child: child,
  );
}

class _RimClipper extends CustomClipper<RRect> {
  _RimClipper({required this.theme, required this.rim}) : super(reclip: rim.progress);

  final PlateTheme theme;
  final _RimFrames rim;

  /// Content bleeds this far under the border paint: clipping to the face's
  /// exact edge leaves a hairline seam where two anti-aliased edges meet.
  static const _overlap = 0.75;

  @override
  RRect getClip(Size size) {
    final g = _Geometry(theme, size, rim);
    return RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(math.max(0.0, g.border - _overlap)),
      Radius.circular(g.innerRadius),
    );
  }

  @override
  bool shouldReclip(_RimClipper old) => old.theme != theme || old.rim != rim;
}

/// The outer rim, its inner edge, and the face the regions are clipped to.
class _Geometry {
  _Geometry(PlateTheme theme, Size size, _RimFrames rim)
    : border = theme.borderWidthRatio * size.height * rim.borderWidth.shown.clamp(0.0, 1.0),
      outerRadius = theme.plateRadiusRatio * size.height * rim.corner.shown.clamp(0.0, 1.0) {
    innerRadius = (outerRadius - border).clamp(0.0, outerRadius);
    final outerRect = Offset.zero & size;
    outer = RRect.fromRectAndRadius(outerRect, Radius.circular(outerRadius));
    inner = RRect.fromRectAndRadius(outerRect.deflate(border), Radius.circular(innerRadius));
    // Halfway into the border: far enough out that the border's inner edge
    // lies over a region, not past one; far enough in that a region's edge
    // never reaches the plate's outer anti-aliased rim.
    face = outer.deflate(border / 2);
  }

  final double border;
  final double outerRadius;
  late final double innerRadius;
  late final RRect outer;
  late final RRect inner;
  late final RRect face;
}

bool _fades(PlatePartFrame frame) => switch (frame.motion.effect) {
  PlatePartEffect.fade || PlatePartEffect.fadeScale || PlatePartEffect.fadeSlide => true,
  PlatePartEffect.wipe || PlatePartEffect.draw => false,
};

class _FacePaint extends StatelessWidget {
  const _FacePaint({required this.theme});

  final PlateTheme theme;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _FacePainter(
      frame: PlatePartAnimator.of(context),
      rim: _RimScope.of(context),
      theme: theme,
    ),
  );
}

class _FacePainter extends CustomPainter {
  _FacePainter({required this.frame, required this.rim, required this.theme})
    : super(repaint: Listenable.merge([frame.progress, rim.progress]));

  final PlatePartFrame frame;
  final _RimFrames rim;
  final PlateTheme theme;
  final Paint _paint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    if (frame.hidden) return;
    final g = _Geometry(theme, size, rim);
    final color = theme.plateBackground;
    canvas.save();
    if (frame.phase != PlatePartPhase.settled && !_fades(frame)) {
      canvas.clipRect(plateRevealRect(Offset.zero & size, frame.motion.origin, frame));
    }
    canvas.clipRRect(g.face);
    _paint.color = _fades(frame) ? color.withValues(alpha: color.a * frame.shown) : color;
    canvas.drawRRect(g.face, _paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_FacePainter old) =>
      !identical(old.frame, frame) || old.rim != rim || old.theme != theme;
}

class _RegionPaint extends StatelessWidget {
  const _RegionPaint({
    required this.index,
    required this.theme,
    required this.background,
    required this.panelColor,
  });

  final int index;
  final PlateTheme theme;
  final PlateSection background;
  final Color panelColor;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _RegionPainter(
      frame: PlatePartAnimator.of(context),
      rim: _RimScope.of(context),
      index: index,
      theme: theme,
      background: background,
      panelColor: panelColor,
    ),
  );
}

class _RegionPainter extends CustomPainter {
  _RegionPainter({
    required this.frame,
    required this.rim,
    required this.index,
    required this.theme,
    required this.background,
    required this.panelColor,
  }) : super(repaint: Listenable.merge([frame.progress, rim.progress]));

  final PlatePartFrame frame;
  final _RimFrames rim;
  final int index;
  final PlateTheme theme;
  final PlateSection background;
  final Color panelColor;

  final Paint _paint = Paint();
  Size? _laidOutFor;
  (PlateSection, Rect)? _leaf;

  @override
  void paint(Canvas canvas, Size size) {
    if (frame.hidden) return;
    if (_laidOutFor != size) {
      _laidOutFor = size;
      _leaf = background.layout(Offset.zero & size).leaves.elementAtOrNull(index);
    }
    final leaf = _leaf;
    if (leaf == null) return;
    final (section, r) = leaf;
    final fill = section.fill!;
    // The field is already down; painting it again would only add a second
    // anti-aliased edge along each neighbour's boundary.
    if (fill.isField) return;

    final g = _Geometry(theme, size, rim);
    final fades = _fades(frame);
    canvas.save();
    canvas.clipRRect(g.face);
    if (frame.phase != PlatePartPhase.settled && !fades) {
      canvas.clipRect(plateRevealRect(r, frame.motion.origin, frame));
    }
    final opacity = fades ? frame.shown : 1.0;
    if (fill.isStripes) {
      _paintStripes(canvas, fill, r, section.shape, opacity);
    } else {
      _paint
        ..shader = null
        ..color = _alpha(
          fill.resolve(
            field: theme.plateBackground,
            panel: panelColor,
            divider: theme.dividerColor,
          ),
          opacity,
        );
      final shape = section.shape;
      if (shape == null) {
        canvas.drawRect(r, _paint);
      } else {
        canvas.translate(r.left, r.top);
        canvas.drawPath(shape.getClip(r.size), _paint);
      }
    }
    canvas.restore();
  }

  static Color _alpha(Color c, double opacity) =>
      opacity >= 1 ? c : c.withValues(alpha: c.a * opacity);

  /// Each stripe is a rect in a frame turned about [r]'s centre, long enough
  /// to cover [r] at any angle, and clipped back to [r] (or its [shape]).
  void _paintStripes(
    Canvas canvas,
    PlateFill fill,
    Rect r,
    CustomClipper<Path>? shape,
    double opacity,
  ) {
    final stripes = fill.stripes!;
    final c = r.center;
    final reach = r.longestSide;
    final cos = math.cos(fill.angle);
    canvas.save();
    if (shape == null) {
      canvas.clipRect(r);
    } else {
      canvas.clipPath(shape.getClip(r.size).shift(r.topLeft));
    }
    canvas.translate(c.dx, c.dy);
    canvas.rotate(-fill.angle);
    var top = -reach;
    _paint.shader = null;
    for (var i = 0; i < stripes.length; i++) {
      // A stop is where the boundary meets the centreline; in the turned frame
      // that is its perpendicular distance from the centre.
      final bottom = i < fill.stops.length ? (fill.stops[i] - c.dy) * cos : reach;
      final stripe = stripes[i];
      if (!stripe.isField) {
        _paint.color = _alpha(
          stripe.resolve(
            field: theme.plateBackground,
            panel: panelColor,
            divider: theme.dividerColor,
          ),
          opacity,
        );
        canvas.drawRect(Rect.fromLTRB(-reach, top, reach, bottom), _paint);
      }
      top = bottom;
    }
    canvas.restore();
    final fog = fill.fog;
    if (fog != null) {
      final field = theme.plateBackground;
      final a = fog.opacity * opacity;
      canvas.save();
      canvas.clipRect(r);
      canvas.translate(fog.center.dx, fog.center.dy);
      canvas.scale(fog.radii.width, fog.radii.height);
      _paint.shader = RadialGradient(
        colors: <Color>[
          field.withValues(alpha: a),
          field.withValues(alpha: a),
          field.withValues(alpha: 0),
        ],
        stops: <double>[0, fog.plateau, 1],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: 1));
      canvas.drawCircle(Offset.zero, 1, _paint);
      _paint.shader = null;
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_RegionPainter old) =>
      !identical(old.frame, frame) ||
      old.rim != rim ||
      old.index != index ||
      old.theme != theme ||
      old.background != background ||
      old.panelColor != panelColor;
}

class _SectionDividerPaint extends StatelessWidget {
  const _SectionDividerPaint({required this.index, required this.theme, required this.background});

  final int index;
  final PlateTheme theme;
  final PlateSection background;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _SectionDividerPainter(
      frame: PlatePartAnimator.of(context),
      rim: _RimScope.of(context),
      color: theme.dividerColor,
      index: index,
      theme: theme,
      background: background,
    ),
  );
}

class _SectionDividerPainter extends PlateDividerPainter {
  _SectionDividerPainter({
    required super.frame,
    required this.rim,
    required super.color,
    required this.index,
    required this.theme,
    required this.background,
  }) : super(alsoRepaintOn: rim.progress);

  final _RimFrames rim;
  final int index;
  final PlateTheme theme;
  final PlateSection background;

  Size? _laidOutFor;
  Rect? _rect;

  void _layout(Size size) {
    if (_laidOutFor == size) return;
    _laidOutFor = size;
    _rect = background.layout(Offset.zero & size).dividers.elementAtOrNull(index);
  }

  @override
  Rect? rectOf(Size size) {
    _layout(size);
    return _rect;
  }

  @override
  RRect? clipOf(Size size) => _Geometry(theme, size, rim).face;

  @override
  bool shouldRepaint(PlateDividerPainter old) =>
      super.shouldRepaint(old) ||
      old is! _SectionDividerPainter ||
      old.rim != rim ||
      old.index != index ||
      old.theme != theme ||
      old.background != background;
}

class _BorderPaint extends StatelessWidget {
  const _BorderPaint({required this.theme, required this.isCompleted});

  final PlateTheme theme;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _BorderPainter(
      frame: PlatePartAnimator.of(context),
      rim: _RimScope.of(context),
      theme: theme,
      isCompleted: isCompleted,
    ),
  );
}

/// Settled: the rim as a filled ring between the outer and inner rounded
/// rects. Drawing: a stroke along the ring's centreline, grown from
/// [PlateMotion.startPoint] and erased from it in the same direction.
class _BorderPainter extends CustomPainter {
  _BorderPainter({
    required this.frame,
    required this.rim,
    required this.theme,
    required this.isCompleted,
  }) : super(repaint: Listenable.merge([frame.progress, rim.progress]));

  final PlatePartFrame frame;
  final _RimFrames rim;

  final PlateTheme theme;
  final bool isCompleted;

  final Paint _fill = Paint();
  final Paint _stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.butt;
  final Path _segment = Path();
  Size? _measuredFor;
  double? _measuredRadius;
  double? _measuredBorder;
  PathMetric? _metric;

  @override
  void paint(Canvas canvas, Size size) {
    if (frame.hidden) return;
    final g = _Geometry(theme, size, rim);
    final color = _borderColor();
    final motion = frame.motion;
    final (a, b) = frame.span;
    final whole = a <= 0 && b >= 1;
    if (whole || motion.effect != PlatePartEffect.draw) {
      _fill.color = whole || !_fades(frame)
          ? color
          : color.withValues(alpha: color.a * frame.shown);
      if (whole || _fades(frame)) {
        canvas.drawDRRect(g.outer, g.inner, _fill);
      } else {
        canvas.save();
        canvas.clipRect(plateRevealRect(Offset.zero & size, motion.origin, frame));
        canvas.drawDRRect(g.outer, g.inner, _fill);
        canvas.restore();
      }
      return;
    }

    final metric = _metricFor(size, g);
    final length = metric.length;
    final s = (motion.startPoint % 1) * length;
    _segment.reset();
    if (motion.clockwise) {
      _addSpan(metric, s + a * length, s + b * length);
    } else {
      _addSpan(metric, s - b * length, s - a * length);
    }
    _stroke
      ..color = color
      ..strokeWidth = g.border;
    canvas.drawPath(_segment, _stroke);
  }

  /// [from]..[to] along the closed ring, either end allowed past the seam.
  void _addSpan(PathMetric metric, double from, double to) {
    final length = metric.length;
    var lo = from % length;
    final span = to - from;
    if (lo + span <= length) {
      _segment.addPath(metric.extractPath(lo, lo + span), Offset.zero);
    } else {
      _segment.addPath(metric.extractPath(lo, length), Offset.zero);
      _segment.addPath(metric.extractPath(0, lo + span - length), Offset.zero);
    }
  }

  /// The ring's centreline, clockwise from the top-left corner.
  PathMetric _metricFor(Size size, _Geometry g) {
    final cached = _metric;
    if (cached != null &&
        _measuredFor == size &&
        _measuredRadius == g.outerRadius &&
        _measuredBorder == g.border) {
      return cached;
    }
    final half = g.border / 2;
    final rect = (Offset.zero & size).deflate(half);
    final r = math.max(0.0, g.outerRadius - half);
    final path = Path()
      ..moveTo(rect.left + r, rect.top)
      ..lineTo(rect.right - r, rect.top)
      ..arcTo(
        Rect.fromCircle(center: Offset(rect.right - r, rect.top + r), radius: r),
        -math.pi / 2,
        math.pi / 2,
        false,
      )
      ..lineTo(rect.right, rect.bottom - r)
      ..arcTo(
        Rect.fromCircle(center: Offset(rect.right - r, rect.bottom - r), radius: r),
        0,
        math.pi / 2,
        false,
      )
      ..lineTo(rect.left + r, rect.bottom)
      ..arcTo(
        Rect.fromCircle(center: Offset(rect.left + r, rect.bottom - r), radius: r),
        math.pi / 2,
        math.pi / 2,
        false,
      )
      ..lineTo(rect.left, rect.top + r)
      ..arcTo(
        Rect.fromCircle(center: Offset(rect.left + r, rect.top + r), radius: r),
        math.pi,
        math.pi / 2,
        false,
      )
      ..close();
    _measuredFor = size;
    _measuredRadius = g.outerRadius;
    _measuredBorder = g.border;
    return _metric = path.computeMetrics().first;
  }

  Color _borderColor() {
    final settled = isCompleted
        ? Color.lerp(theme.plateBorder, theme.plateBackground, 0.02) ?? theme.plateBorder
        : theme.plateBorder;
    final shown = rim.borderColor.shown.clamp(0.0, 1.0);
    if (shown >= 1) return settled;
    return Color.lerp(theme.plateBackground, settled, shown) ?? settled;
  }

  @override
  bool shouldRepaint(_BorderPainter old) =>
      !identical(old.frame, frame) ||
      old.rim != rim ||
      old.theme != theme ||
      old.isCompleted != isCompleted;
}
