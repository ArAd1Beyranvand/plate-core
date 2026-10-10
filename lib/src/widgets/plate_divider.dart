import 'package:flutter/widgets.dart';

import '../animation/plate_animation.dart';
import '../animation/plate_part_animator.dart';

/// Which end of a divider its effect starts at: [start] is the left or top
/// end, [end] the right or bottom.
enum DividerOrigin { start, end }

/// A solid line filling its box — vertical when taller than wide — that draws
/// itself in and erases itself out with the enclosing [PlatePartAnimator].
/// Settled it paints exactly what a `ColoredBox` of [color] does.
class PlateDivider extends StatelessWidget {
  const PlateDivider({super.key, required this.color, this.origin});

  final Color color;

  /// Overrides the part's [PlateMotion.origin] along the line's axis.
  final DividerOrigin? origin;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: PlateDividerPainter(
      frame: PlatePartAnimator.of(context),
      color: color,
      origin: origin,
    ),
    child: const SizedBox.expand(),
  );
}

/// Paints one divider line into [rect] (the whole canvas when null), clipped
/// to [clip] when given. Shared by [PlateDivider] and the frame's own
/// background dividers.
class PlateDividerPainter extends CustomPainter {
  PlateDividerPainter({
    required this.frame,
    required this.color,
    this.origin,
    this.rect,
    this.clip,
  }) : super(repaint: frame.progress);

  final PlatePartFrame frame;
  final Color color;
  final DividerOrigin? origin;
  final Rect? rect;
  final RRect? clip;

  final Paint _paint = Paint();

  static const _rampSteps = 3;

  /// Where the line lies in a canvas of [size]; null paints nothing.
  @protected
  Rect? rectOf(Size size) => rect ?? Offset.zero & size;

  @protected
  RRect? clipOf(Size size) => clip;

  @override
  void paint(Canvas canvas, Size size) {
    if (frame.hidden) return;
    final r = rectOf(size);
    if (r == null) return;
    final clip = clipOf(size);
    if (clip != null) {
      canvas.save();
      canvas.clipRRect(clip);
    }
    final motion = frame.motion;
    if (frame.phase == PlatePartPhase.settled ||
        motion.effect == PlatePartEffect.fade ||
        motion.effect == PlatePartEffect.fadeScale ||
        motion.effect == PlatePartEffect.fadeSlide) {
      _paint.color = color.withValues(alpha: color.a * frame.shown);
      canvas.drawRect(r, _paint);
    } else {
      _paintSpan(canvas, r);
    }
    if (clip != null) canvas.restore();
  }

  void _paintSpan(Canvas canvas, Rect r) {
    final vertical = r.height > r.width;
    final fromEnd =
        (origin ??
            _originOf(
              vertical ? frame.motion.origin.y : frame.motion.origin.x,
            )) ==
        DividerOrigin.end;
    var (a, b) = frame.span;
    if (fromEnd) (a, b) = (1 - b, 1 - a);
    final lo = vertical ? r.top : r.left;
    final len = vertical ? r.height : r.width;
    Rect along(double f0, double f1) => vertical
        ? Rect.fromLTRB(r.left, lo + len * f0, r.right, lo + len * f1)
        : Rect.fromLTRB(lo + len * f0, r.top, lo + len * f1, r.bottom);

    // The moving edge: the head on the way in, the tail on the way out.
    final comingIn = frame.phase == PlatePartPhase.comingIn;
    final moving = comingIn != fromEnd ? b : a;
    final ramp = frame.motion.softEdge
        ? ((vertical ? r.width : r.height) * 3 / len).clamp(0.0, b - a)
        : 0.0;
    _paint.color = color;
    if (ramp <= 0) {
      canvas.drawRect(along(a, b), _paint);
      return;
    }
    final towardLo = moving == a;
    canvas.drawRect(towardLo ? along(a + ramp, b) : along(a, b - ramp), _paint);
    final step = ramp / _rampSteps;
    for (var i = 0; i < _rampSteps; i++) {
      _paint.color = color.withValues(
        alpha: color.a * (_rampSteps - i) / (_rampSteps + 1),
      );
      final f = i * step;
      canvas.drawRect(
        towardLo
            ? along(a + ramp - f - step, a + ramp - f)
            : along(b - ramp + f, b - ramp + f + step),
        _paint,
      );
    }
  }

  static DividerOrigin _originOf(double o) =>
      o > 0 ? DividerOrigin.end : DividerOrigin.start;

  @override
  bool shouldRepaint(PlateDividerPainter old) =>
      !identical(old.frame, frame) ||
      old.color != color ||
      old.origin != origin ||
      old.rect != rect ||
      old.clip != clip;
}
