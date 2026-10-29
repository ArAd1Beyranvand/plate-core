W = 'plate_core/lib/src/widgets/'
V, T, S, F = W + 'plate_view.dart', W + 'plate_text_row.dart', W + 'plate_selector.dart', W + 'plate_flag.dart'
DV, DI, CP = W + 'plate_drawing_view.dart', W + 'plate_divider.dart', W + 'country_panel.dart'
G, SI, FR = W + 'plate_glyph_run.dart', W + 'plate_slot_item.dart', W + 'plate_frame.dart'
NOTES = [
 (V, 'class PlateView extends', [
  'TODO(ts): [D1] ui layer: <plate-view> renders spec+values read-only; no controller needed.',
  'TODO(kt): [D1] @Composable PlateView(spec, values).',
  'TODO(py): [D1] PlateView(QWidget) over the same canvas, editing off.']),
 (V, 'class PlateTextView extends', [
  'TODO(ts): [D1] a text formatter in the model layer, not a widget; vector the output.',
  'TODO(kt): same.',
  'TODO(py): same.']),
 (T, 'noCharacterChooser(', [
  'TODO(ts): drop — default arg; a missing chooser means no sheet.',
  'TODO(kt): drop — nullable lambda.',
  'TODO(py): drop — None.']),
 (T, 'class PlateTextRow extends', [
  'TODO(ts): [D1] ui only; spaceEvenly row of slot elements.',
  'TODO(kt): [D1] Row(Arrangement.SpaceEvenly).',
  'TODO(py): [D1] QHBoxLayout with stretch between items.']),
 (S, 'class PlateSelector<T> extends', [
  'TODO(ts): [D1] ui only: a <select>-like chooser; generic over the option value.',
  'TODO(kt): [D1] ExposedDropdownMenuBox.',
  'TODO(py): [D1] QComboBox with userData.']),
 (F, 'class PlateFlag extends', [
  'TODO(ts): [D6] SVG <img>/inline svg with preserveAspectRatio="none" (BoxFit.fill); drawings via canvas.',
  'TODO(kt): [D6] Image(ContentScale.FillBounds); drawings via Canvas.',
  'TODO(py): [D6] QSvgRenderer into the rect, aspect ignored.']),
 (DV, 'class PlateDrawingView extends', [
  'TODO(ts): [D6][H13] paint PlateDrawing to canvas/SVG; fill vs contain is the only fit.',
  'TODO(kt): [D6][H13] DrawScope painter; Path.op for differences.',
  'TODO(py): [D6][H13] QPainter; QPainterPath.subtracted for differences.']),
 (DI, 'class PlateDividerPainter extends', [
  'TODO(ts): [D1] reveal math (span along the long axis) is pure: put it beside plateRevealRect, vector it.',
  'TODO(kt): same; painter stays in ui.',
  'TODO(py): same.']),
 (CP, 'class CountryPanel extends', [
  'TODO(ts): [D1] layout of flag/code/wording is fixed-canvas: compute rects in core, draw in ui.',
  'TODO(kt): [D1] same; Compose Box with absolute offsets.',
  'TODO(py): [D1] same; QPainter, no layouts.']),
 (CP, 'Size _flagSize(', [
  'TODO(ts): [D1] pure geometry; move to core with a vector.',
  'TODO(kt): same.',
  'TODO(py): same.']),
 (CP, 'class _PanelWording extends', [
  'TODO(ts): [H12] scale-down fit needs measureText; [D6] font must be the bundled one.',
  'TODO(kt): [H12] TextMeasurer; autosize by binary search.',
  'TODO(py): [H12] QFontMetricsF; shrink the font to fit.']),
 (G, 'class PlateGlyphRun extends', [
  'TODO(ts): [H7] diff old/new runs by code point; each glyph is a span animated with WAAPI.',
  'TODO(kt): [H7] AnimatedContent per glyph keyed by index.',
  'TODO(py): [H7] one QPropertyAnimation per glyph item.']),
 (G, 'StrutStyle _strutOf(', [
  'TODO(ts): [H12] line-height 1 and fixed baseline; strut has no CSS twin, set line-height explicitly.',
  'TODO(kt): [H12] LineHeightStyle(trim = Both) and lineHeight = fontSize.',
  'TODO(py): [H12] place by QFontMetrics.ascent; no strut.']),
 (SI, 'class PlateSlotItem extends', [
  'TODO(ts): [D8] the typed/chosen/glyph pick is pure: move it to the input machine and vector it.',
  'TODO(kt): [D8] same.',
  'TODO(py): [D8] same.']),
 (SI, 'class _TypedField extends', [
  'TODO(ts): [D8] <input> with transparent text and the glyph run overlaid; keypad mode = inputmode=none.',
  'TODO(kt): [D8] BasicTextField with transparent text and an overlay; keypad mode = no IME session.',
  'TODO(py): [D8] QLineEdit with transparent text; keypad mode = no focus on the edit.']),
 (SI, 'TextStyle _fittedStyle(', [
  'TODO(ts): [H12] measure widest run with measureText; same 4px caret room.',
  'TODO(kt): [H12] TextMeasurer; same formula.',
  'TODO(py): [H12] QFontMetricsF.horizontalAdvance; same formula.']),
 (SI, 'class _HoldsPageStill extends', [
  'TODO(ts): [H14] drop — preventScroll: true on focus().',
  'TODO(kt): [H14] drop — no BringIntoViewRequester.',
  'TODO(py): [H14] drop — Qt does not scroll on focus.']),
 (FR, 'class PlateFrame extends', [
  'TODO(ts): [D1] paint order face, regions, dividers, border on one canvas; parts are layers.',
  'TODO(kt): [D1] one Canvas, same order.',
  'TODO(py): [D1] one QPainter pass, same order.']),
 (FR, 'class _RimFrames {', [
  'TODO(ts): [H14] drop — the scope chain; read the three rim cues from the store directly.',
  'TODO(kt): [H14] drop — CompositionLocal not needed; collect three flows.',
  'TODO(py): [H14] drop — read the observables.']),
 (FR, 'class _Geometry {', [
  'TODO(ts): [D1] pure: border, radii, face rrect from theme+size+rim; move to core and vector it.',
  'TODO(kt): same.',
  'TODO(py): same.']),
 (FR, 'class _BorderPainter extends', [
  'TODO(ts): [H13] draw effect needs path length: build the centreline path, getPointAtLength/dash.',
  'TODO(kt): [H13] PathMeasure.getSegment.',
  'TODO(py): [H13] QPainterPath.percentAtLength + a dash pattern.']),
]
