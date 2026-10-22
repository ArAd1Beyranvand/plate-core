import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'plate_animation.dart';

/// Where one part is right now: what its painter or transition reads.
///
/// [progress] runs 0→1 across the current transition, delay and curve
/// already applied; it is complete while [phase] is settled.
@immutable
class PlatePartFrame {
  const PlatePartFrame({required this.phase, required this.progress, required this.motion});

  static const PlatePartFrame settled = PlatePartFrame(
    phase: PlatePartPhase.settled,
    progress: kAlwaysCompleteAnimation,
    motion: PlateMotion(),
  );

  final PlatePartPhase phase;
  final Animation<double> progress;
  final PlateMotion motion;

  /// How much of the part shows, 0 (gone) to 1 (as settled).
  double get shown => switch (phase) {
    PlatePartPhase.settled => 1,
    PlatePartPhase.comingIn => progress.value,
    PlatePartPhase.goingOut => 1 - progress.value,
  };

  /// True once a part has nothing left to paint.
  bool get hidden => shown <= 0;

  /// The span of a directional effect, as fractions along the run from its
  /// origin end: grows from the origin on the way in, erases from it on the
  /// way out.
  (double, double) get span {
    final t = progress.value;
    return switch (phase) {
      PlatePartPhase.settled => (0, 1),
      PlatePartPhase.comingIn => (0, t),
      PlatePartPhase.goingOut => (t, 1),
    };
  }
}

/// The part of [bounds] a wipe from [origin] leaves visible. An axis on
/// which [origin] is centred grows from the middle.
Rect plateRevealRect(Rect bounds, Alignment origin, PlatePartFrame frame) {
  final (a, b) = frame.span;
  if (a <= 0 && b >= 1) return bounds;
  final centred = origin.x == 0 && origin.y == 0;
  double axis(double o, double lo, double hi, bool start) {
    final len = hi - lo;
    if (o == 0) {
      if (!centred) return start ? lo : hi;
      // From the middle both ways: the span's length, centred.
      final f = start ? (1 - (b - a)) / 2 : (1 + (b - a)) / 2;
      return lo + len * f;
    }
    final f0 = o < 0 ? a : 1 - b;
    final f1 = o < 0 ? b : 1 - a;
    return lo + len * (start ? f0 : f1);
  }

  return Rect.fromLTRB(
    axis(origin.x, bounds.left, bounds.right, true),
    axis(origin.y, bounds.top, bounds.bottom, true),
    axis(origin.x, bounds.left, bounds.right, false),
    axis(origin.y, bounds.top, bounds.bottom, false),
  );
}

/// The one primitive behind every animated plate part. It owns the part's
/// controller, follows the part's cue from the nearest
/// [PlateAnimationScope], and either applies the part's [PlateMotion] to
/// [child] as paint-only transitions or — with [selfPainted] — leaves [child]
/// alone and hands it the [PlatePartFrame] through [PlatePartAnimator.of].
///
/// The transition chain is the same widgets in every phase, so a phase change
/// never remounts [child] — a slot's TextField keeps its focus and
/// controller. Settled, every link paints its child directly: no clip, no
/// layer, the plate exactly as without animation. While going out the part
/// ignores pointers.
class PlatePartAnimator extends StatefulWidget {
  const PlatePartAnimator({
    super.key,
    required this.id,
    required this.child,
    this.selfPainted = false,
    this.onComeInEnd,
    this.onGoOutEnd,
  });

  final PlatePartId id;
  final Widget child;

  /// True when [child] paints the effect itself from [PlatePartAnimator.of].
  final bool selfPainted;

  final VoidCallback? onComeInEnd;
  final VoidCallback? onGoOutEnd;

  /// The frame of the nearest animated part; settled outside one.
  static PlatePartFrame of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_PartScope>()?.frame ?? PlatePartFrame.settled;

  @override
  State<PlatePartAnimator> createState() => _PlatePartAnimatorState();
}

class _PlatePartAnimatorState extends State<PlatePartAnimator> with SingleTickerProviderStateMixin {
  PlateAnimationController? _host;
  ValueListenable<PlatePartCue>? _cue;
  AnimationController? _ticker;
  CurvedAnimation? _curved;
  PlatePartFrame _frame = PlatePartFrame.settled;
  _Chain _chain = _Chain.identity;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subscribe(PlateAnimationScope.maybeOf(context), widget.id);
  }

  @override
  void didUpdateWidget(PlatePartAnimator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id || oldWidget.selfPainted != widget.selfPainted) {
      _subscribe(_host, widget.id, force: true);
    }
  }

  void _subscribe(PlateAnimationController? host, PlatePartId id, {bool force = false}) {
    if (!force && identical(host, _host)) return;
    _cue?.removeListener(_onCue);
    _host = host;
    _cue = host?.cueOf(id);
    _cue?.addListener(_onCue);
    _apply(_cue?.value ?? PlatePartCue.settled);
  }

  void _onCue() => setState(() => _apply(_cue!.value));

  void _apply(PlatePartCue cue) {
    final host = _host;
    if (host == null || cue.phase == PlatePartPhase.settled) {
      _ticker?.stop();
      _frame = host == null
          ? PlatePartFrame.settled
          : PlatePartFrame(
              phase: PlatePartPhase.settled,
              progress: kAlwaysCompleteAnimation,
              motion: host.style.motionFor(widget.id),
            );
      _chain = _Chain.identity;
      return;
    }
    final motion = host.style.motionFor(widget.id);
    final wait = motion.delay + cue.delay;
    final total = wait + motion.duration;
    final ticker = _ticker ??= AnimationController(vsync: this)..addStatusListener(_onStatus);
    ticker.duration = total.inMicroseconds == 0 ? const Duration(microseconds: 1) : total;
    final start = total.inMicroseconds == 0 ? 0.0 : wait.inMicroseconds / total.inMicroseconds;
    _curved?.dispose();
    _curved = CurvedAnimation(
      parent: ticker,
      curve: Interval(start, 1, curve: motion.curve),
    );
    _frame = PlatePartFrame(phase: cue.phase, progress: _curved!, motion: motion);
    _chain = widget.selfPainted ? _Chain.identity : _Chain.of(_frame);
    if (cue.instant) {
      ticker.value = 1;
    } else {
      ticker.forward(from: 0);
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    switch (_frame.phase) {
      case PlatePartPhase.comingIn:
        widget.onComeInEnd?.call();
      case PlatePartPhase.goingOut:
        widget.onGoOutEnd?.call();
      case PlatePartPhase.settled:
        break;
    }
  }

  @override
  void dispose() {
    _cue?.removeListener(_onCue);
    _curved?.dispose();
    _ticker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chain = _chain;
    return _PartScope(
      frame: _frame,
      child: IgnorePointer(
        ignoring: _frame.phase == PlatePartPhase.goingOut,
        child: FadeTransition(
          opacity: chain.opacity,
          child: ClipRect(
            clipper: chain.clipper,
            clipBehavior: chain.clipper == null ? Clip.none : Clip.hardEdge,
            child: SlideTransition(
              position: chain.slide,
              child: ScaleTransition(
                scale: chain.scale,
                alignment: chain.scaleAlignment,
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The animations one phase plugs into the fixed transition chain. Built on a
/// phase change, never per frame.
class _Chain {
  const _Chain({
    required this.opacity,
    required this.slide,
    required this.scale,
    this.scaleAlignment = Alignment.center,
    this.clipper,
  });

  static const _Chain identity = _Chain(
    opacity: kAlwaysCompleteAnimation,
    slide: AlwaysStoppedAnimation<Offset>(Offset.zero),
    scale: kAlwaysCompleteAnimation,
  );

  factory _Chain.of(PlatePartFrame frame) {
    final shown = frame.phase == PlatePartPhase.goingOut
        ? ReverseAnimation(frame.progress)
        : frame.progress;
    final origin = frame.motion.origin;
    return switch (frame.motion.effect) {
      PlatePartEffect.fade => _Chain(opacity: shown, slide: identity.slide, scale: identity.scale),
      PlatePartEffect.wipe || PlatePartEffect.draw => _Chain(
        // A step, not a fade: skips painting a fully wiped part, paints the
        // rest without a layer.
        opacity: shown.drive(const _Gate()),
        slide: identity.slide,
        scale: identity.scale,
        clipper: _WipeClipper(frame),
      ),
      PlatePartEffect.fadeScale => _Chain(
        opacity: shown,
        slide: identity.slide,
        scale: shown.drive(Tween<double>(begin: 0.4, end: 1)),
        scaleAlignment: origin,
      ),
      PlatePartEffect.fadeSlide => _Chain(
        opacity: shown,
        slide: shown.drive(
          Tween<Offset>(begin: Offset(origin.x * 0.6, origin.y * 0.6), end: Offset.zero),
        ),
        scale: identity.scale,
      ),
    };
  }

  final Animation<double> opacity;
  final Animation<Offset> slide;
  final Animation<double> scale;
  final Alignment scaleAlignment;
  final CustomClipper<Rect>? clipper;
}

class _Gate extends Animatable<double> {
  const _Gate();

  @override
  double transform(double t) => t <= 0 ? 0 : 1;
}

class _WipeClipper extends CustomClipper<Rect> {
  _WipeClipper(this.frame) : super(reclip: frame.progress);

  final PlatePartFrame frame;

  @override
  Rect getClip(Size size) => plateRevealRect(Offset.zero & size, frame.motion.origin, frame);

  @override
  bool shouldReclip(_WipeClipper old) => !identical(old.frame, frame);
}

class _PartScope extends InheritedWidget {
  const _PartScope({required this.frame, required super.child});

  final PlatePartFrame frame;

  @override
  bool updateShouldNotify(_PartScope oldWidget) => !identical(oldWidget.frame, frame);
}
