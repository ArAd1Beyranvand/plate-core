"""The local model: ollama, JSON-constrained, for yes/no questions only.

Measured on the Laos private plate: qwen3.5:4b answered the layout
booleans correctly (one text row above the serial, no badge, Lao script)
in 26 s, and named the field "yellow" where the pixels say FFAF00 amber.
So it gets questions whose answers are categories, never numbers or
colours; those come from `vision`. Every answer is checked against the
schema in the prompt file and anything malformed counts as "unknown".
"""
from __future__ import annotations

import base64
import contextlib
import fcntl
import time
import json
import os
import urllib.request
from pathlib import Path

from platekit import progress

OLLAMA = 'http://127.0.0.1:11434/api/generate'
PROMPTS = Path(__file__).resolve().parent.parent / 'prompts'
VISION_MODEL = 'qwen3.5:4b'
TEXT_MODEL = 'qwen3.5:0.8b'

# Simple tasks go to the small model; everything else to the big one.
# "zone" is one cropped region, pick-one-of-six: 0.8b answers it in about
# the time 4b does with much less memory. Whole-plate layout and the
# two-plate comparison stay on 4b. Override with PLATEKIT_SMALL / PLATEKIT_BIG.
SMALL_TASKS = {'zone'}


def model_for(task: str) -> str:
    if task in SMALL_TASKS:
        return os.environ.get('PLATEKIT_SMALL') or TEXT_MODEL
    return os.environ.get('PLATEKIT_BIG') or VISION_MODEL


def available() -> bool:
    try:
        urllib.request.urlopen('http://127.0.0.1:11434/api/tags', timeout=2)
        return True
    except Exception:
        return False


class _Log:
    """Streams the model's thinking and answer as `│ ` lines; the GUI routes
    those to its log pane, keeping them out of the step cards."""

    def __init__(self):
        self.kind, self.buf = '', ''

    def line(self, text: str):
        print('│ ollama  ' + text, flush=True)

    def feed(self, kind: str, text: str):
        if kind != self.kind:
            self.flush()
            self.kind = kind
        self.buf += text
        while '\n' in self.buf or len(self.buf) > 100:
            cut = self.buf.find('\n')
            cut = cut if 0 <= cut <= 100 else 100
            self.line(f'{self.kind:<7} ' + self.buf[:cut])
            self.buf = self.buf[cut + 1 if self.buf[cut:cut + 1] == '\n' else cut:]

    def flush(self):
        if self.buf.strip():
            self.line(f'{self.kind:<7} ' + self.buf)
        self.buf = ''


def load_prompt(name: str) -> tuple[str, dict]:
    """`prompts/<name>.md`: the prompt, then a ```json schema block."""
    text = (PROMPTS / f'{name}.md').read_text()
    body, _, rest = text.partition('```json')
    schema = json.loads(rest.split('```', 1)[0])
    return body.strip(), schema


@contextlib.contextmanager
def _one_at_a_time(log: '_Log'):
    """One request to ollama at a time across every pk process. Two GUI tabs
    asking at once made ollama swap 0.8b and 4b in and out until a request
    timed out; a file lock makes the second tab wait its turn instead."""
    with open('/tmp/platekit_ollama.lock', 'w') as f:
        try:
            fcntl.flock(f, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            log.line('waiting for another platekit run to finish with ollama')
            progress.task('waiting for ollama (another tab is using it)', 0, None, force=True)
            fcntl.flock(f, fcntl.LOCK_EX)
        yield


def ask(prompt: str, schema: dict, *, images: list[Path] = (), model: str | None = None,
        timeout: int = 900, num_ctx: int | None = None) -> dict:
    think = os.environ.get('PLATEKIT_THINK') == '1'
    payload = {
        'model': model or (os.environ.get('PLATEKIT_BIG') or VISION_MODEL if images
                           else os.environ.get('PLATEKIT_SMALL') or TEXT_MODEL),
        'prompt': prompt,
        'format': schema,
        'stream': True,
        'think': think,
        'options': {'temperature': 0, **({'num_ctx': num_ctx} if num_ctx else {})},
    }
    if images:
        payload['images'] = [base64.b64encode(Path(p).read_bytes()).decode() for p in images]
    req = urllib.request.Request(OLLAMA, json.dumps(payload).encode(),
                                 {'Content-Type': 'application/json'})
    log = _Log()
    log.line(f"model {payload['model']} · think {think} · images {[Path(p).name for p in images]}")
    for ln in prompt.splitlines():
        log.line('prompt  ' + ln)
    raw = thought = ''
    tokens, t0 = 0, time.monotonic()
    progress.task(f"ollama {payload['model']} · loading / reading the prompt", 0, None, force=True)
    with _one_at_a_time(log), urllib.request.urlopen(req, timeout=timeout) as r:
        for chunk in r:  # one JSON object per line
            msg = json.loads(chunk)
            if msg.get('thinking') or msg.get('response'):
                tokens += 1
                progress.task(f"ollama {payload['model']} · {'thinking' if msg.get('thinking') else 'answering'}"
                              f" · {time.monotonic() - t0:.0f}s", tokens, None, 'tok')
            elif not tokens:
                progress.task(f"ollama {payload['model']} · loading / reading the prompt"
                              f" · {time.monotonic() - t0:.0f}s", 0, None)
            if msg.get('thinking'):
                thought += msg['thinking']
                log.feed('think', msg['thinking'])
            if msg.get('response'):
                raw += msg['response']
                log.feed('answer', msg['response'])
            if msg.get('done'):
                log.flush()
                log.line(f"done in {msg.get('total_duration', 0) / 1e9:.1f}s · "
                         f"{msg.get('eval_count', '?')} tokens")
    if not raw.strip():
        # with think on, some models put the constrained JSON in `thinking`
        raw = thought[thought.find('{'):thought.rfind('}') + 1]
    try:
        answer = json.loads(raw)
    except json.JSONDecodeError:
        return {k: 'unknown' for k in schema.get('properties', {})}
    return _validate(answer, schema)


def _validate(answer: dict, schema: dict) -> dict:
    out = {}
    for k, spec in schema.get('properties', {}).items():
        v = answer.get(k, 'unknown')
        if 'enum' in spec and v not in spec['enum']:
            v = 'unknown'
        if spec.get('type') == 'boolean' and not isinstance(v, bool):
            v = 'unknown'
        if spec.get('type') == 'integer' and not isinstance(v, int):
            v = 'unknown'
        if spec.get('type') == 'array':
            item = spec.get('items', {})
            want = {'integer': int, 'string': str}.get(item.get('type'), object)
            # a bad item becomes 'unknown' rather than dropped: `fields` and
            # `field_lengths` are read position by position
            v = [x if isinstance(x, want) and x in item.get('enum', [x]) else 'unknown'
                 for x in v] if isinstance(v, list) else []
        out[k] = v
    return out


def ask_named(name: str, images: list[Path] = (), model: str | None = None,
              num_ctx: int | None = None, **fill) -> dict:
    prompt, schema = load_prompt(name)
    return ask(prompt.format(**fill) if fill else prompt, schema, images=images,
               model=model or model_for(name), num_ctx=num_ctx)
