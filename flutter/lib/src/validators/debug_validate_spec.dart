import 'package:flutter/widgets.dart';

import '../model/plate_alphabet.dart';
import '../model/plate_box.dart';
import '../model/plate_spec.dart';

/// Debug-only consistency check over [specProblems]: asserts there are none.
/// Always returns true; call it inside `assert(...)`.
bool debugValidateSpec(PlateSpec spec) {
  final problems = specProblems(spec);
  assert(problems.isEmpty, problems.join('\n'));
  return true;
}

/// Everything wrong with [spec], empty for a sound one: every rect fits the
/// canvas, every mirror echoes a real slot, registers are evenly pitched, and
/// alphabet ids key content one-to-one.
List<String> specProblems(PlateSpec spec) {
  final problems = <String>[];
  void check(bool ok, String problem) {
    if (!ok) problems.add(problem);
  }

  void checkInCanvas(PlateBox b, String what) {
    check(
      b.left >= 0 &&
          b.top >= 0 &&
          b.right <= spec.canvasWidth &&
          b.bottom <= spec.canvasHeight,
      '$what in spec "${spec.id}" has a rect outside the '
      'canvas (${spec.canvasWidth}x${spec.canvasHeight}).',
    );
  }

  for (var i = 0; i < spec.slots.length; i++) {
    checkInCanvas(spec.slots[i].box, 'PlateSlot $i');
  }

  for (var i = 0; i < spec.mirrors.length; i++) {
    final m = spec.mirrors[i];
    checkInCanvas(m.box, 'PlateMirror $i');
    check(
      m.source >= 0 && m.source < spec.slots.length,
      'PlateMirror $i in spec "${spec.id}" echoes slot ${m.source}, which is '
      'not a slot index (0..${spec.slots.length - 1}).',
    );
  }

  for (var i = 0; i < spec.bands.length; i++) {
    checkInCanvas(spec.bands[i].box, 'PlateBand $i');
  }

  void checkSection(PlateSection s, Rect r, String path) {
    if (s.isLeaf) {
      final stripes = s.fill!.stripes;
      if (stripes == null) return;
      final stops = s.fill!.stops;
      check(
        stripes.length == stops.length + 1 &&
            stripes.every((f) => !f.isStripes),
        'Background leaf $path in spec "${spec.id}" has ${stripes.length} stripes '
        'and ${stops.length} stops; give one stop between each pair, and do not '
        'nest stripes.',
      );
      for (var i = 1; i < stops.length; i++) {
        check(
          stops[i] > stops[i - 1],
          'Background leaf $path in spec "${spec.id}" has stops out of order: '
          '${stops[i]} after ${stops[i - 1]}.',
        );
      }
      return;
    }
    final across = s.axis == Axis.horizontal;
    var previous = across ? r.left : r.top;
    final end = across ? r.right : r.bottom;
    for (var i = 0; i < s.parts.length; i++) {
      final part = s.parts[i];
      final last = i == s.parts.length - 1;
      check(
        last
            ? part.end == null
            : part.end != null && part.end! > previous && part.end! < end,
        'Background part $path.$i in spec "${spec.id}" ends at ${part.end}; '
        '${last ? "the last part runs to its parent's end, so leave it null" : 'expected a value in ($previous, $end)'}.',
      );
      final partEnd = part.end ?? end;
      final child = across
          ? Rect.fromLTRB(previous, r.top, partEnd, r.bottom)
          : Rect.fromLTRB(r.left, previous, r.right, partEnd);
      checkSection(part.section, child, '$path.$i');
      previous = partEnd;
    }
  }

  checkSection(
    spec.background,
    Rect.fromLTWH(0, 0, spec.canvasWidth, spec.canvasHeight),
    'background',
  );

  // Only keyed groups of three or more cells on one row have a pitch; a
  // register split across lines is exempt.
  for (final g in spec.effectiveTextGroups) {
    if (g.key == null || g.indices.length < 3) continue;
    final boxes = <PlateBox>[
      for (final i in g.indices)
        if (spec.slotAt(i) != null) spec.slots[i].box,
    ];
    if (boxes.length != g.indices.length) continue;
    final sameRow = boxes.every(
      (b) => b.top == boxes.first.top && b.height == boxes.first.height,
    );
    if (!sameRow) continue;
    final pitch = boxes[1].left - boxes[0].left;
    for (var n = 1; n < boxes.length; n++) {
      check(
        (boxes[n].left - boxes[0].left - n * pitch).abs() < 0.01,
        'Register "${g.key}" in spec "${spec.id}" is unevenly pitched: cell $n '
        'sits at ${boxes[n].left}, but a pitch of $pitch puts it at '
        '${boxes[0].left + n * pitch}. Build it with plateRegister/'
        'plateRegisterAcross rather than cell by cell.',
      );
    }
  }

  for (final r in spec.restrictions) {
    check(
      spec.effectiveTextGroups.any((g) => g.key == r.group),
      'Restriction "${r.reason}" in spec "${spec.id}" watches group '
      '"${r.group}", which no text group carries — it would never fire.',
    );
  }

  // An alphabet id must map one-to-one onto rendered content, keyed by
  // characters and glyphs: national numerals share `latin.digits`' characters
  // but mean something else.
  final byId = <String, String>{};
  final byContent = <String, String>{};
  for (final a in <PlateAlphabet>[
    for (final slot in spec.slots) slot.alphabet,
    for (final m in spec.mirrors)
      if (m.alphabet != null) m.alphabet!,
  ]) {
    final contentKey = _contentKey(a);
    final seenContent = byId[a.id];
    check(
      seenContent == null || seenContent == contentKey,
      'Alphabet id "${a.id}" in spec "${spec.id}" appears with two different '
      'character/glyph sets.',
    );
    byId[a.id] = contentKey;
    final seenId = byContent[contentKey];
    check(
      seenId == null || seenId == a.id,
      'Spec "${spec.id}" has two distinct alphabet ids ("$seenId", "${a.id}") '
      'sharing the same characters and glyphs.',
    );
    byContent[contentKey] = a.id;
  }
  return problems;
}

String _contentKey(PlateAlphabet a) =>
    a.characters.map((c) => '$c=${a.render(c)}').join(' ');
