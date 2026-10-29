M = 'plate_core/lib/src/model/'
NOTES = [
 (M+'plate_alphabet.dart', 'class PlateAlphabet {', [
  'TODO(ts): [H3] equality by id only; key Maps/Sets by alphabet.id, never compare structurally.',
  'TODO(kt): [H3] plain class with equals/hashCode on id, not a data class.',
  'TODO(py): [H3] @dataclass(frozen=True, eq=False) with __eq__/__hash__ on id.']),
 (M+'plate_alphabet.dart', 'static final Map<String, List<String>> _expanded', [
  'TODO(ts): [H5] per-instance lazy getter, not a module-level cache keyed by pattern.',
  'TODO(kt): [H5] `val characters by lazy`; no companion cache.',
  'TODO(py): [H5] functools.cached_property (needs __dict__) or set in __post_init__.']),
 (M+'plate_alphabet.dart', 'static Iterable<String> _tokens(', [
  'TODO(ts): [H22] range tokens are code points: Array.from(token), String.fromCodePoint.',
  'TODO(kt): [H22] split by codePoints, not chars; encode back to UTF-16 by hand in commonMain.',
  'TODO(py): [H22] list(token) is code points already; chr() for the range.']),
 (M+'plate_alphabet.dart', 'String canonical(String value) {', [
  'TODO(ts): [H21][H8] glyphs must be a Map (first-key-wins); toUpperCase is locale-free, keep it so.',
  'TODO(kt): [H21][H8] uppercase() not uppercase(Locale); LinkedHashMap order for the reverse lookup.',
  'TODO(py): [H8] str.upper() turns ß into SS; Dart keeps it two chars too, vectors pin it.']),
 (M+'plate_alphabet.dart', 'List<String> splitRunes(String value)', [
  'TODO(ts): [H7] Array.from(value): code points, not UTF-16 units and not graphemes.',
  'TODO(kt): [H7] iterate codePoints(); a String.toList() of Chars splits surrogate pairs.',
  'TODO(py): [H7] list(value).']),
 (M+'plate_alphabet.dart', 'final TextDirection direction;', [
  'TODO(ts): [H10] "ltr" | "rtl" string union.',
  'TODO(kt): [H10] own enum in commonMain; map to LayoutDirection in Compose.',
  'TODO(py): [H10] own Enum; Qt.LayoutDirection only in the ui layer.']),
 (M+'plate_asset.dart', 'sealed class PlateGraphic {', [
  'TODO(ts): [H18] union PlateDrawing | PlateAsset tagged by kind: "drawing" | "svg" | "raster".',
  'TODO(kt): [H18] sealed interface; same kind tags in the JSON export.',
  'TODO(py): [H18] Union type + match on class; kind tag only in the JSON.']),
 (M+'plate_asset.dart', 'sealed class PlateAsset extends PlateGraphic {', [
  'TODO(ts): [H20][D5] resolve package+path to a URL through the countries package subpath exports.',
  'TODO(kt): [H20][D5] Compose resources per countries module; SVG flags become drawings (D6).',
  'TODO(py): [H20][D5] importlib.resources.files(f"plates.countries.{package}") / path.']),
 (M+'plate_box.dart', 'Rect get rect', [
  'TODO(ts): [H10] model Rect is a plain {left, top, right, bottom} type defined once.',
  'TODO(kt): [H10] own Rect in commonMain; convert to Compose Rect in ui only.',
  'TODO(py): [H10] own NamedTuple Rect; QRectF only in the ui layer.']),
 (M+'plate_country.dart', 'class PlateCountry {', [
  'TODO(ts): [H3] equality by code only.',
  'TODO(kt): [H3] equals/hashCode on code; not a data class.',
  'TODO(py): [H3] eq=False dataclass, __eq__/__hash__ on code.']),
 (M+'plate_country.dart', 'final Color panelColor;', [
  'TODO(ts): [H10] colours stay 0xAARRGGBB numbers in model; convert to rgba() in the painter.',
  'TODO(kt): [H10] ARGB Long in model; Color(argb) in Compose.',
  'TODO(py): [H10] ARGB int; QColor.fromRgba in ui.']),
 (M+'plate_input_source.dart', 'enum PlateInputSource {', [
  'TODO(ts): [D8] inputmode="none"+virtualkeyboardpolicy="manual" for every source but system.',
  'TODO(kt): [D8] KeyboardOptions + LocalSoftwareKeyboardController.hide() for non-system sources.',
  'TODO(py): [D8] hardware keys only; system and keypadFirst collapse to hardwareKeyboard on desktop.']),
 (M+'plate_input_source.dart', 'PlateInputSource defaultInputSource()', [
  'TODO(ts): [H16] desktop when !matchMedia("(pointer: coarse)").matches, not by user agent.',
  'TODO(kt): [H16] expect/actual: desktop -> hardwareKeyboard, android -> system.',
  'TODO(py): [H16] always hardwareKeyboard (PySide6 desktop).']),
 (M+'plate_layout.dart', 'List<PlateSlot> plateRegister({', [
  'TODO(ts): [H6] codegen emits the expanded slots; port these builders only for hand-written specs.',
  'TODO(kt): [H6] same; builders return List (read-only), not MutableList.',
  'TODO(py): [H6] same; return tuples.']),
 (M+'plate_restriction.dart', 'class PlateRestrictionException', [
  'TODO(ts): extends Error with name "PlateRestrictionError"; message is the reason.',
  'TODO(kt): class PlateRestrictionException(val restriction) : Exception(restriction.reason).',
  'TODO(py): class PlateRestrictionError(ValueError); str() is the reason.']),
 (M+'plate_shape.dart', 'sealed class PlateShape {', [
  'TODO(ts): [H18][D1] union by kind; toPath moves to render and emits an SVG path string.',
  'TODO(kt): [H18][D1] sealed interface in model; path building lives in render, not on the shape.',
  'TODO(py): [H18][D1] dataclasses + match in render; no Qt types in model.']),
 (M+'plate_shape.dart', 'class PlateRingShape extends PlateShape {', [
  'TODO(ts): [H13] two circles in one path with fill-rule="evenodd" equals the difference here.',
  'TODO(kt): [H13] Path.combine(PathOperation.Difference) or PathFillType.EvenOdd.',
  'TODO(py): [H13] QPainterPath.subtracted, or OddEvenFill with both ellipses.']),
 (M+'plate_shape.dart', 'class PlateCrescentShape extends PlateShape {', [
  'TODO(ts): [H13] evenodd is wrong when the bite pokes outside the disc: clip-path or real difference.',
  'TODO(kt): [H13] PathOperation.Difference (evenodd would paint the bite outside the disc).',
  'TODO(py): [H13] QPainterPath.subtracted.']),
 (M+'plate_shape.dart', 'final List<Offset> points;', [
  'TODO(ts): [H10] points as [x, y] pairs; flatten in the JSON export.',
  'TODO(kt): [H10] own Point(x, y) in commonMain, not Compose Offset.',
  'TODO(py): [H10] tuple[float, float].']),
 (M+'plate_spec.dart', 'bool accepts(String value) {', [
  'TODO(ts): [H7] split with Array.from; a chosen symbol is judged whole.',
  'TODO(kt): [H7] code points, not Chars.',
  'TODO(py): [H7] list(value).']),
 (M+'plate_spec.dart', 'bool isFull(String? value)', [
  'TODO(ts): [H24] runes.length is Array.from(v).length, not v.length.',
  'TODO(kt): [H24] codePointCount, not length.',
  'TODO(py): [H24] len(v) is already code points.']),
 (M+'plate_spec.dart', 'class PlateFill {', [
  'TODO(ts): [H18] union: {kind:"color"}, {kind:"stripes"}, and three role singletons field/panel/divider.',
  'TODO(kt): [H18] sealed interface: ColorFill, StripesFill, object Field/Panel/Divider.',
  'TODO(py): [H18] ColorFill/StripesFill dataclasses + a Role enum for the three singletons.']),
 (M+'plate_spec.dart', 'class PlateFog {', [
  'TODO(ts): [H10] center/radii as plain {x,y}/{width,height}.',
  'TODO(kt): [H10] own Point/Size in commonMain.',
  'TODO(py): [H10] tuples.']),
 (M+'plate_spec.dart', 'class PlateSection {', [
  'TODO(ts): [H18] union leaf {fill, shape?} | split {axis, parts}; layout() moves to render ([D1]).',
  'TODO(kt): [H18] sealed interface Leaf/Split; layout is pure and stays in model.',
  'TODO(py): [H18] Leaf/Split dataclasses; layout returns a NamedTuple ([H17]).']),
 (M+'plate_spec.dart', 'final CustomClipper<Path>? shape;', [
  'TODO(ts): [H1][D3] an SVG path string in leaf-local units, exported from the clipper at leaf size.',
  'TODO(kt): [H1][D3] path data string parsed with PathParser; not a lambda.',
  'TODO(py): [H1][D3] path data string; QPainterPath built in render.']),
 (M+'plate_spec.dart', ') layout(', [
  'TODO(ts): [H17] return {leaves: [section, rect][], dividers: Rect[]}; it is a D9 vector.',
  'TODO(kt): [H17] data class SectionLayout(leaves: List<Pair<PlateSection, Rect>>, dividers).',
  'TODO(py): [H17] NamedTuple(leaves, dividers).']),
 (M+'plate_spec.dart', 'class PlateDecal {', [
  'TODO(ts): [H2][D3] image is an asset reference {package, path}, not an ImageProvider.',
  'TODO(kt): [H2][D3] asset reference; painter loads it with Compose resources.',
  'TODO(py): [H2][D3] asset reference; QImage from importlib.resources in ui.']),
 (M+'plate_spec.dart', 'typedef PlateLabelResolver =', [
  'TODO(ts): [H4][D4-table] most resolvers are key -> caption tables: export them as data, hand-port the rest.',
  'TODO(kt): [H4][D4-table] (group: (String) -> String) -> String?; table resolvers become maps.',
  'TODO(py): [H4][D4-table] Callable[[Callable[[str], str]], str | None]; tables become dicts.']),
 (M+'plate_spec.dart', 'typedef PlateThemeResolver =', [
  'TODO(ts): [H4][D4-table] letter -> theme tables become data; only real logic stays a function.',
  'TODO(kt): [H4][D4-table] same; the export records which resolvers are tables.',
  'TODO(py): [H4][D4-table] same.']),
 (M+'plate_spec.dart', 'final String? fontFamily;', [
  'TODO(ts): [D6-font] @font-face per family from the countries package; fontPackage picks the subpath.',
  'TODO(kt): [D6-font] FontFamily(Font(Res.font.x)) from the countries module.',
  'TODO(py): [D6-font] QFontDatabase.addApplicationFont from importlib.resources at import time.']),
 (M+'plate_spec.dart', 'final EdgeInsets? padding;', [
  'TODO(ts): [H10] {left, top, right, bottom}; null means 10% of the panel height on every side.',
  'TODO(kt): [H10] own Insets in commonMain, not PaddingValues.',
  'TODO(py): [H10] NamedTuple Insets.']),
 (M+'plate_spec.dart', 'final CustomClipper<Path>? shape;\n', []),
 (M+'plate_spec.dart', 'class PlateSpec {', [
  'TODO(ts): [H3] equality by id only (no identical() short-cut needed); Maps keyed by spec.id.',
  'TODO(kt): [H3] equals/hashCode on id; not a data class.',
  'TODO(py): [H3] eq=False dataclass, __eq__/__hash__ on id.']),
 (M+'plate_spec.dart', 'final bool noPanel;', [
  'TODO(ts): make panel optional (panel?: PlatePanel) instead of porting noPanel.',
  'TODO(kt): panel: PlatePanel? instead of noPanel.',
  'TODO(py): panel: PlatePanel | None instead of no_panel.']),
 (M+'slot_behavior.dart', 'SlotBehavior resolveSlotBehavior({', [
  'TODO(ts): [D9] pure; every (mode, input, source) triple is a vector.',
  'TODO(kt): [D9] pure; same vectors.',
  'TODO(py): [D9][D8] pure; keypadFirst/imeField fall back to hardwareField in PySide6.']),
 ('plate_core/lib/src/theme/plate_theme.dart', 'class PlateTheme {', [
  'TODO(ts): [H15] structural equality and a lerp(a, b, t) over every field for the cross-fade.',
  'TODO(kt): [H15] a data class is right here (equality is structural); add lerp.',
  'TODO(py): [H15] frozen dataclass (structural eq is right) + lerp; replace() is copyWith.']),
 ('plate_core/lib/src/theme/plate_theme.dart', 'TextStyle glyphStyle(', [
  'TODO(ts): [H12][D6-font] font-size slotHeight*0.72, line-height 1, weight 700, explicit family.',
  'TODO(kt): [H12][D6-font] fontSize in px→sp via LocalDensity, lineHeight = 1.em, Bold.',
  'TODO(py): [H12][D6-font] QFont pixel size h*0.72, bold; QFontMetricsF for the box, not point size.']),
 ('plate_core/lib/src/theme/plate_theme.dart', 'static PlateTheme of(BuildContext context)', [
  'TODO(ts): [H14] drop — the theme is an explicit argument to render().',
  'TODO(kt): [H14] CompositionLocal LocalPlateTheme, default standard().',
  'TODO(py): [H14] drop — pass the theme to the widget.']),
 ('plate_core/lib/src/theme/plate_theme.dart', 'class PlateThemeScope extends InheritedWidget {', [
  'TODO(ts): [H14] drop — no scope; see PlateTheme.of.',
  'TODO(kt): [H14] CompositionLocalProvider(LocalPlateTheme provides theme).',
  'TODO(py): [H14] drop.']),
 ('plate_core/lib/src/validators/debug_validate_spec.dart', 'List<String> specProblems(PlateSpec spec) {', [
  'TODO(ts): [H23][D9] port this, not the assert wrapper; message texts are part of the vectors.',
  'TODO(kt): [H23][D9] same; return List<String>.',
  'TODO(py): [H23][D9] same; return list[str].']),
 ('plate_core/lib/src/validators/debug_validate_spec.dart', 'bool debugValidateSpec(PlateSpec spec) {', [
  'TODO(ts): [H23] drop — call specProblems in tests and behind a debug flag.',
  'TODO(kt): [H23] drop — check(specProblems(spec).isEmpty()) in tests.',
  'TODO(py): [H23] drop — asserts vanish under -O.']),
 ('plate_core/lib/src/validators/plate_validator.dart', 'bool isDigits(String value)', [
  'TODO(ts): [H9] ASCII 0-9 only: /^[0-9]+$/, never \\d with the u flag on other scripts.',
  'TODO(kt): [H9] all { it in \'0\'..\'9\' }; Char.isDigit() accepts every Unicode Nd.',
  'TODO(py): [H9] str.isdigit() accepts ۵ and ²: use re.fullmatch(r"[0-9]+", v) or an ASCII check.']),
 ('plate_core/lib/src/validators/plate_validator.dart', 'bool isDigitsOfLength(', [
  'TODO(ts): [H24] length is code units; safe only because isDigits passes ASCII alone.',
  'TODO(kt): [H24] same.',
  'TODO(py): [H24] same, len() agrees for ASCII.']),
 ('plate_core/lib/src/validators/plate_validator.dart', 'abstract class PlateValidator {', [
  'TODO(ts): [D4-code] interface {validate(entry): PlateValidation}; country validators hand-ported.',
  'TODO(kt): [D4-code] fun interface PlateValidator.',
  'TODO(py): [D4-code] Protocol with validate(); validation is a frozen dataclass (reason: str | None).']),
 ('plate_core/lib/src/drawings/european_stars.dart', 'abstract final class EuropeanStars {', [
  'TODO(ts): [H19] export const EuropeanStars = {band, flag} as const.',
  'TODO(kt): [H19] object EuropeanStars.',
  'TODO(py): [H19] module-level BAND, FLAG.']),
]
NOTES = [n for n in NOTES if n[2]]
import os
_only = os.environ.get('ONLY')
if _only: NOTES = [n for n in NOTES if any(o in n[0] for o in _only.split(','))]
