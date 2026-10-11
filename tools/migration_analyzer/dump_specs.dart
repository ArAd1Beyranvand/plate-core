// Dumps every PlateSpec reachable from registry.g.dart to out/specs/<key>.json.
//
// plate_core imports dart:ui, so this cannot run under `dart run`; run it as
//   flutter test dump_specs.dart
// from tools/migration_analyzer (after `python3 analyzer/gen_registry.py`).
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plate_core/plate_core.dart';
import 'package:plate_number_holder/screens/gallery/sources/sources.dart';

import 'registry.g.dart';

void main() {
  test('dump gallery', _dumpGallery);
  test('dump specs', () {
    final out = Directory('out/specs')..createSync(recursive: true);
    final validatorsOut = Directory('out/validators')
      ..createSync(recursive: true);

    // Identity, not ==: PlateSpec.== compares ids only, and two different
    // objects sharing an id is itself something to report.
    final specs = LinkedHashMap<PlateSpec, _Found>.identity();
    final errors = <String, List<String>>{};

    for (final e in registry) {
      Object? value;
      try {
        value = e.read();
      } catch (err) {
        errors.putIfAbsent(e.key, () => []).add('${e.source} threw: $err');
        continue;
      }
      void add(Object? v, String path) {
        if (v is PlateSpec) {
          specs
              .putIfAbsent(v, () => _Found(e.package, e.key))
              .catalogues
              .add(path);
        } else if (v is PlateSpec Function()) {
          add(v(), '$path()');
        } else if (v is Map) {
          for (final entry in v.entries) {
            add(entry.value, '$path[${entry.key}]');
          }
        } else if (v is Iterable) {
          var i = 0;
          for (final x in v) {
            add(x, '$path[${i++}]');
          }
        }
      }

      add(value, e.source);
    }

    final byKey = <String, List<Map<String, Object?>>>{};
    final keys = <String>{
      for (final f in specs.values) f.key,
      ...discoveryWarnings.keys,
      ...errors.keys,
    };
    final packageOf = <String, String>{
      for (final e in registry) e.key: e.package,
    };
    for (final MapEntry(key: spec, value: found) in specs.entries) {
      byKey.putIfAbsent(found.key, () => []).add({
        ..._spec(spec),
        'catalogues': <String>[...found.catalogues],
      });
    }

    for (final key in keys.toList()..sort()) {
      final list = byKey[key] ?? [];
      final warnings = <String>[
        ...?discoveryWarnings[key],
        ...?errors[key],
      ];
      _markClones(list, warnings);
      _specTotal += list.length;
      final validatorText = StringBuffer();
      for (final path in validatorFiles[key] ?? const <String>[]) {
        validatorText
          ..writeln('// ===== $path')
          ..writeln(File('../../$path').readAsStringSync());
      }
      if (validatorText.isNotEmpty) {
        File(
          '${validatorsOut.path}/$key.txt',
        ).writeAsStringSync(validatorText.toString());
      }
      if (list.isEmpty) warnings.add('no PlateSpec reached for this key');
      File('${out.path}/$key.json').writeAsStringSync(
        const JsonEncoder.withIndent(' ').convert({
          'country': key,
          'package': packageOf[key],
          'specCount': list.length,
          'validatorFiles': validatorFiles[key] ?? const <String>[],
          'warnings': warnings,
          'specs': list,
        }),
      );
    }
    // ignore: avoid_print
    print('dumped $_specTotal specs into ${keys.length} files');
  });
}

var _specTotal = 0;

/// Every gallery entry, flattened over umbrella sources, to
/// out/gallery.json. Theme identity is by value (PlateTheme.==), numbered in
/// order of first appearance so two entries can be compared by `theme`.
void _dumpGallery() {
  final themes = <PlateTheme>[];
  final seen = <String>{};
  final entries = <Map<String, Object?>>[];
  void visit(GallerySource source) {
    for (final m in source.members) {
      visit(m);
    }
    for (final section in source.sections) {
      for (final e in section.entries) {
        if (!seen.add('${e.id}|${e.spec.id}')) continue;
        var theme = e.theme == null ? -1 : themes.indexOf(e.theme!);
        if (e.theme != null && theme < 0) {
          themes.add(e.theme!);
          theme = themes.length - 1;
        }
        entries.add({
          'source': source.countryName,
          'packages': source.packageNames,
          'section': section.title,
          'id': e.id,
          'label': e.label,
          'specId': e.spec.id,
          'theme': theme,
          'themeColors': e.theme == null
              ? null
              : [_c(e.theme!.plateBackground), _c(e.theme!.ink)],
          'country': e.country?.code ?? e.spec.country.code,
          'validator': e.validator?.runtimeType.toString(),
          'valueDrivenTheme': e.themeForValues != null,
          'sample': e.sampleValues?.map((v) => v ?? '').join(),
        });
      }
    }
  }

  for (final s in gallerySources) {
    visit(s);
  }
  Directory('out').createSync(recursive: true);
  File('out/gallery.json').writeAsStringSync(
    const JsonEncoder.withIndent(' ').convert(entries),
  );
  // ignore: avoid_print
  print('dumped ${entries.length} gallery entries');
}

class _Found {
  _Found(this.package, this.key);
  final String package;
  final String key;
  final List<String> catalogues = [];
}

String _body(Map<String, Object?> s) => jsonEncode({
  for (final e in s.entries)
    if (e.key != 'id' && e.key != 'country' && e.key != 'catalogues')
      e.key: e.value,
});

/// A lookup function rebuilds a spec as a new object; the same id with the
/// same content is one spec reached twice, so its catalogues merge. The same
/// id with different content is a warning. Specs equal in everything but
/// id/country are clones.
void _markClones(List<Map<String, Object?>> list, List<String> warnings) {
  final byId = <String, Map<String, Object?>>{};
  list.removeWhere((s) {
    final first = byId[s['id']! as String];
    if (first == null) {
      byId[s['id']! as String] = s;
      return false;
    }
    if (_body(first) == _body(s)) {
      (first['catalogues']! as List<String>).addAll(
        s['catalogues']! as List<String>,
      );
      return true;
    }
    warnings.add(
      'two PlateSpec objects share id "${s['id']}" but differ in content; '
      'both kept',
    );
    return false;
  });
  final firstByBody = <String, String>{};
  for (final s in list) {
    final id = s['id']! as String;
    final body = _body(s);
    final original = firstByBody[body];
    if (original != null && original != id) {
      s['cloneOf'] = original;
    } else {
      firstByBody[body] = id;
    }
  }
}

String _c(Color? c) => c == null
    ? 'theme'
    : '#${c.toARGB32().toRadixString(16).padLeft(8, '0')}';

double _r(double v) => (v * 100).roundToDouble() / 100;

List<double> _box(PlateBox b) => [
  _r(b.left),
  _r(b.top),
  _r(b.width),
  _r(b.height),
];

Map<String, Object?> _alphabet(PlateAlphabet a) => {
  'count': a.characters.length,
  'sample': a.characters.take(12).join(),
  'numeric': a.isNumeric,
  'input': a.input.name,
  'direction': a.direction.name,
  'glyphs': a.glyphs.length,
  'glyphSample': a.characters.take(12).map(a.render).join(),
};

Object? _fill(PlateFill f) {
  if (f.isStripes) {
    return {
      'stripes': [for (final s in f.stripes!) _fill(s)],
      'stops': f.stops.map(_r).toList(),
      'angle': _r(f.angle),
      'fog': f.fog != null,
    };
  }
  if (f.isField) return 'field';
  if (f.isPanel) return 'panel';
  if (f.color == null) return 'divider';
  return _c(f.color);
}

Object? _section(PlateSection s) => s.isLeaf
    ? {
        'fill': _fill(s.fill!),
        if (s.shape != null) 'shape': s.shape.runtimeType.toString(),
      }
    : {
        'axis': s.axis == Axis.horizontal ? 'columns' : 'rows',
        'parts': [
          for (final p in s.parts)
            {
              'end': p.end == null ? null : _r(p.end!),
              'divider': _r(p.divider),
              'section': _section(p.section),
            },
        ],
      };

/// Many identical rules (a stipple) collapse to one summary entry.
Object _rules(List<PlateRule> rules) {
  if (rules.length <= 6) return [for (final r in rules) _box(r.box)];
  final sizes = {for (final r in rules) '${_r(r.box.width)}x${_r(r.box.height)}'};
  final lefts = [for (final r in rules) r.box.left]..sort();
  return {
    'count': rules.length,
    'sizes': sizes.toList(),
    'pitch': _r(lefts[1] - lefts[0]),
    'extent': [
      _r(lefts.first),
      _r(rules.map((r) => r.box.right).reduce((a, b) => a > b ? a : b)),
    ],
    'summary':
        '${rules.length} rects ${sizes.join('/')}, '
        'x ${_r(lefts.first)}..${_r(lefts.last)}',
  };
}

Map<String, Object?> _spec(PlateSpec s) {
  final groupOf = <int, int>{};
  final groups = s.effectiveTextGroups;
  for (var g = 0; g < groups.length; g++) {
    for (final i in groups[g].indices) {
      groupOf[i] = g;
    }
  }
  final alphabets = <String, Object?>{
    for (final slot in s.slots) slot.alphabet.id: _alphabet(slot.alphabet),
    for (final m in s.mirrors)
      if (m.alphabet != null) m.alphabet!.id: _alphabet(m.alphabet!),
  };
  return {
    'id': s.id,
    'country': {
      'code': s.country.code,
      'captionLines': s.country.captionLines,
      'headingLines': s.country.headingLines,
      'panelColor': _c(s.country.panelColor),
      'panelTextColor': _c(s.country.panelTextColor),
      'flag': s.country.flag?.path,
    },
    'canvas': [_r(s.canvasWidth), _r(s.canvasHeight)],
    'aspect': _r(s.canvasWidth / s.canvasHeight),
    'direction': s.textDirection.name,
    'borderRatio': s.borderWidthRatioOverride,
    'ink': s.inkOverride == null ? null : _c(s.inkOverride),
    'panel': {
      'hidden': s.noPanel,
      'box': _box(s.panel.box),
      'flagScale': s.panel.flagScale,
      'captionScale': s.panel.captionScale,
      'padding': s.panel.padding?.toString(),
      'axis': s.panel.direction.name,
      'shape': s.panel.shape?.runtimeType.toString(),
    },
    'background': _section(s.background),
    'alphabets': alphabets,
    'slots': [
      for (var i = 0; i < s.slots.length; i++)
        {
          'i': i,
          'box': _box(s.slots[i].box),
          'alphabet': s.slots[i].alphabet.id,
          'input': s.slots[i].alphabet.input.name,
          'group': groupOf[i],
          if (s.slots[i].color != null) 'color': _c(s.slots[i].color),
          // Distance from the previous slot's left edge, when both sit on the
          // same row: an evenly pitched register repeats one value.
          'pitch':
              i > 0 &&
                  s.slots[i - 1].box.top == s.slots[i].box.top &&
                  s.slots[i - 1].box.height == s.slots[i].box.height
              ? _r(s.slots[i].box.left - s.slots[i - 1].box.left)
              : null,
        },
    ],
    'textGroups': [
      for (final g in groups)
        {
          'key': g.key,
          'indices': g.indices,
          'prefix': g.prefix,
          'reversed':
              g.indices.length > 1 && g.indices.first > g.indices.last,
        },
    ],
    'explicitTextGroups': s.textGroups.isNotEmpty,
    'mirrors': [
      for (final m in s.mirrors)
        {
          'source': m.source,
          'box': _box(m.box),
          'glyphHeight': _r(m.glyphHeight),
          'alphabet': m.alphabet?.id,
          'editable': m.editable,
        },
    ],
    'rules': _rules(s.rules),
    'labels': [
      for (final l in s.labels)
        {
          'text': l.text,
          'box': _box(l.box),
          'glyphHeight': _r(l.glyphHeight),
          if (l.color != null) 'color': _c(l.color),
          if (l.rotated) 'rotated': true,
          if (l.fontFamily != null) 'font': l.fontFamily,
        },
    ],
    'bands': [
      for (final b in s.bands)
        {'box': _box(b.box), 'color': _c(b.color)},
    ],
    'decals': [
      for (final d in s.decals)
        {'image': d.image.toString(), 'box': _box(d.box)},
    ],
    'restrictions': [
      for (final r in s.restrictions)
        {'group': r.group, 'values': r.values, 'reason': r.reason},
    ],
  };
}
