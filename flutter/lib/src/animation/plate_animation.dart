import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../model/plate_box.dart';
import '../model/plate_spec.dart';

/// Where a plate part is in its lifecycle. [settled] is the default and paints
/// the part exactly as a plate without animation does.
enum PlatePartPhase { comingIn, settled, goingOut }

/// The kinds of visual part a plate is made of. Closed: the library owns the
/// renderer, so it owns the list of things it renders.
enum PlatePartKind {
  /// The face's base colour.
  background,

  /// The plate's outer corner radius, grown from square.
  corner,

  /// One leaf of [PlateSpec.background], indexed in depth-first order.
  region,

  /// One [PlatePart.divider] of [PlateSpec.background], depth-first.
  divider,

  /// The rim's thickness, grown from nothing.
  borderWidth,

  /// The rim's colour, blended in from the face.
  borderColor,

  /// The rim.
  border,

  /// The country block's own colour, when the panel paints it.
  panel,

  /// The flag on the country block.
  flag,

  /// The heading and caption wording on the country block.
  caption,

  /// One of [PlateSpec.bands].
  band,

  /// The corner radius of one of [PlateSpec.bands], grown from square.
  bandCorner,

  /// One of [PlateSpec.rules].
  rule,

  /// One of [PlateSpec.labels].
  label,

  /// One of [PlateSpec.decals].
  decal,

  /// One of [PlateSpec.slots].
  slot,

  /// One of [PlateSpec.mirrors].
  mirror,
}

// TODO(ts): [D9] structural key: use `${kind}:${index}` strings as Map keys; allOf(spec) is a vector.
// TODO(kt): [D9] data class PlatePartId(kind, index) — structural equality is right here.
// TODO(py): [D9] frozen dataclass (hashable); allOf is a vector.
/// A stable address for one part of a plate: its [kind] and, for a kind a
/// spec has several of, its [index] in the spec's own list.
@immutable
class PlatePartId {
  const PlatePartId(this.kind, [this.index = 0]);

  const PlatePartId.region(int index) : this(PlatePartKind.region, index);
  const PlatePartId.divider(int index) : this(PlatePartKind.divider, index);
  const PlatePartId.band(int index) : this(PlatePartKind.band, index);
  const PlatePartId.bandCorner(int index)
    : this(PlatePartKind.bandCorner, index);
  const PlatePartId.rule(int index) : this(PlatePartKind.rule, index);
  const PlatePartId.label(int index) : this(PlatePartKind.label, index);
  const PlatePartId.decal(int index) : this(PlatePartKind.decal, index);
  const PlatePartId.slot(int index) : this(PlatePartKind.slot, index);
  const PlatePartId.mirror(int index) : this(PlatePartKind.mirror, index);

  static const PlatePartId background = PlatePartId(PlatePartKind.background);
  static const PlatePartId corner = PlatePartId(PlatePartKind.corner);
  static const PlatePartId borderColor = PlatePartId(PlatePartKind.borderColor);
  static const PlatePartId borderWidth = PlatePartId(PlatePartKind.borderWidth);
  static const PlatePartId border = PlatePartId(PlatePartKind.border);
  static const PlatePartId panel = PlatePartId(PlatePartKind.panel);
  static const PlatePartId flag = PlatePartId(PlatePartKind.flag);
  static const PlatePartId caption = PlatePartId(PlatePartKind.caption);

  final PlatePartKind kind;
  final int index;

  /// Every part [spec] renders, in painting order.
  static List<PlatePartId> allOf(PlateSpec spec) => <PlatePartId>[
    background,
    corner,
    for (var i = 0; i < plateRegionCount(spec.background); i++)
      PlatePartId.region(i),
    for (var i = 0; i < plateDividerCount(spec.background); i++)
      PlatePartId.divider(i),
    borderWidth,
    borderColor,
    border,
    if (!spec.noPanel) ...<PlatePartId>[panel, flag, caption],
    for (var i = 0; i < spec.bands.length; i++) PlatePartId.band(i),
    for (var i = 0; i < spec.bands.length; i++) PlatePartId.bandCorner(i),
    for (var i = 0; i < spec.rules.length; i++) PlatePartId.rule(i),
    for (var i = 0; i < spec.labels.length; i++) PlatePartId.label(i),
    for (var i = 0; i < spec.decals.length; i++) PlatePartId.decal(i),
    for (var i = 0; i < spec.mirrors.length; i++) PlatePartId.mirror(i),
    for (var i = 0; i < spec.slots.length; i++) PlatePartId.slot(i),
  ];

  @override
  bool operator ==(Object other) =>
      other is PlatePartId && other.kind == kind && other.index == index;

  @override
  int get hashCode => Object.hash(kind, index);

  @override
  String toString() => switch (kind) {
    PlatePartKind.background ||
    PlatePartKind.corner ||
    PlatePartKind.borderWidth ||
    PlatePartKind.borderColor ||
    PlatePartKind.border ||
    PlatePartKind.panel ||
    PlatePartKind.flag ||
    PlatePartKind.caption => kind.name,
    _ => '${kind.name} $index',
  };
}

// TODO(ts): derive from layout(); never count leaves by a second walk.
// TODO(kt): same.
// TODO(py): same.
/// How many leaves [section] has — the [PlatePartKind.region] count.
int plateRegionCount(PlateSection section) =>
    section.layout(Rect.zero).leaves.length;

/// How many dividers [section] draws — the [PlatePartKind.divider] count.
int plateDividerCount(PlateSection section) =>
    section.layout(Rect.zero).dividers.length;

/// How a part appears and disappears.
enum PlatePartEffect {
  /// Opacity.
  fade,

  /// A clip that grows from [PlateMotion.origin] on the way in and erases
  /// from the same side on the way out.
  wipe,

  /// Grows from [PlateMotion.origin], fading as it goes.
  fadeScale,

  /// Slides in from [PlateMotion.origin], fading as it goes.
  fadeSlide,

  /// The stroke travels the perimeter (border) or the line's length
  /// (divider, rule) from the origin; any other part treats it as [wipe].
  draw,
}

// TODO(ts): [H11] duration/delay as integer ms; curve as a name from the shared cubic-bezier table.
// TODO(kt): [H11] Long ms; curve -> CubicBezierEasing with Flutter's control points, not Compose presets.
// TODO(py): [H11] int ms; QEasingCurve.BezierSpline with the same points (InOutCubic differs).
/// The timing and look of one part's transitions.
@immutable
class PlateMotion {
  const PlateMotion({
    this.effect = .fade,
    this.duration = const Duration(milliseconds: 420),
    this.curve = Curves.easeInOutCubic,
    this.delay = Duration.zero,
    this.origin = .centerLeft,
    this.startPoint = 0,
    this.clockwise = true,
    this.softEdge = false,
  });

  final PlatePartEffect effect;
  final Duration duration;
  final Curve curve;

  /// Added before every transition of the part; a cue's own delay adds to it.
  final Duration delay;

  // TODO(ts): [H10] {x, y} in [-1, 1]; centre is (0, 0), not (0.5, 0.5).
  // TODO(kt): [H10] own Alignment(x, y) in [-1,1]; Compose BiasAlignment matches, Alignment.Center does too.
  // TODO(py): [H10] tuple (x, y) in [-1, 1].
  /// Where a directional effect starts. For a divider or rule only the sign
  /// along its axis counts: negative is its left/top end, positive its
  /// right/bottom end.
  final Alignment origin;

  /// For the border: where the stroke starts, as a fraction of the perimeter
  /// measured clockwise from the top-left corner.
  final double startPoint;

  /// For the border: the stroke's direction of travel.
  final bool clockwise;

  /// For a divider or rule: a short alpha ramp at the moving edge.
  final bool softEdge;

  PlateMotion copyWith({
    PlatePartEffect? effect,
    Duration? duration,
    Curve? curve,
    Duration? delay,
    Alignment? origin,
    double? startPoint,
    bool? clockwise,
    bool? softEdge,
  }) => PlateMotion(
    effect: effect ?? this.effect,
    duration: duration ?? this.duration,
    curve: curve ?? this.curve,
    delay: delay ?? this.delay,
    origin: origin ?? this.origin,
    startPoint: startPoint ?? this.startPoint,
    clockwise: clockwise ?? this.clockwise,
    softEdge: softEdge ?? this.softEdge,
  );
}

/// The [PlateMotion] each part uses: one per kind, with optional overrides
/// for single parts.
@immutable
class PlateAnimationStyle {
  const PlateAnimationStyle({
    this.byKind = defaults,
    this.overrides = const <PlatePartId, PlateMotion>{},
  });

  final Map<PlatePartKind, PlateMotion> byKind;
  final Map<PlatePartId, PlateMotion> overrides;

  // TODO(ts): [D9] the table is data: export it with the curves by name.
  // TODO(kt): [D9] same.
  // TODO(py): [D9] same.
  static const Map<PlatePartKind, PlateMotion> defaults = {
    .background: PlateMotion(effect: .wipe, origin: .center),
    .region: PlateMotion(effect: .wipe),
    .divider: PlateMotion(effect: .draw, origin: .topCenter, softEdge: true),
    .corner: PlateMotion(effect: .fade, duration: Duration(milliseconds: 600)),
    .borderWidth: PlateMotion(
      effect: .fade,
      duration: Duration(milliseconds: 600),
    ),
    .borderColor: PlateMotion(
      effect: .fade,
      duration: Duration(milliseconds: 600),
    ),
    .border: PlateMotion(effect: .draw, duration: Duration(milliseconds: 900)),
    .panel: PlateMotion(effect: .wipe),
    .flag: PlateMotion(effect: .wipe),
    .caption: PlateMotion(effect: .wipe, origin: .topCenter),
    .band: PlateMotion(effect: .wipe),
    .bandCorner: PlateMotion(effect: .fade),
    .rule: PlateMotion(effect: .draw, origin: .topCenter, softEdge: true),
    .label: PlateMotion(effect: .wipe),
    .decal: PlateMotion(effect: .fadeScale, origin: .center),
    .slot: PlateMotion(effect: .fadeSlide, origin: .bottomCenter),
    .mirror: PlateMotion(effect: .fadeSlide, origin: .bottomCenter),
  };

  PlateMotion motionFor(PlatePartId id) =>
      overrides[id] ?? byKind[id.kind] ?? const PlateMotion();
}

/// One instruction to a part: go to [phase] after [delay]. [serial] tells a
/// repeated instruction from a stale one, so cueing `comingIn` twice replays.
@immutable
class PlatePartCue {
  const PlatePartCue(
    this.phase, {
    this.delay = Duration.zero,
    this.serial = 0,
    this.instant = false,
  });

  static const PlatePartCue settled = PlatePartCue(PlatePartPhase.settled);

  final PlatePartPhase phase;
  final Duration delay;
  final int serial;

  /// Jump to the end of [phase] with no transition.
  final bool instant;
}

// TODO(ts): [D7] a store of cues keyed by part id; parts subscribe to their own key only.
// TODO(kt): [D7] MutableStateFlow<PlatePartCue> per id in a map; fallback cue for ids not seen yet.
// TODO(py): [D7] Observable per id; QVariantAnimation per mounted part in the ui layer.
/// Drives the phases of a plate's parts, all at once or one at a time. Hand
/// it to [PlateCanvas.animation] (or put it above any plate with a
/// [PlateAnimationScope]).
///
/// Each part listens only to its own cue, so cueing one part rebuilds nothing
/// else. Every part starts [PlatePartPhase.settled].
class PlateAnimationController extends ChangeNotifier {
  PlateAnimationController({
    PlateAnimationStyle style = const PlateAnimationStyle(),
  }) : _style = style;

  PlateAnimationStyle _style;
  PlateAnimationStyle get style => _style;
  set style(PlateAnimationStyle value) {
    if (identical(value, _style)) return;
    _style = value;
    notifyListeners();
  }

  final Map<PlatePartId, ValueNotifier<PlatePartCue>> _cues = {};
  PlatePartCue _fallback = PlatePartCue.settled;
  int _serial = 0;

  /// The live cue for [id]; a part subscribes to this.
  ValueListenable<PlatePartCue> cueOf(PlatePartId id) =>
      _cues.putIfAbsent(id, () => ValueNotifier<PlatePartCue>(_fallback));

  /// The phase [id] was last told to take.
  PlatePartPhase phaseOf(PlatePartId id) =>
      (_cues[id]?.value ?? _fallback).phase;

  ValueNotifier<PlatePartCue> _notifierOf(PlatePartId id) =>
      cueOf(id) as ValueNotifier<PlatePartCue>;

  /// Cues one part.
  void cue(
    PlatePartId id,
    PlatePartPhase phase, {
    Duration delay = Duration.zero,
  }) {
    _notifierOf(id).value = PlatePartCue(
      phase,
      delay: delay,
      serial: ++_serial,
    );
  }

  void comeIn(PlatePartId id, {Duration delay = Duration.zero}) =>
      cue(id, .comingIn, delay: delay);

  void goOut(PlatePartId id, {Duration delay = Duration.zero}) =>
      cue(id, .goingOut, delay: delay);

  void settle(PlatePartId id) => cue(id, .settled);

  /// Takes [id] straight to gone, with no transition.
  void hide(PlatePartId id) {
    _notifierOf(id).value = PlatePartCue(
      PlatePartPhase.goingOut,
      serial: ++_serial,
      instant: true,
    );
  }

  /// Cues every part — including ones not mounted yet — to [phase]. A part
  /// named in [delays] waits that long first; see [PlateStagger].
  void cueAll(
    PlatePartPhase phase, {
    Map<PlatePartId, Duration> delays = const {},
  }) {
    final serial = ++_serial;
    _fallback = PlatePartCue(phase, serial: serial);
    final ids = <PlatePartId>{..._cues.keys, ...delays.keys};
    for (final id in ids) {
      _notifierOf(id).value = PlatePartCue(
        phase,
        delay: delays[id] ?? Duration.zero,
        serial: serial,
      );
    }
  }

  void comeInAll({Map<PlatePartId, Duration> delays = const {}}) =>
      cueAll(.comingIn, delays: delays);

  void goOutAll({Map<PlatePartId, Duration> delays = const {}}) =>
      cueAll(.goingOut, delays: delays);

  void settleAll() => cueAll(.settled);

  @override
  void dispose() {
    for (final n in _cues.values) {
      n.dispose();
    }
    super.dispose();
  }
}

// TODO(ts): [H19][D9] plain function staggerSequence(spec, {stepMs, reverse}); vector the delays.
// TODO(kt): [H19] object PlateStagger.
// TODO(py): [H19] module function stagger_sequence.
/// Delay maps for [PlateAnimationController.cueAll]: a plate composing
/// itself part by part.
abstract final class PlateStagger {
  /// Each of [spec]'s parts [step] after the one before, in painting order
  /// ([PlatePartId.allOf]); [reverse] for a plate taking itself apart.
  static Map<PlatePartId, Duration> sequence(
    PlateSpec spec, {
    Duration step = const Duration(milliseconds: 60),
    bool reverse = false,
  }) {
    final ids = PlatePartId.allOf(spec);
    final ordered = reverse ? ids.reversed.toList() : ids;
    return {for (var i = 0; i < ordered.length; i++) ordered[i]: step * i};
  }
}

/// How long a [PlateAnimationController.cueAll] with [delays] runs under
/// [style], for the parts in [ids].
Duration plateCueLength(
  PlateAnimationStyle style,
  Iterable<PlatePartId> ids,
  Map<PlatePartId, Duration> delays,
) {
  var longest = Duration.zero;
  for (final id in ids) {
    final m = style.motionFor(id);
    final end = (delays[id] ?? Duration.zero) + m.delay + m.duration;
    if (end > longest) longest = end;
  }
  return longest;
}

// TODO(ts): [H4] keep is a callback; specs never export it, the holder passes it in code.
// TODO(kt): [H4] keep: ((PlatePartId, PlateSpec, PlateSpec) -> Boolean?)?.
// TODO(py): [H4] keep: Callable | None.
/// What a [PlateCanvas] does when its spec changes: the old plate goes out
/// part by part, then the new one comes in, except the parts [keeps] — those
/// swap in place with no transition.
///
/// A part is kept when its kind is in [keepKinds] and both plates have it,
/// or when [keep] says so. The default keeps nothing.
@immutable
class PlateSpecTransition {
  const PlateSpecTransition({
    this.keepKinds = const <PlatePartKind>{},
    this.keep,
    this.keepIdentical = false,
    this.morphBackground = false,
    this.step = const Duration(milliseconds: 60),
  });

  /// Also keep every part both plates draw the same way — see [samePart].
  final bool keepIdentical;

  /// The face's base colour stays put and blends into the next plate's while
  /// the canvas resizes, instead of going out and coming back in.
  final bool morphBackground;

  final Set<PlatePartKind> keepKinds;

  /// Per-part decision from the outgoing and incoming plates; overrides
  /// [keepKinds] when it returns non-null.
  final bool? Function(PlatePartId id, PlateSpec from, PlateSpec to)? keep;

  /// The stagger between consecutive parts, as in [PlateStagger.sequence].
  final Duration step;

  /// [fromValues] and [toValues] are the characters each plate shows, for
  /// judging slots; without them no slot is identical.
  bool keeps(
    PlatePartId id,
    PlateSpec from,
    PlateSpec to, {
    List<String?>? fromValues,
    List<String?>? toValues,
  }) {
    if (id.kind == PlatePartKind.bandCorner) {
      return keeps(
        PlatePartId.band(id.index),
        from,
        to,
        fromValues: fromValues,
        toValues: toValues,
      );
    }
    final decided = keep?.call(id, from, to);
    if (decided != null) return decided;
    if (keepIdentical &&
        samePart(id, from, to, fromValues: fromValues, toValues: toValues)) {
      return true;
    }
    return keepKinds.contains(id.kind) &&
        PlatePartId.allOf(from).contains(id) &&
        PlatePartId.allOf(to).contains(id);
  }

  // TODO(ts): [H1][D9] shape identity becomes path-string equality once clippers are data; vector it.
  // TODO(kt): [H1] compare path strings, not lambdas.
  // TODO(py): [H1] compare path strings.
  /// True when [from] and [to] would paint [id] identically, as far as the
  /// specs say: same canvas, and the part's own data equal. Covers the panel
  /// (block, flag, caption), background regions and dividers, bands, rules,
  /// labels, and slots showing the same character (or none) in the same box.
  /// The border and the face behind the regions always redraw.
  static bool samePart(
    PlatePartId id,
    PlateSpec from,
    PlateSpec to, {
    List<String?>? fromValues,
    List<String?>? toValues,
  }) {
    if (from.canvasWidth != to.canvasWidth ||
        from.canvasHeight != to.canvasHeight) {
      return false;
    }
    final i = id.index;
    switch (id.kind) {
      case .panel || .flag || .caption:
        final a = from.panel, b = to.panel;
        return !from.noPanel &&
            !to.noPanel &&
            from.country == to.country &&
            from.country.panelColor == to.country.panelColor &&
            _sameBox(a.box, b.box) &&
            a.flagScale == b.flagScale &&
            a.captionScale == b.captionScale &&
            a.padding == b.padding &&
            a.direction == b.direction &&
            identical(a.shape, b.shape);
      case .region:
        final a = _layout(from).leaves.elementAtOrNull(i);
        final b = _layout(to).leaves.elementAtOrNull(i);
        if (a == null || b == null) return false;
        return a.$2 == b.$2 &&
            identical(a.$1.shape, b.$1.shape) &&
            _sameFill(a.$1.fill!, b.$1.fill!) &&
            (!a.$1.paintsPanel ||
                from.country.panelColor == to.country.panelColor);
      case .divider:
        final a = _layout(from).dividers.elementAtOrNull(i);
        final b = _layout(to).dividers.elementAtOrNull(i);
        return a != null && a == b && from.inkOverride == to.inkOverride;
      case .slot:
        if (fromValues == null || toValues == null) return false;
        if (i >= from.slots.length || i >= to.slots.length) return false;
        if (i >= fromValues.length || i >= toValues.length) return false;
        final a = from.slots[i], b = to.slots[i];
        final va = fromValues[i] ?? '', vb = toValues[i] ?? '';
        return va == vb &&
            _sameBox(a.box, b.box) &&
            a.color == b.color &&
            from.inkOverride == to.inkOverride;
      case .band:
        if (i >= from.bands.length || i >= to.bands.length) return false;
        final a = from.bands[i], b = to.bands[i];
        return _sameBox(a.box, b.box) &&
            a.color == b.color &&
            a.topCornerRadius == b.topCornerRadius &&
            a.bottomCornerRadius == b.bottomCornerRadius;
      case .rule:
        if (i >= from.rules.length || i >= to.rules.length) return false;
        return _sameBox(from.rules[i].box, to.rules[i].box) &&
            from.inkOverride == to.inkOverride;
      case .label:
        if (i >= from.labels.length || i >= to.labels.length) return false;
        final a = from.labels[i], b = to.labels[i];
        return _sameBox(a.box, b.box) &&
            a.text == b.text &&
            a.glyphHeight == b.glyphHeight &&
            a.color == b.color &&
            a.rotated == b.rotated &&
            a.lineHeight == b.lineHeight &&
            a.fontFamily == b.fontFamily &&
            a.fontPackage == b.fontPackage;
      default:
        return false;
    }
  }

  static bool _sameFill(PlateFill a, PlateFill b) {
    if (identical(a, b)) return true;
    if (a.isStripes || b.isStripes) return false;
    return a.isField == b.isField &&
        a.isPanel == b.isPanel &&
        a.color == b.color &&
        a.fog == null &&
        b.fog == null;
  }

  static ({List<(PlateSection, Rect)> leaves, List<Rect> dividers}) _layout(
    PlateSpec spec,
  ) => spec.background.layout(
    Rect.fromLTWH(0, 0, spec.canvasWidth, spec.canvasHeight),
  );

  static bool _sameBox(PlateBox a, PlateBox b) =>
      a.left == b.left &&
      a.top == b.top &&
      a.width == b.width &&
      a.height == b.height;
}

// TODO(ts): [H14] drop — pass the controller to render/painter.
// TODO(kt): [H14] CompositionLocal LocalPlateAnimation.
// TODO(py): [H14] drop — constructor argument.
/// Puts a [PlateAnimationController] above the plate parts beneath it. With
/// none, every part is settled and costs nothing beyond its wrapper.
class PlateAnimationScope extends InheritedWidget {
  const PlateAnimationScope({
    super.key,
    required this.controller,
    required super.child,
  });

  final PlateAnimationController? controller;

  static PlateAnimationController? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<PlateAnimationScope>()
      ?.controller;

  @override
  bool updateShouldNotify(PlateAnimationScope oldWidget) =>
      oldWidget.controller != controller;
}
