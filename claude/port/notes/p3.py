A = 'plate_core/lib/src/animation/plate_animation.dart'
P = 'plate_core/lib/src/animation/plate_part_animator.dart'
NOTES = [
 (A, 'class PlatePartId {', [
  'TODO(ts): [D9] structural key: use `${kind}:${index}` strings as Map keys; allOf(spec) is a vector.',
  'TODO(kt): [D9] data class PlatePartId(kind, index) — structural equality is right here.',
  'TODO(py): [D9] frozen dataclass (hashable); allOf is a vector.']),
 (A, 'int plateRegionCount(', [
  'TODO(ts): derive from layout(); never count leaves by a second walk.',
  'TODO(kt): same.',
  'TODO(py): same.']),
 (A, 'class PlateMotion {', [
  'TODO(ts): [H11] duration/delay as integer ms; curve as a name from the shared cubic-bezier table.',
  'TODO(kt): [H11] Long ms; curve -> CubicBezierEasing with Flutter\'s control points, not Compose presets.',
  'TODO(py): [H11] int ms; QEasingCurve.BezierSpline with the same points (InOutCubic differs).']),
 (A, 'final Alignment origin;', [
  'TODO(ts): [H10] {x, y} in [-1, 1]; centre is (0, 0), not (0.5, 0.5).',
  'TODO(kt): [H10] own Alignment(x, y) in [-1,1]; Compose BiasAlignment matches, Alignment.Center does too.',
  'TODO(py): [H10] tuple (x, y) in [-1, 1].']),
 (A, 'static const Map<PlatePartKind, PlateMotion> defaults', [
  'TODO(ts): [D9] the table is data: export it with the curves by name.',
  'TODO(kt): [D9] same.',
  'TODO(py): [D9] same.']),
 (A, 'class PlateAnimationController extends ChangeNotifier {', [
  'TODO(ts): [D7] a store of cues keyed by part id; parts subscribe to their own key only.',
  'TODO(kt): [D7] MutableStateFlow<PlatePartCue> per id in a map; fallback cue for ids not seen yet.',
  'TODO(py): [D7] Observable per id; QVariantAnimation per mounted part in the ui layer.']),
 (A, 'abstract final class PlateStagger {', [
  'TODO(ts): [H19][D9] plain function staggerSequence(spec, {stepMs, reverse}); vector the delays.',
  'TODO(kt): [H19] object PlateStagger.',
  'TODO(py): [H19] module function stagger_sequence.']),
 (A, 'class PlateSpecTransition {', [
  'TODO(ts): [H4] keep is a callback; specs never export it, the holder passes it in code.',
  'TODO(kt): [H4] keep: ((PlatePartId, PlateSpec, PlateSpec) -> Boolean?)?.',
  'TODO(py): [H4] keep: Callable | None.']),
 (A, 'static bool samePart(', [
  'TODO(ts): [H1][D9] shape identity becomes path-string equality once clippers are data; vector it.',
  'TODO(kt): [H1] compare path strings, not lambdas.',
  'TODO(py): [H1] compare path strings.']),
 (A, 'class PlateAnimationScope extends InheritedWidget {', [
  'TODO(ts): [H14] drop — pass the controller to render/painter.',
  'TODO(kt): [H14] CompositionLocal LocalPlateAnimation.',
  'TODO(py): [H14] drop — constructor argument.']),
 (P, 'class PlatePartFrame {', [
  'TODO(ts): [D1] {phase, progress: number, motion}; progress is a plain number per frame.',
  'TODO(kt): [D1] progress: Float read from an Animatable in Compose; model holds no Animation.',
  'TODO(py): [D1] progress float from QVariantAnimation.valueChanged.']),
 (P, 'Rect plateRevealRect(', [
  'TODO(ts): [D1][D9] pure render math; vector (bounds, origin, phase, t) -> rect.',
  'TODO(kt): [D1][D9] same, in render.',
  'TODO(py): [D1][D9] same.']),
 (P, 'class PlatePartAnimator extends StatefulWidget {', [
  'TODO(ts): [D1] no widget: render() reads each part frame and applies opacity/clip/translate/scale.',
  'TODO(kt): [D1] Modifier.graphicsLayer {alpha, translation, scale, clip} per part; one Animatable each.',
  'TODO(py): [D1] painter applies opacity/clip/transform per display-list group; one QVariantAnimation each.']),
 (P, 'void _apply(PlatePartCue cue) {', [
  'TODO(ts): [H11] delay is the head of the curve interval: t<start -> 0, then curve((t-start)/(1-start)).',
  'TODO(kt): [H11] same Interval math; don\'t use tween(delayMillis), it skips the instant cue.',
  'TODO(py): [H11] same Interval math over a linear QVariantAnimation.']),
 (P, 'class _Chain {', [
  'TODO(ts): [D1] fade=opacity, wipe/draw=clip+gate, fadeScale=scale 0.4→1, fadeSlide=translate 0.6 size.',
  'TODO(kt): [D1] same table in render.',
  'TODO(py): [D1] same table in render.']),
 (P, 'class _PartScope extends InheritedWidget {', [
  'TODO(ts): [H14] drop.',
  'TODO(kt): [H14] drop — pass the frame down.',
  'TODO(py): [H14] drop.']),
]
