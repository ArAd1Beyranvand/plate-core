"""Discover every country package's public PlateSpec catalogue and generate
the Dart registry that dump_specs.dart reads.

Writes, next to this folder:
  pubspec.yaml        path deps on every discovered package
  registry.g.dart     one entry per public catalogue member

Discovery is static (regex over the files each package's library exports), so
it reports what it could not reach instead of guessing: lookup functions with
non-enumerable parameters, private caches, private spec fields.
"""

import itertools
import json
import re
import sys
from pathlib import Path

TOOL = Path(__file__).resolve().parent.parent
ROOT = TOOL.parent.parent

# Packages that bundle several countries in src/<country>/: each subfolder
# becomes its own report key, e.g. iranshahr.oman.
SPLIT_PACKAGES = {'iranshahr_plate'}

SPEC_TYPE = (r'(PlateSpec\??|List<PlateSpec>|Iterable<PlateSpec>'
             r'|Map<[^=;{]*?,\s*PlateSpec(?:\s+Function\(\))?>)')
FIELD_RE = re.compile(r'\bstatic\s+(?:const\s+|final\s+|late\s+final\s+)?' + SPEC_TYPE + r'\s+(\w+)\s*[=;]')
GETTER_RE = re.compile(r'\bstatic\s+' + SPEC_TYPE + r'\s+get\s+(\w+)')
FUNC_RE = re.compile(r'\bstatic\s+' + SPEC_TYPE + r'\s+(\w+)\s*\(')
TOP_RE = re.compile(r'^(?:const|final)\s+' + SPEC_TYPE + r'\s+(\w+)\s*=', re.M)
CLASS_RE = re.compile(r'^(?:abstract\s+|final\s+|sealed\s+|base\s+|interface\s+)*class\s+(\w+)[^{]*\{', re.M)
TOP_FUNC_RE = re.compile(r'^PlateSpec\s+([a-z]\w*)\s*\(\s*\)', re.M)
ENUM_RE = re.compile(r'^enum\s+(\w+)', re.M)
EXPORT_RE = re.compile(r"^export\s+'([^']+)'([^;]*);", re.M)


def strip_comments(src):
    src = re.sub(r'/\*.*?\*/', '', src, flags=re.S)
    return re.sub(r'(?m)//.*$', '', src)


def class_bodies(src):
    """(name, body) for each top-level class, by brace matching."""
    for m in CLASS_RE.finditer(src):
        depth, i = 1, m.end()
        while i < len(src) and depth:
            depth += {'{': 1, '}': -1}.get(src[i], 0)
            i += 1
        yield m.group(1), src[m.end():i - 1]


def exported_files(lib_file, seen=None):
    """{path: (show set | None, hide set)} reachable through export directives."""
    seen = {} if seen is None else seen
    src = strip_comments(lib_file.read_text())
    for m in EXPORT_RE.finditer(src):
        uri, combinators = m.group(1), m.group(2)
        if uri.startswith('package:') or uri.startswith('dart:'):
            continue
        path = (lib_file.parent / uri).resolve()
        if not path.exists() or path in seen:
            continue
        show = re.search(r'\bshow\s+([\w\s,]+)', combinators)
        hide = re.search(r'\bhide\s+([\w\s,]+)', combinators)
        seen[path] = (
            {s.strip() for s in show.group(1).split(',')} if show else None,
            {s.strip() for s in hide.group(1).split(',')} if hide else set(),
        )
        exported_files(path, seen)
    return seen


def visible(name, show, hide):
    return (show is None or name in show) and name not in hide


def split_params(params):
    """Positional-required params as (type, name); and whether any exist after."""
    params = params.strip()
    required = re.split(r'[\[{]', params, 1)[0]
    out = []
    for p in [p.strip() for p in required.split(',') if p.strip()]:
        parts = p.split()
        if len(parts) >= 2:
            out.append((' '.join(parts[:-1]), parts[-1]))
    return out


def report_key(pkg, path):
    base = pkg[:-len('_plate')]
    if pkg in SPLIT_PACKAGES:
        rel = path.relative_to(ROOT / pkg / 'lib' / 'src')
        if len(rel.parts) > 1:
            return f'{base}.{rel.parts[0]}'
    return base


def discover():
    packages = sorted(
        p.name for p in ROOT.iterdir()
        if p.is_dir() and p.name.endswith('_plate') and not p.name.startswith('plate_')
        and (p / 'pubspec.yaml').exists() and (p / 'lib' / f'{p.name}.dart').exists()
    )
    entries, warnings, validators = [], {}, {}
    for pkg in packages:
        lib = ROOT / pkg / 'lib'
        files = exported_files(lib / f'{pkg}.dart')
        # Types whose every value is nameable: enums, and classes holding
        # `static const T name` instances of themselves (the house style for
        # extensible concepts). Maps type -> Dart list expression.
        enums = {}
        for path, (show, hide) in files.items():
            src = strip_comments(path.read_text())
            for e in ENUM_RE.findall(src):
                if visible(e, show, hide):
                    enums[e] = f'{e}.values'
            for cls, body in class_bodies(src):
                consts = re.findall(r'\bstatic\s+const\s+' + cls + r'\s+([a-zA-Z]\w*)\s*=', body)
                if consts and visible(cls, show, hide):
                    enums[cls] = '[' + ', '.join(f'{cls}.{c}' for c in consts) + ']'

        for path in sorted(files):
            show, hide = files[path]
            key = report_key(pkg, path)
            warn = warnings.setdefault(key, [])
            src = strip_comments(path.read_text())
            rel = path.relative_to(ROOT)
            if 'validator' in path.name:
                validators.setdefault(key, []).append(str(rel))
            for name in TOP_RE.findall(src):
                if not name[1].startswith('_') and visible(name[1], show, hide):
                    entries.append((pkg, key, name[1], f'{pkg}.{name[1]}'))
            for name in TOP_FUNC_RE.findall(src):
                if visible(name, show, hide):
                    entries.append((pkg, key, f'{name}()', f'{pkg}.{name}()'))
            for cls, body in class_bodies(src):
                if cls.startswith('_') or not visible(cls, show, hide):
                    continue
                for _, member in FIELD_RE.findall(body) + GETTER_RE.findall(body):
                    if member.startswith('_'):
                        warn.append(f'{rel}: private catalogue {cls}.{member} '
                                    '(specs in it are dumped only if also reachable publicly)')
                    else:
                        entries.append((pkg, key, f'{cls}.{member}', f'{cls}.{member}'))
                for fm in FUNC_RE.finditer(body):
                    member = fm.group(2)
                    if member.startswith('_'):
                        continue
                    close = body.find(')', fm.end())
                    params = split_params(body[fm.end():close])
                    raw = body[fm.end():close]
                    enumerable = (all(t in enums or t == 'bool' for t, _ in params)
                                  and not re.search(r'\brequired\b', raw))
                    if not enumerable:
                        warn.append(f'{rel}: lookup function {cls}.{member}('
                                    f'{" ".join(raw.split())}) has non-enumerable '
                                    'parameters; only its default/catalogued results are dumped')
                        continue
                    domains = [[f'{t}.values'] if t != 'bool' else ['true', 'false'] for t, _ in params]
                    if any(t != 'bool' for t, _ in params):
                        # enum params: iterate .values inside Dart
                        entries.append((pkg, key, f'{cls}.{member}(*)',
                                        _enum_call(cls, member, params, enums)))
                    else:
                        for combo in itertools.product(*domains):
                            entries.append((pkg, key, f'{cls}.{member}({", ".join(combo)})',
                                            f'{cls}.{member}({", ".join(combo)})'))
                    if '{' in raw or '[' in raw:
                        warn.append(f'{rel}: {cls}.{member} has optional parameters; '
                                    'only the defaults are dumped')
                if re.search(r'\bstatic\s+final\s+Map<[^>]*PlateSpec>\s+_\w*cache', body, re.I):
                    warn.append(f'{rel}: {cls} builds specs at runtime into a private cache')
    reached = {e[0] for e in entries}
    for pkg in packages:
        if pkg not in reached:
            warnings.setdefault(pkg[:-len('_plate')], []).append(
                'no public PlateSpec catalogue found by discovery')
    return [p for p in packages if p in reached], entries, {k: v for k, v in warnings.items() if v}, validators


def _enum_call(cls, member, params, enums):
    """A Dart expression listing member(...) over every enum/bool combination."""
    loops, args = [], []
    for i, (t, _) in enumerate(params):
        dom = '[true, false]' if t == 'bool' else enums[t]
        loops.append(f'for (final a{i} in {dom})')
        args.append(f'a{i}')
    return f'<Object?>[{" ".join(loops)} {cls}.{member}({", ".join(args)})]'


def dart_str(s):
    return json.dumps(s).replace('$', '\\$')


def write(packages, entries, warnings, validators):
    deps = '\n'.join(f'  {p}:\n    path: ../../{p}' for p in packages)
    (TOOL / 'pubspec.yaml').write_text(f'''# GENERATED by analyzer/gen_registry.py — do not edit by hand.
name: migration_analyzer
publish_to: none

environment:
  sdk: '>=3.10.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_test:
    sdk: flutter
  plate_core:
    path: ../../plate_core
{deps}

dev_dependencies:
  flutter_lints: ^6.0.0

dependency_overrides:
  plate_core:
    path: ../../plate_core
  plate_alphabet:
    path: ../../plate_alphabet
  plate_keypad:
    path: ../../plate_keypad
''')
    lines = ['// GENERATED by analyzer/gen_registry.py — do not edit by hand.',
             '// ignore_for_file: deprecated_member_use', '']
    for p in packages:
        lines.append(f"import 'package:{p}/{p}.dart' as {p};")
    lines += ['', 'typedef RegistryEntry = ({String package, String key, String source, Object? Function() read});', '',
              'final List<RegistryEntry> registry = <RegistryEntry>[']
    for pkg, key, label, expr in entries:
        expr = re.sub(r'\b([A-Z]\w*)\.', lambda m: f'{pkg}.{m.group(1)}.', expr)
        lines.append(f"  (package: '{pkg}', key: '{key}', source: {dart_str(label)}, read: () => {expr}),")
    lines += ['];', '', 'const Map<String, List<String>> discoveryWarnings = <String, List<String>>{']
    for k, ws in sorted(warnings.items()):
        lines.append(f"  '{k}': <String>[")
        lines += [f'    {dart_str(w)},' for w in ws]
        lines.append('  ],')
    lines += ['};', '', 'const Map<String, List<String>> validatorFiles = <String, List<String>>{']
    for k, fs in sorted(validators.items()):
        lines.append(f"  '{k}': <String>[{', '.join(json.dumps(f) for f in fs)}],")
    lines += ['};', '']
    (TOOL / 'registry.g.dart').write_text('\n'.join(lines))


def main():
    packages, entries, warnings, validators = discover()
    write(packages, entries, warnings, validators)
    print(f'{len(packages)} packages, {len(entries)} catalogue entries, '
          f'{sum(map(len, warnings.values()))} discovery warnings')
    return 0


if __name__ == '__main__':
    sys.exit(main())
