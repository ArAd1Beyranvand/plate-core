"""Asks a small Ollama model, per country in plate_number_holder, whether the
country's Wikipedia plate page lists region/state/city codes (a table or a rule).

Run: python3 tools/region_code_scanner/scanner_gui.py

The index page and every country page are cached under cache/, so Wikipedia is
fetched once; delete the cache dir to refetch. Results go to out/results.json.
"""
import json
import queue
import re
import threading
import tkinter as tk
import urllib.parse
import urllib.request
from html.parser import HTMLParser
from pathlib import Path
from tkinter import ttk

import regions

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[1]
CACHE = HERE / 'cache'
OUT = HERE / 'out' / 'results.json'
INDEX_URL = 'https://en.wikipedia.org/wiki/Vehicle_registration_plate'
# Wikipedia rejects requests without a descriptive User-Agent.
UA = 'plate-region-code-scanner/1.0 (local research tool)'
DEFAULT_MODEL = 'qwen3.5:0.8b'
ENDPOINT = 'http://localhost:11434'
# A 0.8b model loses the thread on long input; only the most relevant
# sections are sent, up to this many characters.
MAX_CHARS = 7000
KEYWORDS = re.compile(
    r'\b(codes?|coded|regions?|regional|states?|provinces?|provincial|districts?|cit(?:y|ies)|count(?:y|ies)|'
    r'prefectures?|governorates?|departments?|municipalit(?:y|ies)|oblasts?|krais?|okrugs?|raions?|'
    r'cantons?|voivodeships?|counties|shires?|parish(?:es)?|emirates?|wilayas?|wilayats?|vilayets?|'
    r'velayats?|aimags?|aimaks?|marzes?|mintaqas?|muhafazas?|baladiyas?|dzongkhags?|'
    r'territor(?:y|ies)|divisions?|subdivisions?|sub-districts?|zones?|sectors?|circles?|arrondissements?|'
    r'communes?|cercles?|localit(?:y|ies)|towns?|capitals?|islands?|atolls?|boroughs?|'
    r'areas?|locations?|origin|registered in|place of registration|registration (?:office|authority|district)|'
    r'RTO|licensing authority|issuing (?:office|authority)|'
    r'prefix(?:es)?|suffix(?:es)?|identif(?:y|ies|ier|ying)|denot(?:e|es|ing)|indicat(?:e|es|ing)|'
    r'represent(?:s|ing)?|stands? for|allocated|assigned|series)\b', re.I)

SCHEMA = {
    'type': 'object',
    'properties': {
        'has_region_codes': {'type': 'boolean'},
        'kind': {'type': 'string', 'enum': ['table', 'rule', 'both', 'none']},
        'region_level': {'type': 'string'},
        'evidence': {'type': 'string'},
    },
    'required': ['has_region_codes', 'kind', 'region_level', 'evidence'],
}

PROMPT = """You read part of the Wikipedia article about vehicle registration plates of {country}.

Question: does the article say which part of the plate number identifies a region
(state, province, district, city, county, governorate, etc.)? That counts if there is
a TABLE mapping codes to regions, or a RULE such as "the first two letters show the
province" or "digits 1-2 are the district number".

Answer JSON:
- has_region_codes: true or false
- kind: "table", "rule", "both" or "none"
- region_level: what the code identifies (e.g. "province", "city"), or "" if none
- evidence: one short quote or example from the text, or "" if none

Detected tables whose header mentions codes/regions: {n_tables}

Article excerpt:
{text}
"""


# ---------------------------------------------------------------- fetching

def fetch(url):
    CACHE.mkdir(exist_ok=True)
    name = urllib.parse.unquote(url.rsplit('/', 1)[-1]).replace('/', '_') + '.html'
    path = CACHE / name
    if path.exists():
        return path.read_text(encoding='utf-8'), True
    req = urllib.request.Request(url, headers={'User-Agent': UA})
    with urllib.request.urlopen(req, timeout=60) as r:
        html = r.read().decode('utf-8', 'replace')
    path.write_text(html, encoding='utf-8')
    return html, False


def norm(name):
    name = urllib.parse.unquote(name).lower().replace('-', '_').replace(' ', '_')
    return re.sub(r'^the_', '', name)


def country_pages(index_html):
    """{normalized country: url} from the index page's links."""
    pages = {}
    for m in re.finditer(r'href="(?:https://en\.wikipedia\.org)?/wiki/Vehicle_registration_plates_of_([^"#?]+)"',
                         index_html):
        pages.setdefault(norm(m.group(1)), 'https://en.wikipedia.org/wiki/Vehicle_registration_plates_of_' + m.group(1))
    return pages


def holder_countries():
    text = (REPO / 'plate_number_holder' / 'pubspec.yaml').read_text()
    seen = []
    for m in re.finditer(r'^  ([a-z_]+)_plate:\s*$', text, re.M):
        if m.group(1) not in seen:
            seen.append(m.group(1))
    return seen


# ---------------------------------------------------------------- page text

class _Extractor(HTMLParser):
    """Article body as sections of lines; table rows become 'a | b | c'."""
    SKIP = {'style', 'script', 'sup', 'math'}

    def __init__(self):
        super().__init__()
        self.sections = [['(intro)', []]]
        self.buf, self.row, self.cell = [], None, None
        self.skip = 0
        self.heading = False
        self.tables = []  # header text of each table
        self.table_depth = 0
        self.first_row_of_table = False
        self.grids = []  # every table as {'section', 'rows': [[cell, ...]]}
        self.grid_stack = []
        self.spans = []  # per open table: {column: [rows left, text]} from rowspan

    def handle_starttag(self, tag, attrs):
        if tag in self.SKIP:
            self.skip += 1
        elif tag in ('h2', 'h3', 'h4'):
            self._flush()
            self.heading = True
        elif tag == 'table':
            self._flush()
            self.table_depth += 1
            self.first_row_of_table = True
            self.grids.append({'section': self.sections[-1][0], 'rows': []})
            self.grid_stack.append(self.grids[-1])
            self.spans.append({})
        elif tag == 'tr':
            self.row = []
        elif tag in ('td', 'th'):
            self.cell = []
            a = dict(attrs)
            self.cell_span = (_int(a.get('rowspan')), _int(a.get('colspan')))
        elif tag == 'br' and self.cell is not None:
            self.cell.append(' / ')
        elif tag in ('p', 'li', 'br', 'div'):
            self._flush()

    def handle_endtag(self, tag):
        if tag in self.SKIP:
            self.skip = max(0, self.skip - 1)
        elif tag in ('h2', 'h3', 'h4'):
            title = ' '.join(''.join(self.buf).split()).replace('[edit]', '')
            self.buf = []
            self.heading = False
            self.sections.append([title, []])
        elif tag in ('td', 'th') and self.cell is not None and self.row is not None:
            text = ' '.join(''.join(self.cell).split()).strip(' /')
            rowspan, colspan = self.cell_span
            for _ in range(colspan):
                self._fill_spans()
                if rowspan > 1 and self.spans:
                    self.spans[-1][len(self.row)] = [rowspan - 1, text]
                self.row.append(text)
            self.cell = None
        elif tag == 'tr' and self.row is not None:
            self._fill_spans()
            if self.grid_stack and any(self.row):
                self.grid_stack[-1]['rows'].append(self.row)
            line = ' | '.join(c for c in self.row if c)
            if line:
                self.sections[-1][1].append(line)
                if self.first_row_of_table:
                    self.tables.append(line)
            self.first_row_of_table = False
            self.row = None
        elif tag == 'table':
            self.table_depth = max(0, self.table_depth - 1)
            if self.grid_stack:
                self.grid_stack.pop()
                self.spans.pop()
        elif tag in ('p', 'li'):
            self._flush()

    def handle_data(self, data):
        if self.skip:
            return
        (self.cell if self.cell is not None else self.buf).append(data)

    def _fill_spans(self):
        """Insert cells carried down by a rowspan from earlier rows."""
        if not self.spans:
            return
        spans = self.spans[-1]
        while len(self.row) in spans:
            col = len(self.row)
            left, text = spans[col]
            self.row.append(text)
            if left <= 1:
                del spans[col]
            else:
                spans[col][0] = left - 1

    def _flush(self):
        line = ' '.join(''.join(self.buf).split())
        if line and not self.heading:
            self.sections[-1][1].append(line)
        if not self.heading:
            self.buf = []


def _int(v):
    try:
        return max(1, int(v))
    except (TypeError, ValueError):
        return 1


STOP_SECTIONS = re.compile(r'^(see also|references|external links|notes|further reading|sources)', re.I)


def page_text(html):
    start = html.find('class="mw-content-ltr mw-parser-output"')
    if start < 0:
        start = html.find('mw-parser-output')
    end = html.find('id="catlinks"')
    p = _Extractor()
    p.feed(html[max(start, 0):end if end > 0 else None])
    sections = [(t, ls) for t, ls in p.sections if ls and not STOP_SECTIONS.match(t)]
    code_tables = [h for h in p.tables if KEYWORDS.search(h)]
    grids = [g for g in p.grids if len(g['rows']) >= 2 and not STOP_SECTIONS.match(g['section'])]
    return sections, code_tables, grids


def excerpt(sections):
    """Keyword-dense sections first, each capped, until MAX_CHARS."""
    scored = []
    for i, (title, lines) in enumerate(sections):
        body = '\n'.join(lines)
        score = len(KEYWORDS.findall(title)) * 5 + len(KEYWORDS.findall(body)) + (3 if i == 0 else 0)
        scored.append((score, i, title, body))
    picked, used = [], 0
    for score, i, title, body in sorted(scored, key=lambda s: (-s[0], s[1])):
        if used >= MAX_CHARS:
            break
        chunk = f'## {title}\n{body[:2500]}'
        picked.append((i, chunk[:MAX_CHARS - used]))
        used += len(picked[-1][1])
    return '\n\n'.join(c for _, c in sorted(picked))


# ---------------------------------------------------------------- model

def list_models():
    with urllib.request.urlopen(ENDPOINT + '/api/tags', timeout=5) as r:
        return sorted(m['name'] for m in json.load(r).get('models', []))


def ask(model, country, text, n_tables):
    return _chat(model, PROMPT.format(country=country, text=text, n_tables=n_tables), SCHEMA)


def _chat(model, prompt, schema):
    body = {
        'model': model, 'stream': False, 'format': schema, 'think': False,
        'messages': [{'role': 'user', 'content': prompt}],
        'options': {'num_ctx': 8192, 'temperature': 0},
    }
    req = urllib.request.Request(ENDPOINT + '/api/chat', data=json.dumps(body).encode(),
                                 headers={'Content-Type': 'application/json'})
    with urllib.request.urlopen(req, timeout=600) as r:
        return json.loads(json.load(r)['message']['content'])


# ---------------------------------------------------------------- GUI

class App:
    COLS = ('country', 'page', 'tables', 'answer', 'kind', 'level', 'evidence')

    def __init__(self, root):
        self.root = root
        root.title('Region code scanner')
        root.geometry('1250x720')
        self.events = queue.Queue()
        self.stop = threading.Event()
        self.results = json.loads(OUT.read_text()) if OUT.exists() else {}

        bar = ttk.Frame(root, padding=6)
        bar.pack(fill='x')
        ttk.Label(bar, text='Model').pack(side='left')
        self.model = tk.StringVar(value=DEFAULT_MODEL)
        try:
            models = list_models()
        except OSError:
            models = [DEFAULT_MODEL]
        ttk.Combobox(bar, textvariable=self.model, values=models, width=24).pack(side='left', padx=4)
        self.only_missing = tk.BooleanVar(value=True)
        ttk.Checkbutton(bar, text='Skip countries already answered', variable=self.only_missing).pack(side='left', padx=8)
        self.extract = tk.BooleanVar(value=True)
        ttk.Checkbutton(bar, text=f'Cut region sections with {regions.MODEL}',
                        variable=self.extract).pack(side='left', padx=8)
        self.run_btn = ttk.Button(bar, text='Run all', command=self.run)
        self.run_btn.pack(side='left')
        ttk.Button(bar, text='Run selected', command=lambda: self.run(selected=True)).pack(side='left', padx=4)
        ttk.Button(bar, text='Cut regions (selected)',
                   command=lambda: self.run(selected=True, extract_only=True)).pack(side='left')
        ttk.Button(bar, text='Stop', command=self.stop.set).pack(side='left')
        self.status = tk.StringVar(value='idle')
        ttk.Label(bar, textvariable=self.status).pack(side='left', padx=12)

        pane = ttk.PanedWindow(root, orient='vertical')
        pane.pack(fill='both', expand=True)
        frame = ttk.Frame(pane)
        self.tree = ttk.Treeview(frame, columns=self.COLS, show='headings')
        widths = (170, 60, 55, 70, 60, 110, 650)
        for col, w in zip(self.COLS, widths):
            self.tree.heading(col, text=col)
            self.tree.column(col, width=w, stretch=col == 'evidence')
        sb = ttk.Scrollbar(frame, command=self.tree.yview)
        self.tree.configure(yscrollcommand=sb.set)
        self.tree.pack(side='left', fill='both', expand=True)
        sb.pack(side='right', fill='y')
        self.tree.tag_configure('yes', background='#dff5df')
        self.tree.tag_configure('no', background='#f7e1e1')
        self.tree.tag_configure('missing', foreground='#888')
        self.tree.bind('<<TreeviewSelect>>', self.show_detail)
        pane.add(frame, weight=3)

        self.log = tk.Text(pane, height=12, wrap='word')
        pane.add(self.log, weight=1)

        self.countries = holder_countries()
        for c in self.countries:
            self.tree.insert('', 'end', iid=c, values=(c,))
            if c in self.results:
                self.update_row(c, self.results[c])
        root.after(100, self.drain)

    def update_row(self, c, r):
        a = r.get('answer') or {}
        has = a.get('has_region_codes')
        self.tree.item(c, values=(c, 'yes' if r.get('url') else 'NONE', r.get('code_tables', ''),
                                  {True: 'YES', False: 'no'}.get(has, r.get('error', '')),
                                  a.get('kind', ''), a.get('region_level', ''), a.get('evidence', '')),
                       tags=('yes',) if has else ('no',) if has is False else ('missing',))

    def show_detail(self, _):
        sel = self.tree.selection()
        if sel and sel[0] in self.results:
            r = self.results[sel[0]]
            self.log.delete('1.0', 'end')
            self.log.insert('end', f"{r.get('url', 'no Wikipedia page found')}\n"
                                   f"code-like table headers: {r.get('table_headers', [])}\n"
                                   f"region sections -> {regions.REGIONS / (sel[0] + '.html')}: {r.get('region_sections')}\n\n"
                                   f"{json.dumps(r.get('answer'), indent=2, ensure_ascii=False)}\n")

    def run(self, selected=False, extract_only=False):
        targets = list(self.tree.selection()) if selected else self.countries
        if not selected and self.only_missing.get():
            targets = [c for c in targets if not (self.results.get(c) or {}).get('answer')]
        self.stop.clear()
        self.run_btn.state(['disabled'])
        threading.Thread(target=self.work, args=(targets, self.model.get(), extract_only, self.extract.get()),
                         daemon=True).start()

    def emit(self, *ev):
        self.events.put(ev)

    def work(self, targets, model, extract_only, extract):
        try:
            index, cached = fetch(INDEX_URL)
            pages = country_pages(index)
            self.emit('log', f'index {"from cache" if cached else "downloaded"}: {len(pages)} country pages')
            for n, c in enumerate(targets, 1):
                if self.stop.is_set():
                    self.emit('log', 'stopped')
                    break
                self.emit('status', f'{n}/{len(targets)} {c}')
                url = pages.get(norm(c))
                r = dict(self.results.get(c) or {}) if extract_only else {}
                r['url'] = url
                if not url:
                    r['error'] = 'no page'
                    self.emit('log', f'{c}: no "Vehicle registration plates of" link on the index page')
                    self.emit('result', c, r)
                    continue
                try:
                    html, cached = fetch(url)
                    sections, tables, grids = page_text(html)
                    name = c.replace('_', ' ').title()
                    if not extract_only:
                        text = excerpt(sections)
                        r['code_tables'] = len(tables)
                        r['table_headers'] = tables[:10]
                        self.emit('log', f'{c}: page {"cached" if cached else "fetched"}, {len(text)} chars sent, '
                                         f'{len(tables)} code-like tables; asking {model}')
                        r['answer'] = ask(model, name, text, len(tables))
                    a = r.get('answer') or {}
                    if extract_only or extract:
                        self.emit('log', f'{c}: asking {regions.MODEL} about each section of the raw HTML')
                        r['region_sections'] = regions.extract(name, c, html, log=lambda m: self.emit('log', m))
                        self.emit('log', f'{c}: {len(r["region_sections"])} sections -> {regions.REGIONS / (c + ".html")}')
                except Exception as e:
                    r['error'] = type(e).__name__
                    self.emit('log', f'{c}: {e!r}')
                self.emit('result', c, r)
        except Exception as e:
            self.emit('log', f'failed: {e!r}')
        self.emit('done')

    def drain(self):
        while not self.events.empty():
            kind, *args = self.events.get()
            if kind == 'log':
                self.log.insert('end', args[0] + '\n')
                self.log.see('end')
            elif kind == 'status':
                self.status.set(args[0])
            elif kind == 'result':
                c, r = args
                self.results[c] = r
                OUT.parent.mkdir(exist_ok=True)
                OUT.write_text(json.dumps(self.results, indent=2, ensure_ascii=False))
                self.update_row(c, r)
            elif kind == 'done':
                self.status.set('idle')
                self.run_btn.state(['!disabled'])
        self.root.after(100, self.drain)


if __name__ == '__main__':
    root = tk.Tk()
    App(root)
    root.mainloop()
