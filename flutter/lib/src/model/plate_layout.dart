/// Builders for the regular parts of a plate face: runs of equal cells at a
/// constant pitch. [PlateTextGroup] declares which slots form a register; these
/// say where the cells sit.
///
/// They return ordinary [PlateSlot], [PlateMirror] and [PlateRule] values, so
/// the widget layer cannot tell them from literals. Irregular elements stay
/// literals. The lists are not `const`, so a spec built from one is a
/// `static final`; [PlateSpec] equality is over `id` alone.
library;

import 'dart:math' as math;
import 'dart:ui' show Color;

import 'plate_alphabet.dart';
import 'plate_box.dart';
import 'plate_spec.dart';

/// [count] equal cells over [alphabet] from [left], each [width] by [height] at
/// [top], stepping by [pitch] (default [width]: flush cells). Pass [pitch] for a
/// gapped register. [color] is every cell's [PlateSlot.color].
List<PlateSlot> plateRegister({
  required PlateAlphabet alphabet,
  required int count,
  required double left,
  required double top,
  required double width,
  required double height,
  double? pitch,
  Color? color,
  String? group,
}) {
  _checkCount(count, 'plateRegister');
  final step = pitch ?? width;
  return List<PlateSlot>.unmodifiable(<PlateSlot>[
    for (var i = 0; i < count; i++)
      PlateSlot(
        alphabet: alphabet,
        box: PlateBox(left + i * step, top, width, height),
        color: color,
        group: group,
      ),
  ]);
}

/// [count] flush cells filling `[left, right)` exactly: [plateRegister] given
/// the span instead of the cell width, so changing [count] still ends flush at
/// [right].
List<PlateSlot> plateRegisterAcross({
  required PlateAlphabet alphabet,
  required int count,
  required double left,
  required double right,
  required double top,
  required double height,
  Color? color,
}) {
  _checkCount(count, 'plateRegisterAcross');
  return plateRegister(
    alphabet: alphabet,
    count: count,
    left: left,
    top: top,
    width: count == 0 ? 0 : (right - left) / count,
    height: height,
    color: color,
  );
}

/// One [PlateMirror] per entry of [sources], laid out as a register, in
/// [sources] order. [editable] makes the band a row of paired input fields.
List<PlateMirror> plateEcho({
  required Iterable<int> sources,
  required double left,
  required double top,
  required double width,
  required double height,
  double? pitch,
  double? glyphHeight,
  PlateAlphabet? alphabet,
  bool editable = false,
}) {
  final step = pitch ?? width;
  return List<PlateMirror>.unmodifiable(<PlateMirror>[
    for (final (i, source) in sources.indexed)
      PlateMirror(
        source: source,
        box: PlateBox(left + i * step, top, width, height),
        glyphHeight: glyphHeight ?? height,
        alphabet: alphabet,
        editable: editable,
      ),
  ]);
}

/// [count] identical rules stepping by [stepX] across and [stepY] down, such as
/// a stippled separator.
List<PlateRule> plateStipple({
  required int count,
  required double left,
  required double top,
  required double width,
  required double height,
  double stepX = 0,
  double stepY = 0,
}) {
  _checkCount(count, 'plateStipple');
  return List<PlateRule>.unmodifiable(<PlateRule>[
    for (var i = 0; i < count; i++)
      PlateRule(
        box: PlateBox(left + i * stepX, top + i * stepY, width, height),
      ),
  ]);
}

/// The letter spacing that sets a run of glyphs [height] tall at [pitch]:
/// the pitch less a bold glyph's advance, about 0.6 em of the 0.72 × [height]
/// font [PlateTheme.glyphStyle] draws. Never negative.
double plateRunSpacing(double pitch, double height) =>
    math.max(0, pitch - 0.6 * 0.72 * height);

void _checkCount(int count, String caller) {
  if (count < 0) {
    throw ArgumentError.value(count, 'count', '$caller needs count >= 0');
  }
}

/// [length] glyphs [pitch] apart as one slot, [length] × [pitch] wide, its
/// left edge at [left] or its middle at [centre]. Spaced so the glyphs land at
/// the pitch, unless [spacing] says otherwise.
PlateSlot plateRun(
  PlateAlphabet alphabet,
  int length, {
  required double pitch,
  required double top,
  required double height,
  double? left,
  double? centre,
  int? minLength,
  double? spacing,
  Color? color,
  String? group,
}) {
  assert((left == null) != (centre == null), 'Give left or centre.');
  final width = length * pitch;
  return PlateSlot(
    alphabet: alphabet,
    box: PlateBox(left ?? centre! - width / 2, top, width, height),
    length: length,
    minLength: minLength,
    spacing: spacing ?? plateRunSpacing(pitch, height),
    color: color,
    group: group,
  );
}

/// One item of a [plateRow]. A run or text may be pinned with [left] or
/// [centre], for a field measured off a reference rather than set after its
/// neighbour; the row carries on from its far edge.
sealed class PlateRowItem {
  const PlateRowItem({this.left, this.centre})
    : assert(left == null || centre == null, 'Pin by left or centre.');

  final double? left, centre;

  double _width(double pitch);
}

/// A run of [length] glyphs; see [plateRun]. [pitch] overrides the row's.
class PlateRowRun extends PlateRowItem {
  const PlateRowRun(
    this.alphabet,
    this.length, {
    super.left,
    super.centre,
    this.group,
    this.minLength,
    this.pitch,
    this.spacing,
    this.color,
  });

  final PlateAlphabet alphabet;
  final int length;
  final String? group;
  final int? minLength;
  final double? pitch, spacing;
  final Color? color;

  @override
  double _width(double pitch) => length * (this.pitch ?? pitch);
}

/// [count] one-character slots [cellWidth] wide stepping [pitch] (the row's
/// when null); see [plateRegister]. [top] and [height] override the row's.
class PlateRowCells extends PlateRowItem {
  const PlateRowCells(
    this.alphabet,
    this.count, {
    required this.cellWidth,
    super.left,
    super.centre,
    this.pitch,
    this.top,
    this.height,
    this.group,
  });

  final PlateAlphabet alphabet;
  final int count;
  final double cellWidth;
  final double? pitch, top, height;
  final String? group;

  @override
  double _width(double pitch) =>
      count == 0 ? 0 : (count - 1) * (this.pitch ?? pitch) + cellWidth;
}

/// Fixed wording [width] wide (one pitch when null), such as a hyphen or a
/// printed prefix.
class PlateRowText extends PlateRowItem {
  const PlateRowText(this.text, [this.width, double? left, double? centre])
    : glyphHeight = null,
      color = null,
      top = null,
      height = null,
      super(left: left, centre: centre);

  /// [PlateRowText] with its own glyph height, colour or box.
  const PlateRowText.styled(
    this.text,
    this.width, {
    super.left,
    super.centre,
    this.glyphHeight,
    this.color,
    this.top,
    this.height,
  });

  final String text;
  final double? width;

  /// Null for the row's; set to box a mark smaller than the row, such as a
  /// centred seal.
  final double? top, height;

  /// Null for the row's height.
  final double? glyphHeight;
  final Color? color;

  @override
  double _width(double pitch) => width ?? pitch;
}

/// Empty space [width] wide.
class PlateRowGap extends PlateRowItem {
  const PlateRowGap(this.width) : super();

  final double width;

  @override
  double _width(double pitch) => width;
}

/// The slots and labels a [plateRow] lays out, each item's left edge in
/// [lefts], and where the last item ends.
typedef PlateRowLayout = ({
  List<PlateSlot> slots,
  List<PlateLabel> labels,
  List<double> lefts,
  double right,
});

/// How wide [plateRow] lays [items] out.
double plateRowWidth(
  List<PlateRowItem> items, {
  required double pitch,
  double gap = 0,
}) =>
    items.fold<double>(0, (sum, item) => sum + item._width(pitch)) +
    gap * math.max(0, items.length - 1);

/// Lays [items] left to right on one line [height] tall at [top]: from
/// [left], or centred on [centre] (when every item is pinned, give neither).
/// [gap] separates neighbouring items.
PlateRowLayout plateRow(
  List<PlateRowItem> items, {
  required double pitch,
  required double top,
  required double height,
  double? left,
  double? centre,
  double gap = 0,
}) {
  var x =
      left ??
      (centre == null
          ? 0.0
          : centre - plateRowWidth(items, pitch: pitch, gap: gap) / 2);
  final slots = <PlateSlot>[];
  final labels = <PlateLabel>[];
  final lefts = <double>[];
  var right = x;
  for (final item in items) {
    final w = item._width(pitch);
    x = item.left ?? (item.centre == null ? x : item.centre! - w / 2);
    lefts.add(x);
    right = x + w;
    switch (item) {
      case PlateRowCells():
        slots.addAll(
          plateRegister(
            alphabet: item.alphabet,
            count: item.count,
            left: x,
            top: item.top ?? top,
            width: item.cellWidth,
            height: item.height ?? height,
            pitch: item.pitch ?? pitch,
            group: item.group,
          ),
        );
      case PlateRowRun():
        slots.add(
          plateRun(
            item.alphabet,
            item.length,
            pitch: item.pitch ?? pitch,
            left: x,
            top: top,
            height: height,
            minLength: item.minLength,
            spacing: item.spacing,
            color: item.color,
            group: item.group,
          ),
        );
      case PlateRowText():
        labels.add(
          PlateLabel(
            text: item.text,
            box: PlateBox(
              x,
              item.top ?? top,
              item._width(pitch),
              item.height ?? height,
            ),
            glyphHeight: item.glyphHeight ?? item.height ?? height,
            color: item.color,
          ),
        );
      case PlateRowGap():
    }
    x += w + gap;
  }
  return (slots: slots, labels: labels, lefts: lefts, right: right);
}
