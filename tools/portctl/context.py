"""Deterministic context packing: templates, ROADMAP entries, Dart cuts, compacted errors.
Nothing here calls a model."""
import re
from config import ROADMAP, PROMPTS, ROOT


def render(template, **vars):
    """Fills {{name}} in prompts/<template>.md; {{> other}} includes another template."""
    s = (PROMPTS / f'{template}.md').read_text(encoding='utf8')
    s = re.sub(r'\{\{>\s*(\w+)\s*\}\}', lambda m: render(m.group(1), **vars), s)
    def sub(m):
        v = vars.get(m.group(1), '')
        return '\n'.join(map(str, v)) if isinstance(v, (list, tuple)) else str(v)
    return re.sub(r'\{\{(\w+)\}\}', sub, s)


_roadmap = None


def roadmap_entry(tag):
    """The paragraph of ROADMAP.md for an id like H9 or D4 (D4-table -> D4)."""
    global _roadmap
    if _roadmap is None:
        _roadmap = {}
        cur = None
        for line in ROADMAP.read_text(encoding='utf8').split('\n'):
            m = re.match(r'- \*\*([DH]\d+)\b', line)
            if m: cur = m.group(1); _roadmap[cur] = [line]
            elif cur and line.startswith('  '): _roadmap[cur].append(line)
            else: cur = None
    return '\n'.join(_roadmap.get(tag.split('-')[0], []))


def cited(texts, skip=()):
    ids = list(skip)
    for t in texts:
        for i in re.findall(r'\[?([DH]\d+)(?:-\w+)?\]?', t):
            if i not in ids: ids.append(i)
    return '\n'.join(filter(None, (roadmap_entry(i) for i in ids[len(skip):])))


def dart_block(lines, i):
    """Lines from i to the end of the declaration starting there (brace/paren matching)."""
    depth, started, out = 0, False, []
    for l in lines[i:]:
        out.append(l)
        code = re.sub(r"//.*|'[^']*'|\"[^\"]*\"", '', l)
        depth += code.count('{') + code.count('(') - code.count('}') - code.count(')')
        started |= any(c in code for c in '{(')
        if started and depth <= 0 and code.rstrip().endswith((';', '}')): break
        if not started and code.rstrip().endswith(';'): break
    return '\n'.join(out)


def compact_error(log, limit=30):
    """First failure of a compiler / test log and the lines right after it. qwen's context is
    expensive (CPU prompt eval), so a 2000-line Gradle log becomes ~30 lines."""
    lines = [l for l in log.splitlines() if l.strip()]
    pat = re.compile(r'error|Error|FAIL|failed|Expected|expected|AssertionError|Traceback|e: |TS\d{4}')
    for i, l in enumerate(lines):
        if pat.search(l):
            return '\n'.join(lines[max(0, i - 2):i + limit])
    return '\n'.join(lines[-limit:])


def tokens(text):
    """Rough token count (no tokenizer for qwen here): ~3.5 characters per token for code."""
    return int(len(text) / 3.5) + 1


def read(rel):
    return (ROOT / rel).read_text(encoding='utf8')
