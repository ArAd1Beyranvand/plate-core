/// Builders for the regular parts of a plate face: runs of equal cells at a
/// constant pitch. [PlateTextGroup] declares which slots form a register; these
/// say where the cells sit.
///
/// They return ordinary [PlateSlot], [PlateMirror] and [PlateRule] values, so
/// the widget layer cannot tell them from literals. Irregular elements stay
/// literals. The lists are not `const`, so a spec built from one is a
/// `static final`; [PlateSpec] equality is over `id` alone.
library;

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
}) {
  _checkCount(count, 'plateRegister');
  final step = pitch ?? width;
  return List<PlateSlot>.unmodifiable(<PlateSlot>[
    for (var i = 0; i < count; i++)
      PlateSlot(
        alphabet: alphabet,
        box: PlateBox(left + i * step, top, width, height),
        color: color,
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
  if (count == 0) return const <PlateSlot>[];
  final width = (right - left) / count;
  return plateRegister(
    alphabet: alphabet,
    count: count,
    left: left,
    top: top,
    width: width,
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
      PlateRule(box: PlateBox(left + i * stepX, top + i * stepY, width, height)),
  ]);
}

void _checkCount(int count, String caller) {
  if (count < 0) {
    throw ArgumentError.value(count, 'count', '$caller needs count >= 0');
  }
}
