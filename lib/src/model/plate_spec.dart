import 'package:flutter/widgets.dart';

import 'plate_alphabet.dart';
import 'plate_asset.dart';
import 'plate_box.dart';
import 'plate_country.dart';
import '../theme/plate_theme.dart';
import 'plate_restriction.dart';

/// One editable position on a plate. [box].height doubles as the glyph height.
@immutable
class PlateSlot {
  const PlateSlot({
    required this.alphabet,
    required this.box,
    this.color,
    this.length = 1,
    int? minLength,
    this.spacing = 0,
  }) : minLength = minLength ?? length,
       assert(length >= 1, 'A slot holds at least one character.'),
       assert(
         minLength == null || (minLength >= 1 && minLength <= length),
         'minLength is 1..length.',
       );

  final PlateAlphabet alphabet;
  final PlateBox box;

  /// The most characters the slot holds. A run printed and edited as a unit
  /// ("two digits") is one slot of [length] 2: one box, one focus stop. A
  /// register whose cells are drawn apart stays [plateRegister]. A chosen
  /// alphabet is picked a symbol at a time, so its slot stays at 1.
  final int length;

  /// The fewest characters that complete the field; [length] unless the field
  /// is variable, like a serial of four to six digits. Focus still advances
  /// only at [length].
  final int minLength;

  /// Extra space after each character of a run, in plate units, matching the
  /// printed pitch rather than the font's advance. Meaningless at [length] 1.
  final double spacing;

  /// Ink for this slot, or null for the theme's. Only for a slot on a coloured
  /// region where the theme's ink would be illegible; same case as
  /// [PlateLabel.color].
  final Color? color;

  // TODO(ts): [H7] split with Array.from; a chosen symbol is judged whole.
  // TODO(kt): [H7] code points, not Chars.
  // TODO(py): [H7] list(value).
  /// Whether [value] is a legal, possibly partial, content: at most [length]
  /// characters, each in [alphabet] in either form.
  bool accepts(String value) {
    // A chosen symbol may span several characters ('CD'); it is judged whole.
    if (alphabet.input == .chosen) return alphabet.accepts(value);
    final characters = splitRunes(value);
    return characters.isNotEmpty &&
        characters.length <= length &&
        characters.every(alphabet.accepts);
  }

  String canonical(String value) => alphabet.canonicalAll(value);

  String render(String value) => alphabet.renderAll(value);

  // TODO(ts): [H24] runes.length is Array.from(v).length, not v.length.
  // TODO(kt): [H24] codePointCount, not length.
  // TODO(py): [H24] len(v) is already code points.
  /// Nothing more can be typed.
  bool isFull(String? value) => value != null && value.runes.length >= length;

  bool isComplete(String? value) =>
      value != null && value.runes.length >= minLength;
}

/// An echo of a slot's value painted elsewhere on the plate, such as the same
/// number printed once per script.
///
/// A mirror shares the [source] slot's value and owns no position in
/// [PlateSpec.slots], so it never counts towards [PlateSpec.slotCount], text
/// groups, completion or validation. When [editable] it gets its own focus node
/// and text controller but reads and writes the source's position.
///
/// [alphabet] is the transform: point it at an alphabet with different
/// [PlateAlphabet.glyphs] to echo in another numeral system. Null uses the
/// source slot's own.
@immutable
class PlateMirror {
  const PlateMirror({
    required this.source,
    required this.box,
    required this.glyphHeight,
    this.alphabet,
    this.editable = false,
  });

  /// Index into [PlateSpec.slots].
  final int source;

  final PlateBox box;
  final double glyphHeight;
  final PlateAlphabet? alphabet;
  final bool editable;
}

/// A painted mark such as a short divider between character groups.
@immutable
class PlateRule {
  const PlateRule({required this.box});

  final PlateBox box;
}

// TODO(ts): [H18] union: {kind:"color"}, {kind:"stripes"}, and three role singletons field/panel/divider.
// TODO(kt): [H18] sealed interface: ColorFill, StripesFill, object Field/Panel/Divider.
// TODO(py): [H18] ColorFill/StripesFill dataclasses + a Role enum for the three singletons.
/// What a [PlateSection] leaf is painted in.
///
/// [field], [panel] and [divider] resolve at render time to the theme's
/// `plateBackground`, the rendered country's `panelColor` and the theme's
/// `dividerColor`, so one spec follows a host's livery and a varying country.
@immutable
class PlateFill {
  /// A colour of the design's own.
  const PlateFill.color(Color this.color)
    : _role = null,
      stripes = null,
      stops = const <double>[],
      angle = 0,
      fog = null;
  const PlateFill._(this._role)
    : color = null,
      stripes = null,
      stops = const <double>[],
      angle = 0,
      fog = null;

  /// Parallel bands across the leaf, tilted by [angle]: a flag printed under
  /// the characters.
  ///
  /// [stops] are the y, in plate coordinates, at which each boundary between
  /// consecutive [stripes] crosses the leaf's vertical centreline. There is one
  /// fewer stop than stripes; the first stripe runs to the leaf's top and the
  /// last to its bottom. [angle] is in radians, positive rising to the right,
  /// turning every boundary about the leaf's centre.
  ///
  /// Stripes are fills themselves (so the top one can be [field]) but may not
  /// nest. [fog] washes the field colour over the middle of them.
  const PlateFill.stripes(
    List<PlateFill> this.stripes, {
    required this.stops,
    this.angle = 0,
    this.fog,
  }) : color = null,
       _role = null;

  static const PlateFill field = PlateFill._(_FillRole.field);
  static const PlateFill panel = PlateFill._(_FillRole.panel);

  /// The divider colour, for a strip that runs out to the plate's edge.
  static const PlateFill divider = PlateFill._(_FillRole.divider);

  final Color? color;
  final _FillRole? _role;
  final List<PlateFill>? stripes;
  final List<double> stops;
  final double angle;
  final PlateFog? fog;

  bool get isField => _role == _FillRole.field;
  bool get isPanel => _role == _FillRole.panel;
  bool get isStripes => stripes != null;

  bool get paintsPanel => isPanel || (stripes?.any((s) => s.isPanel) ?? false);

  /// The paint colour; not meaningful for [isStripes], paint each stripe.
  Color resolve({
    required Color field,
    required Color panel,
    required Color divider,
  }) => switch (_role) {
    _FillRole.field => field,
    _FillRole.panel => panel,
    _FillRole.divider => divider,
    null => color!,
  };
}

enum _FillRole { field, panel, divider }

// TODO(ts): [H10] center/radii as plain {x,y}/{width,height}.
// TODO(kt): [H10] own Point/Size in commonMain.
// TODO(py): [H10] tuples.
/// The theme's field colour airbrushed over a [PlateFill.stripes] leaf: an
/// ellipse at [opacity] out to [plateau] of its radii, fading to nothing at its
/// edge. It pales the stripes behind the characters.
@immutable
class PlateFog {
  const PlateFog({
    required this.center,
    required this.radii,
    this.opacity = 1,
    this.plateau = 0.5,
  });

  /// In plate coordinates.
  final Offset center;

  /// Half-width and half-height of the ellipse.
  final Size radii;

  final double opacity;

  /// Fraction of [radii] over which the fog holds full [opacity].
  final double plateau;
}

// TODO(ts): [H18] union leaf {fill, shape?} | split {axis, parts}; layout() moves to render ([D1]).
// TODO(kt): [H18] sealed interface Leaf/Split; layout is pure and stays in model.
// TODO(py): [H18] Leaf/Split dataclasses; layout returns a NamedTuple ([H17]).
/// The plate face divided into regions: a guillotine tree of columns and rows
/// whose leaves are [PlateFill]s.
///
/// Painted in one pass under the border, so a coloured strip runs to the
/// plate's edge with the border over it and no box edge for the face to show
/// through. Positions are plate coordinates along the parent's axis, so the
/// layout does not move when a theme changes the border width.
@immutable
class PlateSection {
  /// A leaf. [shape] cuts it to something other than its rectangle: the
  /// clipper gets the leaf's size and returns the region to fill, and the field
  /// shows through the rest.
  const PlateSection.fill(PlateFill this.fill, {this.shape})
    : axis = null,
      parts = const <PlatePart>[];

  /// Side-by-side regions, split along x.
  const PlateSection.columns(this.parts)
    : axis = .horizontal,
      fill = null,
      shape = null;

  /// Stacked regions, split along y.
  const PlateSection.rows(this.parts)
    : axis = .vertical,
      fill = null,
      shape = null;

  /// The plain face: one region in the theme's field colour.
  static const PlateSection plain = PlateSection.fill(PlateFill.field);

  final PlateFill? fill;
  // TODO(ts): [H1][D3] an SVG path string in leaf-local units, exported from the clipper at leaf size.
  // TODO(kt): [H1][D3] path data string parsed with PathParser; not a lambda.
  // TODO(py): [H1][D3] path data string; QPainterPath built in render.
  final CustomClipper<Path>? shape;
  final Axis? axis;
  final List<PlatePart> parts;

  bool get isLeaf => axis == null;

  /// Whether any leaf is filled with the panel colour, in which case the
  /// background owns the panel block and [CountryPanel] lays out only the flag
  /// and caption on it.
  bool get paintsPanel =>
      isLeaf ? fill!.paintsPanel : parts.any((p) => p.section.paintsPanel);

  // TODO(ts): [H17] return {leaves: [section, rect][], dividers: Rect[]}; it is a D9 vector.
  // TODO(kt): [H17] data class SectionLayout(leaves: List<Pair<PlateSection, Rect>>, dividers).
  // TODO(py): [H17] NamedTuple(leaves, dividers).
  /// The leaves and dividers of this tree laid over [bounds], depth-first.
  /// Indices match [PlatePartId.region] and [PlatePartId.divider].
  ({List<(PlateSection, Rect)> leaves, List<Rect> dividers}) layout(
    Rect bounds,
  ) {
    final leaves = <(PlateSection, Rect)>[];
    final dividers = <Rect>[];
    void walk(PlateSection s, Rect r) {
      if (s.isLeaf) {
        leaves.add((s, r));
        return;
      }
      final across = s.axis == .horizontal;
      var start = across ? r.left : r.top;
      final last = s.parts.length - 1;
      for (var i = 0; i <= last; i++) {
        final part = s.parts[i];
        final end = i == last ? (across ? r.right : r.bottom) : part.end!;
        walk(
          part.section,
          across
              ? Rect.fromLTRB(start, r.top, end, r.bottom)
              : Rect.fromLTRB(r.left, start, r.right, end),
        );
        if (part.divider > 0 && i != last) {
          final half = part.divider / 2;
          dividers.add(
            across
                ? Rect.fromLTRB(end - half, r.top, end + half, r.bottom)
                : Rect.fromLTRB(r.left, end - half, r.right, end + half),
          );
        }
        start = end;
      }
    }

    walk(this, bounds);
    return (leaves: leaves, dividers: dividers);
  }
}

/// One region of a split [PlateSection].
@immutable
class PlatePart {
  /// [end] is the region's far edge in plate coordinates along the parent's
  /// axis; null on the last part, which runs to the parent's end.
  ///
  /// [divider] is the thickness of a rule centred on [end] across the parent's
  /// full extent, in the theme's divider colour. It lives here rather than in
  /// [PlateSpec.rules] because a boxed rule would show the field through its
  /// own edges.
  const PlatePart(this.section, {this.end, this.divider = 0});

  final PlateSection section;
  final double? end;
  final double divider;
}

/// A solid block of colour floating on the background, such as a capsule
/// behind a code. A region that divides the plate is a [PlateSection] instead.
///
/// Paints only the rectangle; characters over it are ordinary slots and
/// [PlateLabel]s inside [box]. Not a fat [PlateRule]: a rule takes the divider
/// colour and follows [PlateSpec.inkOverride], whereas a band is the field the
/// ink is printed on and carries its own [color].
@immutable
class PlateBand {
  const PlateBand({
    required this.box,
    required this.color,
    this.topCornerRadius = 0,
    this.bottomCornerRadius = 0,
  });

  final PlateBox box;
  final Color color;

  /// Radius of the top corners; the bottom stay square on the plate's edge.
  final double topCornerRadius;

  /// Radius of the bottom corners; set with [topCornerRadius] for a capsule.
  final double bottomCornerRadius;
}

// TODO(ts): [H2][D3] image is an asset reference {package, path}, not an ImageProvider.
// TODO(kt): [H2][D3] asset reference; painter loads it with Compose resources.
// TODO(py): [H2][D3] asset reference; QImage from importlib.resources in ui.
/// A fixed image on the plate face, such as a sticker or badge: a raster
/// [image], or a [drawing] of const shapes that needs no file.
@immutable
class PlateDecal {
  const PlateDecal({this.image, this.drawing, required this.box})
    : assert(
        (image == null) != (drawing == null),
        'A decal is an image or a drawing, not both and not neither.',
      );

  final ImageProvider? image;

  final PlateDrawing? drawing;

  final PlateBox box;
}

// TODO(ts): [H4][D4-table] most resolvers are key -> caption tables: export them as data, hand-port the rest.
// TODO(kt): [H4][D4-table] (group: (String) -> String) -> String?; table resolvers become maps.
// TODO(py): [H4][D4-table] Callable[[Callable[[str], str]], str | None]; tables become dicts.
/// Picks a [PlateLabel]'s wording from what is typed. [group] reads a
/// [PlateTextGroup] by key, as [PlateSpec.valueOfGroup] does. Null keeps
/// [PlateLabel.text].
typedef PlateLabelResolver =
    String? Function(String Function(String key) group);

// TODO(ts): [H4][D4-table] letter -> theme tables become data; only real logic stays a function.
// TODO(kt): [H4][D4-table] same; the export records which resolvers are tables.
// TODO(py): [H4][D4-table] same.
/// Picks a plate's colours from what is typed, so one spec can be several
/// liveries. [base] is the host's theme (return it to leave it alone); [group]
/// reads a [PlateTextGroup] by key. Changes cross-fade.
typedef PlateThemeResolver =
    PlateTheme Function(PlateTheme base, String Function(String key) group);

/// Fixed text printed on the plate face.
@immutable
class PlateLabel {
  const PlateLabel({
    required this.text,
    required this.box,
    required this.glyphHeight,
    this.color,
    this.rotated = false,
    this.lineHeight,
    this.fontFamily,
    this.fontPackage,
    this.resolve,
  });

  final String text;
  final PlateBox box;
  final double glyphHeight;

  /// Replaces [text] with what the typed characters say. Static or top-level,
  /// to keep the label const. Changes cross-fade.
  final PlateLabelResolver? resolve;

  /// Ink for this label, or null for the theme's. Only for a label on a
  /// [PlateBand], where the theme's ink would be illegible.
  final Color? color;

  /// Turns the text 90° counter-clockwise to fill a narrow column with one
  /// horizontal word, rather than stacking its letters upright.
  final bool rotated;

  /// Overrides the glyph style's line height, to open up a stacked-letter
  /// label so it fills a tall box.
  final double? lineHeight;

  // TODO(ts): [D6-font] @font-face per family from the countries package; fontPackage picks the subpath.
  // TODO(kt): [D6-font] FontFamily(Font(Res.font.x)) from the countries module.
  // TODO(py): [D6-font] QFontDatabase.addApplicationFont from importlib.resources at import time.
  /// Face for this label, or null for the theme's.
  final String? fontFamily;

  /// Package that bundles [fontFamily].
  final String? fontPackage;
}

/// The country block: where it sits and how its flag and caption are laid out.
@immutable
class PlatePanel {
  const PlatePanel({
    required this.box,
    this.flagScale = 1.0,
    this.captionScale = 1.0,
    this.padding,
    this.direction = .vertical,
    this.shape,
  });

  final PlateBox box;

  final double flagScale;
  final double captionScale;

  // TODO(ts): [H10] {left, top, right, bottom}; null means 10% of the panel height on every side.
  // TODO(kt): [H10] own Insets in commonMain, not PaddingValues.
  // TODO(py): [H10] NamedTuple Insets.
  /// Null means a uniform inset of 10% of the panel's height.
  final EdgeInsets? padding;

  /// [Axis.vertical] puts the flag above the caption, horizontal beside it.
  final Axis direction;

  // TODO(ts): [H1][D3] SVG path string in panel-box units, exported from the clipper at box size.
  // TODO(kt): [H1][D3] path data string, not a lambda.
  // TODO(py): [H1][D3] path data string.
  /// Clips the panel to a non-rectangular block. Handed [box]'s size in plate
  /// coordinates, returns the shape to keep. Null adds no clip to the tree.
  final CustomClipper<Path>? shape;
}

/// One visual group in a plate's text rendering. [prefix] is prepended to the
/// rendered characters.
@immutable
class PlateTextGroup {
  const PlateTextGroup(this.indices, {this.prefix = '', this.key});
  final List<int> indices;
  final String prefix;

  /// Semantic name (e.g. 'letters', 'serial') that validators, restrictions and
  /// resolvers use to read the group by name rather than position.
  final String? key;
}

// TODO(ts): [H3] equality by id only (no identical() short-cut needed); Maps keyed by spec.id.
// TODO(kt): [H3] equals/hashCode on id; not a data class.
// TODO(py): [H3] eq=False dataclass, __eq__/__hash__ on id.
/// A complete plate design. Adding a plate means adding a const of this type,
/// never a widget.
@immutable
class PlateSpec {
  const PlateSpec({
    required this.id,
    required this.country,
    required this.canvasWidth,
    required this.canvasHeight,
    required this.panel,
    required this.slots,
    this.noPanel = false,
    this.background = PlateSection.plain,
    this.bands = const <PlateBand>[],
    this.rules = const <PlateRule>[],
    this.labels = const <PlateLabel>[],
    this.decals = const <PlateDecal>[],
    this.mirrors = const <PlateMirror>[],
    this.textDirection = .ltr,
    this.borderWidthRatioOverride,
    this.inkOverride,
    this.textGroups = const <PlateTextGroup>[],
    this.restrictions = const <PlateRestriction>[],
    this.resolveTheme,
    this.resolveRegion,
  });

  /// Stable identifier, e.g. 'xx.car'. The sole basis of [operator ==].
  final String id;

  final PlateCountry country;

  final double canvasWidth, canvasHeight;
  final PlatePanel panel;

  // TODO(ts): make panel optional (panel?: PlatePanel) instead of porting noPanel.
  // TODO(kt): panel: PlatePanel? instead of noPanel.
  // TODO(py): panel: PlatePanel | None instead of no_panel.
  /// Suppresses [panel] for a plate with no country block. A bool rather than a
  /// nullable [panel] because callers read `spec.panel.box` unconditionally.
  final bool noPanel;

  /// The face's regions and the dividers between them, painted under the
  /// border. A panel running edge to edge belongs here as a [PlateFill.panel]
  /// region.
  final PlateSection background;

  /// Blocks of colour floating on [background], under rules and labels.
  final List<PlateBand> bands;

  final List<PlateSlot> slots;

  /// Marks that do not divide the plate, like a short tick. An edge-to-edge
  /// line is a [PlatePart.divider].
  final List<PlateRule> rules;
  final List<PlateLabel> labels;
  final List<PlateDecal> decals;

  /// Echoes of slot values; they never count towards [slotCount].
  final List<PlateMirror> mirrors;

  final TextDirection textDirection;

  final double? borderWidthRatioOverride;

  /// The one ink this plate is printed in, for a design whose print colour is
  /// its own rather than the host's livery. Replaces the whole monochrome set
  /// (glyphs, border, rules, completed-field outline). Null for the theme's.
  final Color? inkOverride;

  /// Slot indices grouped for text rendering, in [textDirection] reading
  /// order. Empty means one group per slot.
  final List<PlateTextGroup> textGroups;

  /// Register values this plate refuses outright. Each must name a keyed group
  /// in [textGroups]; [debugValidateSpec] asserts it.
  final List<PlateRestriction> restrictions;

  /// Derives the theme from the typed characters, or null for the host's.
  /// Static or top-level, to keep the spec const.
  final PlateThemeResolver? resolveTheme;

  /// Where the typed characters say the plate was issued, for a plate with no
  /// room to print it; the host shows it via [PlateController.regionCaption].
  /// Null while it cannot be told. Static or top-level, to keep the spec const.
  final PlateLabelResolver? resolveRegion;

  int get slotCount => slots.length;

  /// The slot at [index], or null when [index] is outside the plate.
  PlateSlot? slotAt(int index) =>
      index >= 0 && index < slots.length ? slots[index] : null;

  /// [textGroups], or one group per slot when none are declared.
  List<PlateTextGroup> get effectiveTextGroups => textGroups.isNotEmpty
      ? textGroups
      : [
          for (var i = 0; i < slots.length; i++) PlateTextGroup([i]),
        ];

  PlateTextGroup? groupAt(int index) =>
      effectiveTextGroups.where((g) => g.indices.contains(index)).firstOrNull;

  PlateTextGroup? groupNamed(String key) =>
      effectiveTextGroups.where((g) => g.key == key).firstOrNull;

  /// [group]'s prefix followed by its slot values rendered through their
  /// alphabets. Unset slots render as ''.
  String renderGroup(PlateTextGroup group, List<String?> values) {
    final buffer = StringBuffer(group.prefix);
    for (final i in group.indices) {
      final value = i < values.length ? (values[i] ?? '') : '';
      buffer.write(slotAt(i)?.render(value) ?? '');
    }
    return buffer.toString();
  }

  /// The slot focus advances to from [index], or null at the end.
  int? nextIndex(int index) =>
      index >= 0 && index + 1 < slots.length ? index + 1 : null;

  /// The slot focus steps back to from [index], or null at the start.
  int? previousIndex(int index) =>
      index > 0 && index < slots.length ? index - 1 : null;

  /// The raw (unrendered) values of the group named [key], concatenated; ''
  /// for an unknown key or unset slots.
  String valueOfGroup(String key, List<String?> values) => [
    for (final i in groupNamed(key)?.indices ?? const <int>[])
      if (i < values.length) values[i] ?? '',
  ].join();

  /// The first of [restrictions] that [values] break, or null.
  PlateRestriction? restrictionViolatedBy(List<String?> values) {
    for (final r in restrictions) {
      if (r.matches(valueOfGroup(r.group, values))) return r;
    }
    return null;
  }

  /// Throws [PlateRestrictionException] when [values] break a restriction. For
  /// values that bypass a controller, such as a database row or a scan.
  void checkRestrictions(List<String?> values) {
    final r = restrictionViolatedBy(values);
    if (r != null) throw PlateRestrictionException(r);
  }

  /// Empty for an unknown key.
  List<int> indicesOfGroup(String key) =>
      groupNamed(key)?.indices ?? const <int>[];

  @override
  bool operator ==(Object other) => other is PlateSpec && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
