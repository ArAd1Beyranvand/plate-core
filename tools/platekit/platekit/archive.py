"""The before data, kept outside the repo for other frameworks.

`.plateref/<code>/` is scratch: rerunning `before` overwrites it and it is
gitignored. Each run is copied to `$PLATEKIT_ARCHIVE/<code>/<timestamp>/`
(default `~/platekit-archive`), never into the country's package, with a
`manifest.json` naming each file so a JS or any other port can read the
facts, measurements, flats and icons without Python or Flutter.
"""
from __future__ import annotations

import json
import os
import shutil
import time
from pathlib import Path

# what a port needs; zone crops and corner sheets are debugging aids
KEEP = ('facts.json', 'photos.json', 'brief.md', 'sheet_flat.png', 'art.html',
        'size_conflict.json', 'orig_*', 'flat_*.png', 'icons/*')


def root() -> Path:
    return Path(os.environ.get('PLATEKIT_ARCHIVE', Path.home() / 'platekit-archive')).expanduser()


def save(work: Path) -> Path:
    dest = root() / work.name / time.strftime('%Y%m%d-%H%M%S')
    files = []
    for pattern in KEEP:
        for f in sorted(work.glob(pattern)):
            if f.is_file():
                target = dest / f.relative_to(work)
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(f, target)
                files.append(str(f.relative_to(work)))
    facts = json.loads((work / 'facts.json').read_text()) if (work / 'facts.json').exists() else {}
    (dest / 'manifest.json').write_text(json.dumps({
        'country': facts.get('country'), 'code': work.name, 'source': facts.get('source'),
        'size_mm': facts.get('size_mm'), 'created': time.strftime('%Y-%m-%dT%H:%M:%S'),
        'files': files,
    }, ensure_ascii=False, indent=1))
    latest = dest.parent / 'latest'
    if latest.is_symlink() or latest.exists():
        latest.unlink()
    latest.symlink_to(dest.name)
    return dest
