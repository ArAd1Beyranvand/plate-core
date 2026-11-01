// web_check: runs the `plates` package inside Pyodide (the browser's CPython) under node.
// Mounts plates/, tests/specs.py and ports/data, renders one plate to SVG through plates.ui.
import { readdirSync, readFileSync, statSync } from 'node:fs';
import { dirname, join, relative } from 'node:path';
import { loadPyodide } from 'pyodide';

const PY = new URL('..', import.meta.url).pathname;
const PORTS = join(PY, '..');
const py = await loadPyodide();

function mount(dir, keep = () => true) {
  for (const name of readdirSync(dir)) {
    const p = join(dir, name);
    if (name === '__pycache__' || name === 'node_modules') continue;
    const target = '/app/' + relative(PORTS, p);
    if (statSync(p).isDirectory()) { py.FS.mkdirTree(target); mount(p, keep); }
    else if (keep(name)) { py.FS.mkdirTree(dirname(target)); py.FS.writeFile(target, readFileSync(p)); }
  }
}
py.FS.mkdirTree('/app/py/tests');
mount(join(PY, 'plates'), (n) => n.endsWith('.py'));
for (const f of ['__init__.py', 'specs.py']) py.FS.writeFile('/app/py/tests/' + f, readFileSync(join(PY, 'tests', f)));
py.FS.mkdirTree('/app/data');
mount(join(PORTS, 'data'), (n) => n.endsWith('.json'));

const out = await py.runPythonAsync(`
import sys
sys.path.insert(0, '/app/py')
from plates.core.input.plate_controller import PlateController
from plates.ui.plate_canvas import PlateView
from tests.specs import spec_of
c = PlateController(spec_of('albania_plate', 'al.private').spec)
c.set_values(['AB', '123', 'FG'])
svg = PlateView(c).svg()
assert svg.startswith('<svg') and '>A</text>' in svg, svg[:200]
assert 'PySide6' not in sys.modules
f"{sys.version.split()[0]} · {len(svg)} chars of svg"
`);
console.log(`pyodide ok · python ${out}`);
