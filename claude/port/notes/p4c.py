C = 'plate_core/lib/src/widgets/plate_canvas.dart'
NOTES = [
 (C, 'class PlateCanvas extends StatefulWidget', [
  'TODO(ts): [D1] ui root: <plate-canvas> custom element over core state; same props, callbacks as events.',
  'TODO(kt): [D1] @Composable PlateCanvas(spec, controller, …); state hoisted into PlateController.',
  'TODO(py): [D1] PlateCanvas(QWidget); a QGraphicsScene at spec canvas size, view fit-in-view.']),
 (C, 'void _startTransition(', [
  'TODO(ts): [D1][D9] which parts go out/in and their delays is pure: move to core, vector it.',
  'TODO(kt): same.',
  'TODO(py): same.']),
 (C, 'ThemeData _selectionThemeFor(', [
  'TODO(ts): drop — ::selection and caret-color CSS from activeColor.',
  'TODO(kt): drop — LocalTextSelectionColors.',
  'TODO(py): drop — QPalette.Highlight on the edits.']),
 (C, 'void _adoptControllerOnly(', [
  'TODO(ts): [D7] own-vs-host controller: dispose only what we created.',
  'TODO(kt): drop — remember { } a default controller.',
  'TODO(py): [D7] same as ts.']),
 (C, 'void _publishVerdict(', [
  'TODO(ts): [H14] drop — post-frame defer; emit after render via queueMicrotask.',
  'TODO(kt): [H14] drop — LaunchedEffect(verdict).',
  'TODO(py): [H14] drop — emit directly; Qt has no build phase.']),
 (C, 'class _Face extends StatelessWidget', [
  'TODO(ts): [H14] drop — the two-layer split exists for Flutter raster caching; one SVG/DOM tree.',
  'TODO(kt): [H14] drop — one Box.',
  'TODO(py): [H14] drop — one scene.']),
 (C, 'class _PlateSizeDelegate extends', [
  'TODO(ts): contain-fit of the tweened plate size; CSS aspect-ratio + transition on the box.',
  'TODO(kt): Modifier.aspectRatio with animateSizeAsState.',
  'TODO(py): fitInView on resize; animate the scene rect.']),
 (C, 'class _PlateSizeScope extends', [
  'TODO(ts): [H14] drop — InheritedWidget; pass the size down.',
  'TODO(kt): [H14] drop.',
  'TODO(py): [H14] drop.']),
 (C, 'class _PlateContent extends', [
  'TODO(ts): [D1] paint order panel, bands, rules, labels, decals; boxes in spec coords, one transform.',
  'TODO(kt): [D1] same order; Modifier.offset/size in spec units under one graphicsLayer scale.',
  'TODO(py): [D1] same order as scene items with z values.']),
 (C, 'class _LiveryState extends', [
  'TODO(ts): [H4][H15] resolveTheme runs in core on each change; ui tweens 350ms between results.',
  'TODO(kt): [H4][H15] same; animateColorAsState per field.',
  'TODO(py): [H4][H15] same; QVariantAnimation over a theme lerp.']),
 (C, 'class _ThemeTween extends', [
  'TODO(ts): [H15] lerpTheme(a, b, t) in core over the six colours; vector it.',
  'TODO(kt): [H15] same with lerp(Color).',
  'TODO(py): [H15] same.']),
 (C, 'class _StaggeredText extends', [
  'TODO(ts): [H24] per-char alpha indexes UTF-16 units like Dart; keep 220ms/55ms.',
  'TODO(kt): [H24] same units; keep timings.',
  'TODO(py): [H24] str indexes code points: index by UTF-16 to match, or accept the difference.']),
 (C, 'class _PlateInputs extends', [
  'TODO(ts): [D8] mirror editability and picker choice are pure: compute per slot in core.',
  'TODO(kt): same.',
  'TODO(py): same.']),
 (C, 'class _ValidationBinding extends', [
  'TODO(ts): [D7] subscribe to the verdict, not values; recolour on flips only.',
  'TODO(kt): [D7] derivedStateOf { validate(values) }.',
  'TODO(py): [D7] verdict observable with change-only signal.']),
 (C, 'class _RestrictionBanner extends', [
  'TODO(ts): [H12] banner geometry 0.42/0.1/0.26 of canvas height; scale-down fit by measureText.',
  'TODO(kt): same ratios.',
  'TODO(py): same ratios.']),
 (C, 'class _SlotBinding extends', [
  'TODO(ts): [D7] per-slot subscription keeps keystrokes local; same in each port.',
  'TODO(kt): [D7] collect slot(i) flow only.',
  'TODO(py): [D7] connect to slot(i) signal only.']),
 (C, 'class _Ghost {', [
  'TODO(ts): [D1] ghost = a second display canvas over the new one until the out stagger ends.',
  'TODO(kt): same; key the ghost by serial.',
  'TODO(py): same; a second scene layer.']),
 (C, 'class _SpecGhostState extends', [
  'TODO(ts): drop — Timer; setTimeout cleared on unmount.',
  'TODO(kt): drop — LaunchedEffect + delay.',
  'TODO(py): drop — QTimer.singleShot.']),
]
