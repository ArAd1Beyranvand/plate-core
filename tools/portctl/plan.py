"""The task graph: phases in the agreed order, their static tasks, and the expanders that add
tasks at run time (TODO audits, country units) once the facts they need exist."""
import json, re
from pathlib import Path

from config import ROOT, PORTS, LANGS

NAMES = {'ts': 'TypeScript', 'kt': 'Kotlin', 'py': 'Python'}

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
     ['../../plate_keypad/lib/src/plate_keypad.dart', '../../plate_keypad/lib/src/plate_character_picker.dart']),
]


def phases():
    out = [('S1', 'export + vectors')]
    for step, title in (('S2', 'model'), ('S3', 'render + ui + keypad'), ('S4', 'countries'), ('S5', 'holder')):
        out += [(f'{step}.{l}', f'{title} · {NAMES[l]}') for l in LANGS]
    return out


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
    for l in LANGS:
        t.append(claude(f's5.{l}.holder', f'S5.{l}', 'holder app (ROADMAP "Holder spec")', 's5_holder',
                        lang=l, verify='all'))
    return t


def seed(store):
    for i, (pid, title) in enumerate(phases()):
        store.x('insert or ignore into phases(id, ord, title) values(?,?,?)', pid, i, title)
    for t in static_tasks():
        store.add_task(t)


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
