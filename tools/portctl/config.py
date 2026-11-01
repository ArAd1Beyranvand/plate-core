"""Paths, models, oracles and router thresholds. Edit here, not in the code."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PORTS = ROOT / 'ports'
DB = ROOT / 'claude' / 'port' / 'portctl.db'
ROADMAP = ROOT / 'claude' / 'port' / 'ROADMAP.md'
PROMPTS = Path(__file__).resolve().parent / 'prompts'

LANGS = ('ts', 'kt', 'py')
# Work finished outside portctl: per language, the last task already done. Everything before it in
# plan order is marked done at seed time (audits and expanders excluded: they must really run).
DONE_THROUGH = {'ts': 's4.ts.codegen', 'py': 's4.py.codegen', 'kt': 's3.kt.render'}

EXT = {'ts': 'ts', 'kt': 'kt', 'py': 'py'}

# portctl starts its own server here with OLLAMA_NUM_PARALLEL, so qwen calls really run side by side.
OLLAMA = 'http://localhost:11435'
OLLAMA_PARALLEL = 3
OLLAMA_SYSTEM = 'http://localhost:11434'   # the system service: used for models the private server lacks
QWEN_SMALL = 'qwen3.5:4b'
QWEN_LARGE = 'qwen3.5-9b:latest'
QWEN_CTX = 8192                # unit median ~500 tokens; prompt with exemplar ~1.6k-3.2k
# Seeds for the rate estimate; replaced by measurements after the first call.
QWEN_RATES = {QWEN_SMALL: (51.0, 16.0), QWEN_LARGE: (23.0, 9.0)}  # (prompt tok/s, output tok/s)

# 'manual': Claude tasks become copiable prompts with a suggested model and effort; you run them in
# Claude Code and press Done, then portctl verifies. 'auto': portctl runs `claude -p` itself.
CLAUDE_MODE = 'manual'
HANDOFFS = ROOT / 'claude' / 'port' / 'handoffs'   # every handed-off prompt is also written here
MANUAL_ROUNDS = 5              # red-oracle fix prompts before a task fails (auto mode: 2)
# Suggested (model, effort) per template, template:part or template:lang. Dynamic cases live in engine.hint().
HINTS = {
    's1_export': ('opus', 'high'), 's1_vectors': ('opus', 'high'),
    's2_setup': ('sonnet', 'medium'),
    's2_core:values': ('sonnet', 'medium'), 's2_core:alphabet': ('opus', 'high'),
    's2_core:layout': ('opus', 'high'), 's2_core:input': ('opus', 'high'), 's2_core:timing': ('sonnet', 'medium'),
    's3_part:render': ('opus', 'high'), 's3_part:ui': ('opus', 'high'), 's3_part:keypad': ('sonnet', 'high'),
    's4_codegen': ('opus', 'high'),
    'a0_arch': ('opus', 'high'),
    'a1_retrofit:ts': ('sonnet', 'high'), 'a1_retrofit:kt': ('opus', 'high'), 'a1_retrofit:py': ('opus', 'high'), 'w1_protocol': ('sonnet', 'high'),
    's5_embed:ts': ('sonnet', 'high'), 's5_embed:kt': ('opus', 'high'), 's5_embed:py': ('opus', 'high'),
    's5_build': ('sonnet', 'medium'),
    'w2_deferred': ('opus', 'high'), 'w2_host': ('opus', 'high'), 'w3_flutter': ('opus', 'high'), 'w4_deploy': ('sonnet', 'high'),
    'w5_seo': ('sonnet', 'high'),
    'repair': ('sonnet', 'low'),
}

CLAUDE = 'claude'
CLAUDE_MODEL = None            # None: the CLI default
CLAUDE_MAX_TURNS = 200
CLAUDE_BUDGET_USD = 15.0       # per task; --max-budget-usd
CLAUDE_TOOLS = ['Read', 'Edit', 'Write', 'Glob', 'Grep',
                'Bash(npm *)', 'Bash(npx *)', 'Bash(node *)', 'Bash(./gradlew *)', 'Bash(gradle *)',
                'Bash(python3 *)', 'Bash(pip *)', 'Bash(pytest *)', 'Bash(dart *)', 'Bash(flutter *)',
                'Bash(git status*)', 'Bash(git diff*)', 'Bash(ls *)', 'Bash(mkdir *)']

# Router.
QWEN_MAX_SECONDS = 600         # estimated time above which a unit goes straight to Claude
QWEN_MAX_OUTPUT = 2400         # num_predict cap; 700 truncated data-heavy units (algeria_validators)
FAMILY_MIN_SAMPLES = 20
FAMILY_MIN_SUCCESS = 0.4
EXEMPLARS_PER_FAMILY = 2
CLAUDE_BATCH = 8               # escalated units per Claude repair task
LADDER = [QWEN_LARGE, QWEN_LARGE, QWEN_LARGE]

# Oracles, run from PORTS/<lang>. {test} is the unit's test file, relative.
ORACLE = {
    'ts': 'npx --no-install vitest run {test} --reporter=dot',
    'kt': './gradlew -q jvmTest --tests {test}',
    'py': 'python3 -m pytest -q -x {test}',
}
ORACLE_ALL = {
    'ts': 'npx --no-install tsc --noEmit && npx --no-install vitest run --reporter=dot',
    'kt': './gradlew -q check',
    'py': 'python3 -m pytest -q',
}
ORACLE_TIMEOUT = 600
