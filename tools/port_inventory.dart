// Writes claude/port/inventory.csv: one row per country package with the
// counts that decide how it ports (claude/port/ROADMAP.md, D3/D4, H1-H9).
//
// Text-level scan, no analyzer: counts are of source occurrences, good enough
// to sort packages into classes, not a substitute for reading the code.
//
//   dart run tools/port_inventory.dart
import 'dart:io';

const _notCountries = {'plate_core', 'plate_alphabet', 'plate_keypad'};

final _columns = <String, RegExp>{
  'specs': RegExp(r'\bPlateSpec\('),
  'resolveTheme': RegExp(r'\bresolveTheme:'),
  'labelResolve': RegExp(r'\bresolve:'),
  'resolveRegion': RegExp(r'\bresolveRegion:'),
  'validators': RegExp(r'extends\s+(Gated)?PlateValidator\b'),
  'regexps': RegExp(r'\bRegExp\('),
  'shapes': RegExp(r'\bshape:'),
  'clippers': RegExp(r'extends\s+CustomClipper\b'),
  'decalImages': RegExp(r'\bimage:\s*\w*Image\('),
  'decalDrawings': RegExp(r'\bdrawing:'),
  'svgAssets': RegExp(r'\bSvgPlateAsset\('),
  'rasterAssets': RegExp(r'\bRasterPlateAsset\('),
  'drawings': RegExp(r'\bPlateDrawing\('),
  'fonts': RegExp(r'\bfontFamily:'),
};

final _literal = RegExp(r"'((?:[^'\\\n]|\\.)*)'");

// Unicode Mn/Mc blocks used by plate scripts: Latin combining, Hebrew, Arabic,
// Indic, Thai, Lao, Myanmar, Khmer, Ethiopic, joiners.
bool _isCombining(int r) =>
    (r >= 0x0300 && r <= 0x036F) ||
    (r >= 0x0591 && r <= 0x05C7) ||
    (r >= 0x0610 && r <= 0x061A) ||
    (r >= 0x064B && r <= 0x065F) ||
    r == 0x0670 ||
    (r >= 0x06D6 && r <= 0x06ED) ||
    (r >= 0x0900 && r <= 0x0903) ||
    (r >= 0x093A && r <= 0x094F) ||
    (r >= 0x0951 && r <= 0x0957) ||
    (r >= 0x0962 && r <= 0x0963) ||
    (r >= 0x0981 && r <= 0x0983) ||
    (r >= 0x09BC && r <= 0x09D7) ||
    (r >= 0x0A01 && r <= 0x0A83) ||
    (r >= 0x0ABC && r <= 0x0D57 && _indicMark(r)) ||
    r == 0x0E31 ||
    (r >= 0x0E34 && r <= 0x0E3A) ||
    (r >= 0x0E47 && r <= 0x0E4E) ||
    r == 0x0EB1 ||
    (r >= 0x0EB4 && r <= 0x0EBC) ||
    (r >= 0x0EC8 && r <= 0x0ECD) ||
    (r >= 0x102B && r <= 0x103E) ||
    (r >= 0x1056 && r <= 0x1059) ||
    (r >= 0x135D && r <= 0x135F) ||
    (r >= 0x17B4 && r <= 0x17D3) ||
    r == 0x200C ||
    r == 0x200D;

// In the Gujarati..Malayalam blocks the marks sit at offsets 0x3C..0x57 and
// 0x01..0x03 of each 0x80 block.
bool _indicMark(int r) {
  final o = r & 0x7F;
  return (o >= 0x3C && o <= 0x57 && o != 0x3D) || (o >= 0x01 && o <= 0x03);
}

void main() {
  final root = Directory.current;
  final packages =
      root
          .listSync()
          .whereType<Directory>()
          .map((d) => d.uri.pathSegments.where((s) => s.isNotEmpty).last)
          .where((n) => n.endsWith('_plate') || n == 'plate_alphabet')
          .where((n) => !_notCountries.contains(n) || n == 'plate_alphabet')
          .toList()
        ..sort();

  final header = [
    'package',
    'class',
    ..._columns.keys,
    'multiCodePoint',
    'combining',
    'nonBmp',
    'loc',
  ];
  final rows = <List<Object>>[header];
  final totals = <String, int>{};

  for (final name in packages) {
    final lib = Directory('${root.path}/$name/lib');
    if (!lib.existsSync()) continue;
    final files = lib
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    final counts = {for (final k in _columns.keys) k: 0};
    var multi = 0, combining = 0, nonBmp = 0, loc = 0;
    for (final f in files) {
      final src = f.readAsStringSync();
      loc += '\n'.allMatches(src).length;
      final code = src
          .split('\n')
          .where((l) => !l.trimLeft().startsWith('//'))
          .join('\n');
      _columns.forEach(
        (k, re) => counts[k] = counts[k]! + re.allMatches(code).length,
      );
      final alphabetFile = code.contains('PlateAlphabet');
      for (final m in _literal.allMatches(code)) {
        final runes = m.group(1)!.runes.toList();
        if (runes.any(_isCombining)) combining++;
        if (runes.any((r) => r > 0xFFFF)) nonBmp++;
        // A multi-code-point alphabet entry: a short literal with no space
        // inside a file that declares alphabets (pattern ranges excluded).
        if (alphabetFile &&
            runes.length > 1 &&
            runes.length <= 4 &&
            !runes.contains(0x20) &&
            !(runes.length == 3 && runes[1] == 0x2D) &&
            !m.group(1)!.contains(RegExp(r'[._$/\\]|^[a-z]'))) {
          multi++;
        }
      }
    }
    // C: clippers, raster decals or more than a couple of validators/RegExps
    // need a hand port. B: a validator or resolver small enough to port with
    // the data. A: data only.
    final handPort =
        counts['clippers']! + counts['decalImages']! > 0 ||
        counts['validators']! > 2 ||
        counts['regexps']! > 2;
    final small =
        counts['validators']! +
            counts['resolveTheme']! +
            counts['labelResolve']! +
            counts['resolveRegion']! >
        0;
    final cls = name == 'plate_alphabet'
        ? '-'
        : handPort
        ? 'C'
        : small
        ? 'B'
        : 'A';
    if (cls != '-') totals[cls] = (totals[cls] ?? 0) + 1;
    rows.add([
      name,
      cls,
      for (final k in _columns.keys) counts[k]!,
      multi,
      combining,
      nonBmp,
      loc,
    ]);
  }

  final out = File('${root.path}/claude/port/inventory.csv')
    ..createSync(recursive: true)
    ..writeAsStringSync('${rows.map((r) => r.join(',')).join('\n')}\n');
  stdout.writeln('${out.path}: ${rows.length - 1} rows, classes $totals');
}
