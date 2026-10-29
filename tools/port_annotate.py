"""Insert port TODO lines above a declaration's doc comment (claude/port/ROADMAP.md).

    python3 tools/port_annotate.py notes.py

notes.py defines NOTES = [(file, anchor, [line, ...])]: anchor is a substring of
the declaration line (first match wins), each line is the comment text without
the leading `// `. Lines over 110 characters are refused.
"""
import runpy
import sys

by_file = {}
for f, anchor, lines in runpy.run_path(sys.argv[1])['NOTES']:
    by_file.setdefault(f, []).append((anchor, lines))
for f, items in by_file.items():
    src = open(f).read().split('\n')
    for anchor, lines in items:
        idx = next((i for i, l in enumerate(src) if anchor in l), None)
        if idx is None:
            sys.exit(f'{f}: anchor not found: {anchor}')
        indent = src[idx][: len(src[idx]) - len(src[idx].lstrip())]
        j = idx
        while j > 0 and src[j - 1].strip().startswith(('///', '@')):
            j -= 1
        new = [f'{indent}// {l}' for l in lines]
        for text in new:
            if len(text) > 110:
                sys.exit(f'{f}: {len(text)} chars: {text}')
        src[j:j] = new
    open(f, 'w').write('\n'.join(src))
