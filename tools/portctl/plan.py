"""The task graph: phases in the agreed order, their static tasks, and the expanders that add
tasks at run time (TODO audits, country units) once the facts they need exist."""
import json, re
from pathlib import Path

from config import ROOT, PORTS, LANGS, DONE_THROUGH

NAMES = {'ts': 'TypeScript', 'kt': 'Kotlin', 'py': 'Python'}
WEB_LANG = {'ts': 'typescript', 'kt': 'kotlin', 'py': 'python'}   # registry keys and deploy folders (W2)
# Injected into every Claude prompt of the language ({{lang_rules}} in _common.md).
LANG_RULES = {
    'ts': 'TypeScript runs in the browser: core and render framework-free, UI = SVG + DOM inputs '
          '(`src/ui`). No `node:` imports under `src/`.',
    'kt': 'Kotlin runs in the browser (W5): Kotlin Multiplatform with `jvm` for tests and BOTH `js(IR)` and '
          '`wasmJs`; core and render in `commonMain` (no `java.*`), UI = SVG + DOM inputs over the display '
          'list in a `webMain` set shared by js and wasmJs, like TS. No Compose. The page loads one build only: '
          'Wasm when WasmGC validates, JS otherwise.',
    'py': 'Python runs in the browser under Pyodide (CPython 3.13), and on the host for tests (3.10, so '
          'keep 3.10 syntax). `plates/` is pure Python, stdlib only: no PySide6/Qt, threads, '
          'subprocess, sockets or file I/O; data arrives as text. The UI is `plates.ui` (svg.py paints the '
          'display list, plate_canvas.py is headless, dom.py binds to the page through injected '
          '`document`/proxy fakes so it is host-testable); timers and animation go through that seam '
          '(setTimeout/requestAnimationFrame). Dart `TODO(py)` notes that name Qt keep their behaviour, '
          'on the DOM. `web_check` in portctl.json (Pyodide under node) must stay green.',
}

# Idioms small local models get wrong; injected into the unit prompt ({{idioms}}).
UNIT_IDIOMS = {
    'kt': ['Kotlin has no `late`/`static`: a Dart `static const` becomes a `const val` in a `companion object` '
           '(strings and numbers only); a `static final RegExp` becomes `val` in the companion: `Regex("...")`.',
           'Write plain Kotlin only: never invent helpers such as `WHEN_CALL`, `hasMatch`, `maxDigits(...)`. '
           'Regex: `re.matches(s)` (whole string) or `re.containsMatchIn(s)`; Dart `hasMatch` = `containsMatchIn`.',
           'Constructor fields stay constructor properties (`class X(val maxDigits: Int = 4)`); use them as '
           '`maxDigits`/`this.maxDigits`, never call them.',
           'Strings: Dart `$x`/`${x}` interpolation is identical in Kotlin. `a?.b` needs `?.` on nullable receivers.',
           'Reuse the target stub shown below: keep its package, imports and class header, replace only the '
           'TODO bodies. Extend the base class the Dart extends (`GatedPlateValidator`: override `gateGroup` and '
           '`judge`, not `validate`). Use `PlateValidation.valid` (property, no parens) and '
           '`PlateValidation.invalid(reason)`; helpers `isDigits`, `isDigitsOfLength` already exist in '
           '`plates.core.validators`.'],
    'ts': [],
    'py': [],
}

# S2 is split along the Dart source so each Claude task has one testable slice.
CORE_PARTS = [
    ('values', 'geometry and value types (H10, H17, H18, H19)',
     ['model/plate_box.dart', 'model/plate_shape.dart', 'model/plate_asset.dart', 'drawings/european_stars.dart']),
    ('alphabet', 'alphabet, slot, spec, country (H3, H5, H7, H8, H21, H22, H24)',
     ['model/plate_alphabet.dart', 'model/plate_spec.dart', 'model/plate_country.dart',
      'model/slot_behavior.dart', 'model/plate_input_source.dart']),
    ('layout', 'section layout, restriction, validation, specProblems (H9, H23)',
     ['model/plate_layout.dart', 'model/plate_restriction.dart', 'validators/plate_validator.dart',
      'validators/debug_validate_spec.dart', 'theme/plate_theme.dart']),
    ('input', 'controller and the pure input machine (D7, D8)',
     ['input/plate_controller.dart', 'input/plate_input_machine.dart', 'input/plate_input_controller.dart']),
    ('timing', 'animation timing model: stagger, cues, curves (H11)',
     ['animation/plate_animation.dart', 'animation/plate_part_animator.dart']),
]
UI_PARTS = [
    ('render', 'render layer: spec + theme + values + part frames -> display list (D1, H12, H13, H15)',
     ['widgets/plate_canvas.dart', 'widgets/plate_frame.dart', 'widgets/plate_divider.dart',
      'widgets/plate_glyph_run.dart', 'widgets/plate_text_row.dart', 'widgets/plate_drawing_view.dart',
      'widgets/plate_flag.dart', 'widgets/country_panel.dart']),
    ('ui', 'ui layer: painter over the display list, inputs at slot boxes, animation driver (D2, D6, D8)',
     ['widgets/plate_canvas.dart', 'widgets/plate_view.dart', 'widgets/plate_slot_item.dart',
      'widgets/plate_selector.dart']),
    ('keypad', 'plate_keypad and the character picker',
     ['plate_keypad/lib/src/plate_keypad.dart', 'plate_keypad/lib/src/plate_character_picker.dart']),
]


def phases():
    out = [('S1', 'export + vectors'), ('A0', 'web architecture: analysis + plan (your review)'),
           ('A1', 'retrofit existing ports to WEB_ARCH.md')]
    for step, title in (('S2', 'model'), ('S3', 'render + ui + keypad'), ('S4', 'countries')):
        out += [(f'{step}.{l}', f'{title} · {NAMES[l]}') for l in LANGS]
    out.append(('W1', 'registry + embed protocol'))
    out += [(f'S5.{l}', f'embed shell + per-country builds · {NAMES[l]}') for l in LANGS]
    return out + [('W2', 'deferred Dart packages + gallery iframe host'), ('W3', 'Flutter per-country builds'),
                  ('W4', 'deploy + performance budget'), ('W5', 'SEO: skeleton, loading pages, sitemap')]


# Tasks of an earlier plan, dropped at seed time unless already done.
RETIRED = [f's5.{l}.holder' for l in LANGS]


def claude(tid, phase, title, template, deps=(), lang='', verify=None, priority=0, **vars):
    return {'id': tid, 'phase': phase, 'lang': lang, 'kind': 'claude', 'title': title, 'deps': list(deps),
            'priority': priority,
            'payload': {'template': template, 'vars': {'lang': lang, 'lang_name': NAMES.get(lang, ''), **vars},
                        'verify': verify}}


def python(tid, phase, title, fn, deps=(), lang='', **args):
    return {'id': tid, 'phase': phase, 'lang': lang, 'kind': 'python', 'title': title, 'deps': list(deps),
            'payload': {'fn': fn, 'args': args}}


def static_tasks():
    t = [claude('s1.export', 'S1', 'Dart exporter: specs/alphabets/countries/themes -> JSON', 's1_export'),
         claude('s1.vectors', 'S1', 'Dart conformance vectors (D9)', 's1_vectors', deps=['s1.export']),
         python('s1.run', 'S1', 'run exporter and vector tool', 'run_s1', deps=['s1.vectors']),
         python('s1.check', 'S1', 'check JSON and vectors', 'check_s1', deps=['s1.run'])]
    for l in LANGS:
        p = f'S2.{l}'
        t.append(claude(f's2.{l}.setup', p, f'{NAMES[l]} project scaffold + portctl.json', 's2_setup', lang=l,
                        verify='all'))
        prev = f's2.{l}.setup'
        for key, what, files in CORE_PARTS:
            t.append(claude(f's2.{l}.{key}', p, f'core · {what}', 's2_core', deps=[prev], lang=l,
                            verify='all', part=key, what=what, files=files))
            prev = f's2.{l}.{key}'
        t.append(python(f's2.{l}.audit', p, 'expand TODO audit', 'expand_audit', deps=[prev], lang=l,
                        files=[f for _, _, fs in CORE_PARTS for f in fs]))
    for l in LANGS:
        p = f'S3.{l}'
        prev = []
        for key, what, files in UI_PARTS:
            t.append(claude(f's3.{l}.{key}', p, what, 's3_part', deps=prev, lang=l, verify='all',
                            part=key, what=what, files=files))
            prev = [f's3.{l}.{key}']
        t.append(python(f's3.{l}.audit', p, 'expand TODO audit', 'expand_audit', deps=prev, lang=l,
                        files=[f for _, _, fs in UI_PARTS for f in fs]))
    for l in LANGS:
        p = f'S4.{l}'
        t += [claude(f's4.{l}.codegen', p, 'codegen: ports/data JSON -> country sources', 's4_codegen',
                     lang=l, verify='all'),
              python(f's4.{l}.generate', p, 'run codegen for every country', 'run_codegen',
                     deps=[f's4.{l}.codegen'], lang=l),
              python(f's4.{l}.units', p, 'expand D4-code units', 'expand_units',
                     deps=[f's4.{l}.generate'], lang=l)]
    t += [claude('a0.arch', 'A0', 'analyse gallery + ports, propose WEB_ARCH.md (no code)', 'a0_arch',
                 verify={'fn': 'check_arch'}),
          python('a1.expand', 'A1', 'one retrofit task per port that already exists', 'expand_retrofit'),
          claude('w1.protocol', 'W1', 'registry generator, schema, protocol + vectors, TS reference client',
                 'w1_protocol', verify={'cmd': 'python3 ports/web/registry.py --self-test'})]
    for l in LANGS:
        p = f'S5.{l}'
        t += [claude(f's5.{l}.embed', p, 'one-country embed shell speaking the protocol', 's5_embed',
                     lang=l, verify='all'),
              claude(f's5.{l}.build', p, 'web_build / web_build_all into deploy/', 's5_build',
                     deps=[f's5.{l}.embed'], lang=l, verify={'fn': 'web_smoke'})]
    flutter = 'cd plate_number_holder && flutter analyze --no-pub && flutter test --no-pub'
    t += [claude('w2.deferred', 'W2', 'gallery loads each *_plate package only when needed (deferred)',
                 'w2_deferred', verify={'cmd': flutter}),
          claude('w2.host', 'W2', 'iframe host + registry-driven language tabs in the gallery', 'w2_host',
                 deps=['w2.deferred'], verify={'cmd': flutter}),
          claude('w3.flutter', 'W3', 'every *_plate as its own Flutter web build', 'w3_flutter',
                 verify={'cmd': f'python3 ports/web/registry.py --check && {flutter}'}),
          claude('w4.deploy', 'W4', 'deploy.py + perf_check.py', 'w4_deploy',
                 verify={'cmd': 'python3 tools/web/perf_check.py'}),
          claude('w5.seo', 'W5', 'SEO text in the HTML skeleton and loading pages, static route pages, sitemap',
                 'w5_seo', deps=['w4.deploy'], verify={'cmd': 'python3 tools/web/seo_check.py'})]
    return t


def seed(store):
    for i, (pid, title) in enumerate(phases()):
        store.x('insert into phases(id, ord, title) values(?,?,?) '
                'on conflict(id) do update set ord=excluded.ord, title=excluded.title', pid, i, title)
    # Static tasks not yet done take the current payload (prompt vars, verify), so plan fixes reach them.
    for t in static_tasks():
        store.x("update tasks set payload=?, title=?, deps=? where id=? and status not in ('done', 'skipped')",
                json.dumps(t['payload']), t['title'], json.dumps(t['deps']), t['id'])
    for tid in RETIRED:
        store.x("delete from tasks where id=? and status not in ('done', 'skipped')", tid)
    for t in static_tasks():
        store.add_task(t)
    baseline(store)


def baseline(store):
    """Marks the claude tasks (and a1 retrofits) a language finished outside portctl as done."""
    tasks = static_tasks()
    for lang, last in DONE_THROUGH.items():
        ids = [t['id'] for t in tasks if t['lang'] == lang and t['kind'] == 'claude' and t['phase'][:2] in ('S2', 'S3', 'S4')]
        for tid in ids[:ids.index(last) + 1] + ([f'a1.{lang}.retrofit'] if lang != 'kt' else []):
            store.x("update tasks set status='done', route='baseline' where id=? and status in ('pending', 'failed')", tid)


# ---- facts the expanders read -------------------------------------------------------------

def lang_contract(lang):
    """ports/<lang>/portctl.json, written by the S2 setup task: commands and unit paths."""
    p = PORTS / lang / 'portctl.json'
    return json.loads(p.read_text()) if p.exists() else {}


def todos(path, lang):
    """(line index, text) of every TODO(<lang>) in a Dart file, and the declaration it sits on."""
    lines = Path(path).read_text(encoding='utf8').split('\n')
    out = []
    for i, l in enumerate(lines):
        m = re.search(rf'TODO\({lang}\):\s*(.*)', l)
        if not m: continue
        j = i + 1
        while j < len(lines) and re.match(r'\s*(//|@)', lines[j]): j += 1
        decl = lines[j].strip() if j < len(lines) else ''
        out.append((i, m.group(1), decl))
    return out


def units():
    """Every country Dart file holding [D4-code] logic, as (package, file, family)."""
    out = []
    for f in sorted(ROOT.glob('*_plate/lib/**/*.dart')):
        s = f.read_text(encoding='utf8')
        if 'TODO(ts): [D4-code]' not in s: continue
        fam = 'validator' if re.search(r'extends (Gated)?PlateValidator', s) else 'resolver'
        out.append((f.relative_to(ROOT).parts[0], str(f.relative_to(ROOT)), fam))
    return out
