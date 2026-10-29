"""P8 country annotator. usage: p8.py [--write] pkg [pkg...]  (run from repo root)

Detects portability sites by text pattern and inserts TODO(py/ts/kt) triples above the
declaration. Idempotent: a site already preceded by a TODO(ts) line is skipped.
"""
import re, sys, glob, os, unicodedata

WRITE = '--write' in sys.argv
NAME = ''
PKGS = [a for a in sys.argv[1:] if not a.startswith('--')]

T = {
 'regexp': ("[H9] Python re: \\d/\\w match Unicode; keep explicit [0-9]/[A-Z] classes (or re.ASCII).",
            "[H9] same flavour as Dart; port as is, cover accept/reject in the vectors (D9).",
            "[H9] Regex engine differs per target (JVM/JS/Native): keep to portable syntax."),
 'validator': ("[D4-code] hand-port; reason strings are the contract, keep them byte-identical.",
               "[D4-code] hand-port; reason strings are the contract, keep them byte-identical.",
               "[D4-code] hand-port; reason strings are the contract, keep them byte-identical."),
 'table': ("[D4-table] lookup table: becomes a dict in the export, no code.",
           "[D4-table] lookup table: becomes data in the export, no code.",
           "[D4-table] lookup table: becomes a map in the export, no code."),
 'rcode': ("[D4-code] resolver with logic: hand-port against the same vectors (D9).",
           "[D4-code] resolver with logic: hand-port against the same vectors (D9).",
           "[D4-code] resolver with logic: hand-port against the same vectors (D9)."),
 'clipper': ("[H1][D3] CustomClipper: export as a path in plate coordinates; QPainterPath.",
             "[H1][D3] CustomClipper: export as an SVG path string in plate coordinates.",
             "[H1][D3] CustomClipper: export as path data; Compose Path via PathParser."),
 'image': ("[H2][D6] ImageProvider: reference the raster as package + path; importlib.resources.",
           "[H2][D6] ImageProvider: reference the raster as package + path; import as asset URL.",
           "[H2][D6] ImageProvider: reference the raster as package + path; Res/compose resources."),
 'asset': ("[H20][D6] flag asset by package + path; convert to PlateDrawing at export time.",
           "[H20][D6] flag asset by package + path; convert to PlateDrawing at export time.",
           "[H20][D6] flag asset by package + path; convert to PlateDrawing at export time."),
 'cluster': ("[H7] literals hold combining marks or astral characters: keep whole strings, never per-char.",
             "[H7] literals hold combining marks or astral characters: use Array.from, never index.",
             "[H7] literals hold combining marks or astral characters: codePoints(), never chars."),
 'barrel': ("[D5] one module `plates.countries.{n}`; assets via importlib.resources.",
            "[D5] one subpath export `./countries/{n}`; tree-shakable.",
            "[D5] package `countries.{n}` in the countries module."),
}

def lead(lines, i):
    while i > 0 and re.match(r'\s*(///|//|@)', lines[i-1]): i -= 1
    return i

def has(lines, i):
    j = lead(lines, i)
    return any('TODO(ts)' in l for l in lines[max(0, j-3):i])

def block(lines, i):
    d = 0; out = []; started = False
    for l in lines[i:]:
        out.append(l)
        d += l.count('{') - l.count('}') + l.count('(') - l.count(')')
        if '{' in l or '(' in l: started = True
        if started and d <= 0 and (l.rstrip().endswith((';', '}')) ):
            break
    return '\n'.join(out)

def classify(src):
    body = re.sub(r'//.*', '', src)
    logic = re.search(r'\bif \(|\bfor \(|RegExp|parse|&&|\|\||\.codeUnit|\.runes|\.substring|\bwhile\b', body)
    return 'rcode' if logic else 'table'

def find(path):
    lines = open(path, encoding='utf8').read().split('\n')
    sites = []  # (line index, key)
    rx_class = None; seen_val = False; cls_start = 0; cls_done = set()
    for i, l in enumerate(lines):
        if re.match(r'\s*(///|//)', l): continue
        m = re.match(r'(abstract |final |sealed )*class \w+', l)
        if m: cls_start = i
        if re.search(r'class \w+ extends (Gated)?PlateValidator', l) and not seen_val:
            seen_val = True; sites.append((i, 'validator'))
        if 'RegExp(' in l:
            if re.match(r'\s*(static )?(final|const) ', l) and (l.startswith('final') or l.startswith('  static')):
                sites.append((i, 'regexp'))
            elif cls_start not in cls_done and not re.match(r'(final|static)', l):
                cls_done.add(cls_start); sites.append((cls_start, 'regexp'))
        if re.search(r'class \w+ extends CustomClipper', l): sites.append((i, 'clipper'))
        if re.search(r'\bAssetImage\(|\bFileImage\(|\bImage\.asset\(', l): sites.append((i, 'image'))
        if re.search(r'\bSvgPlateAsset\(|\bRasterPlateAsset\(|\bImagePlateAsset\(', l): sites.append((i, 'asset'))
        if re.search(r'^\s*static [\w<>?, ]+ \w+\(', l):
            sig = ' '.join(lines[i:i+6]).split('=>')[0].split('{')[0]
            if 'String Function(String key) group' in sig or re.search(r'PlateTheme base,\s*String Function', sig):
                sites.append((i, classify(block(lines, i))))
    # one image / asset annotation per cluster of 12 lines
    out = []; last = {}
    for i, k in sites:
        if k in last and i - last[k] < (6 if k == 'regexp' else 12) and k in ('image', 'asset', 'regexp'): continue
        last[k] = i; out.append((i, k))
    return lines, out

def cluster_sites(path):
    s = open(path, encoding='utf8').read()
    for lit in re.findall(r"'([^'\n]*)'", s):
        for c in lit:
            if unicodedata.category(c) in ('Mn', 'Mc') or ord(c) > 0xFFFF: return True
    return False

def apply(path, extra=None):
    lines, sites = find(path)
    if extra: sites.append(extra(lines))
    sites = [(i, k) for i, k in sites if not has(lines, i)]
    counts = {}
    for i, k in sorted(set(sites), key=lambda s: -s[0]):
        ind = re.match(r'\s*', lines[i]).group(0)
        j = lead(lines, i)
        ts = tuple(t.replace('{n}', NAME) for t in T[k])
        lines[j:j] = [f"{ind}// TODO({n}): {t}" for n, t in zip(('py', 'ts', 'kt'), ts)]
        counts[k] = counts.get(k, 0) + 1
    if counts and WRITE: open(path, 'w', encoding='utf8').write('\n'.join(lines))
    return counts

def pkg_files(p):
    return [f for f in glob.glob(f'{p}/lib/**/*.dart', recursive=True)]

def run(p):
    tot = {}
    global NAME
    NAME = name = p[:-6]
    for f in pkg_files(p):
        extra = None
        if 'alphabet' in os.path.basename(f) and cluster_sites(f):
            def extra(lines):
                i = next((k for k, l in enumerate(lines) if re.match(r'(abstract |final )*class ', l)), 0)
                return (i, 'cluster')
        if f == f'{p}/lib/{p}.dart':
            def extra(lines, name=name):
                i = next((k for k, l in enumerate(lines) if l.startswith('export')), 0)
                return (i, 'barrel')
        for k, v in apply(f, extra).items(): tot[k] = tot.get(k, 0) + v
    return tot

if __name__ == '__main__':
    for p in PKGS:
        print(p, run(p))
