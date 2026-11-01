"""SQLite state: tasks, attempts, events, phases, exemplars. One connection behind a lock."""
import json, sqlite3, threading, time

SCHEMA = '''
create table if not exists phases(id text primary key, ord int, title text, gate text default 'closed');
create table if not exists tasks(
  id text primary key, phase text, lang text, kind text, family text, title text,
  payload text, deps text, status text default 'pending', route text, forced text,
  priority int default 0, result text, updated real);
create table if not exists attempts(
  id integer primary key, task text, n int, worker text, model text, prompt text, output text,
  oracle text, ok int, seconds real, tok_in int, tok_out int, cost real, t real);
create table if not exists events(id integer primary key, t real, task text, source text, level text, text text);
create table if not exists exemplars(family text, lang text, dart text, target text, primary key(family, lang, dart));
create table if not exists kv(k text primary key, v text);
create index if not exists ev_task on events(task);
create index if not exists at_task on attempts(task);
'''

TASK_COLS = ('id', 'phase', 'lang', 'kind', 'family', 'title', 'payload', 'deps', 'status', 'route',
             'forced', 'priority', 'result', 'updated')


class Store:
    def __init__(self, path, recover=True):
        path.parent.mkdir(parents=True, exist_ok=True)
        self.db = sqlite3.connect(str(path), check_same_thread=False)
        self.db.row_factory = sqlite3.Row
        self.lock = threading.RLock()
        with self.lock:
            self.db.executescript(SCHEMA)
            # A task that was running when the app died starts over (not when a second process,
            # like `--done`, opens the store next to a live one).
            if recover: self.db.execute("update tasks set status='pending' where status='running'")
            self.db.commit()

    def q(self, sql, *args):
        with self.lock:
            return [dict(r) for r in self.db.execute(sql, args).fetchall()]

    def x(self, sql, *args):
        with self.lock:
            cur = self.db.execute(sql, args)
            self.db.commit()
            return cur.lastrowid

    # kv
    def get(self, k, default=None):
        r = self.q('select v from kv where k=?', k)
        return json.loads(r[0]['v']) if r else default

    def put(self, k, v):
        self.x('insert or replace into kv values(?,?)', k, json.dumps(v))

    # tasks
    def add_task(self, t):
        t = {**{'deps': [], 'payload': {}, 'family': '', 'lang': '', 'priority': 0}, **t}
        self.x('insert or ignore into tasks(id,phase,lang,kind,family,title,payload,deps,priority,updated) '
               'values(?,?,?,?,?,?,?,?,?,?)', t['id'], t['phase'], t['lang'], t['kind'], t['family'],
               t['title'], json.dumps(t['payload']), json.dumps(t['deps']), t['priority'], time.time())

    def task(self, tid):
        r = self.q('select * from tasks where id=?', tid)
        return self._decode(r[0]) if r else None

    def tasks(self, where='1', *args):
        return [self._decode(r) for r in self.q(f'select * from tasks where {where} order by rowid', *args)]

    def set_task(self, tid, **kw):
        for k, v in kw.items():
            if k in ('payload', 'result', 'deps'): v = json.dumps(v)
            self.x(f'update tasks set {k}=?, updated=? where id=?', v, time.time(), tid)

    @staticmethod
    def _decode(r):
        for k in ('payload', 'deps', 'result'):
            r[k] = json.loads(r[k]) if r[k] else ({} if k != 'deps' else [])
        return r

    # attempts / events
    def add_attempt(self, **a):
        cols = ','.join(a)
        return self.x(f'insert into attempts({cols},t) values({",".join("?" * len(a))},?)', *a.values(), time.time())

    def attempts(self, tid):
        return self.q('select * from attempts where task=? order by id', tid)

    def event(self, task, source, level, text):
        t = time.time()
        self.x('insert into events(t,task,source,level,text) values(?,?,?,?,?)', t, task, source, level, text)
        return t

    def events(self, task=None, after=0, limit=5000):
        if task:
            return self.q('select * from events where task=? and id>? order by id limit ?', task, after, limit)
        return self.q('select * from events where id>? order by id limit ?', after, limit)

    # exemplars
    def add_exemplar(self, family, lang, dart, target):
        self.x('insert or replace into exemplars values(?,?,?,?)', family, lang, dart, target)

    def exemplars(self, family, lang):
        return self.q('select dart, target from exemplars where family=? and lang=?', family, lang)

    # family stats: qwen success over finished qwen-routed units
    def family_stats(self):
        rows = self.q("select family, lang, route, status from tasks where kind='unit'")
        out = {}
        for r in rows:
            s = out.setdefault((r['family'], r['lang']), {'qwen_ok': 0, 'qwen_tried': 0, 'claude': 0, 'left': 0})
            if r['status'] in ('pending', 'running', 'awaiting'): s['left'] += 1
            elif r['route'] == 'qwen' and r['status'] != 'failed':   # crashes say nothing about qwen's quality
                s['qwen_tried'] += 1; s['qwen_ok'] += r['status'] == 'done'
            elif r['route'] == 'escalated':
                s['qwen_tried'] += 1
            elif r['route'] == 'claude': s['claude'] += 1
        return out
