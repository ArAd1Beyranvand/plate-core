# portctl: splitting the port between Python, local qwen and Claude Code

Goal: TypeScript, Kotlin and Python versions of `plate_core`, `plate_alphabet`, `plate_keypad`, the
country packages and a small holder per language — an input + display plate. Built from the Dart, with
the work spread so Claude spends tokens only where judgement is needed.

## The three workers and what they are good at

| Worker | Cost | Speed here (CPU, no GPU) | Use it for |
|---|---|---|---|
| **python** | free | instant | anything deterministic: run tools, codegen from JSON, tests, context packing, diff/stat, error compaction |
| **qwen** (ollama) | free | 4b: 51 tok/s in, 16 out · 9b: 23 in, 9 out | *small, checkable* units: one validator, one resolver, a TODO audit answer. Context ≤ ~1.5k tokens, output ≤ ~500 |
| **claude** (you, in Claude Code) | $ | fast | architecture, a language's core, render/UI, codegen scripts, the **first units of every family** (exemplars), units qwen failed |

Two rules follow from the table:

1. **qwen never works without an oracle.** Every qwen output is compiled and run against the D9
   vectors before it counts. A wrong answer costs CPU time, never correctness.
2. **qwen never works without an exemplar.** The first unit of every family (e.g. "country validator →
   TypeScript") goes to Claude. Its accepted Dart→target pair becomes the few-shot example for every
   later qwen unit of that family. Claude sets the style, and qwen copies it.

## Phase order (yours)

```
S1 export+vectors
S2.ts model   S2.kt model   S2.py model
S3.ts render+ui+keypad   S3.kt …   S3.py …
S4.ts countries          S4.kt …   S4.py …
S5.ts holder             S5.kt …   S5.py …
```

Phases run strictly in this order. Each ends with a **gate**: you approve in the GUI, or turn on
auto-approve. A phase is done when all of its tasks are done or skipped.

## What each phase becomes

- **S1** (claude ×2, python ×2): Claude writes `plate_number_holder/test/port_export_test.dart` (the
  holder already depends on every country; every spec/alphabet/country/theme → `ports/data/`,
  `[D4-table]` resolvers tabulated by enumerating their finite key domain) and
  `port_vectors_test.dart` (D9 vectors → `ports/vectors/`, one file per validator class). Python runs
  both with `flutter test --no-pub` and checks the output (it parses, every package has data, and
  every validator class has vectors).
- **S2.<lang>** (claude ×5, qwen audits, python verify): the core split into five Claude tasks —
  geometry/values, alphabet+slot+spec, layout+restriction+validation, controller+input machine,
  animation timing. Each is verified by its slice of the vectors. Then a **qwen TODO audit**: every
  `TODO(<lang>)` in the Dart files that task covered becomes one yes/no question ("does this target
  code honour this note?"), answered by qwen 4b from a ~1k-token context that Python cuts out. Every
  "no" goes into a single Claude fix-list task.
- **S3.<lang>** (claude ×3 + audits): render (display list, D1), ui (painter + inputs + animation),
  keypad. Then the same audit and fix-list loop.
- **S4.<lang>** (claude ×1, python ×1, qwen ×N): Claude writes the codegen (JSON → source). Python runs it
  for all 182 packages. That covers the bulk of the country code with no LLM at all. Then every
  `[D4-code]` validator or resolver is a **unit**: Claude does the first two (the exemplars), qwen the rest.
- **S5.<lang>** (claude ×1): the holder from `ROADMAP.md` "Holder spec".

## The router (the dynamic part)

For a qwen-eligible unit, in order:

1. Forced route from the GUI → use it.
2. No exemplar yet for (family, lang) → **claude**, and the result becomes the exemplar.
3. Estimated qwen time = prompt tokens / in-rate + max output / out-rate. Above `qwen_max_seconds` →
   **claude** (a big unit is cheaper in Claude than three slow CPU attempts).
4. Family statistics: after `family_min_samples` units, if qwen's success rate in the family is below
   `family_min_success` → **claude** for the rest of the family. Rates are measured, not assumed.
5. Otherwise the **qwen ladder**: 4b first try → 9b with the oracle's compacted error → 9b again → escalate.

Escalated units are not sent one by one. The **escalation batcher** packs up to `claude_batch` failed
units of the same family into one Claude task, with each unit's Dart, qwen's last attempt and its
compacted error. One Claude session repairs eight units, so its startup and repo-reading cost is paid
once per batch instead of once per unit. Each unit is then verified separately.

Measured in-rates and out-rates come from every ollama call (exponential moving average), so the
estimate follows the machine.

## Context packing (python, deterministic)

A qwen prompt is assembled, never summarised by a model:

- the unit's Dart source, cut out by brace matching
- its `TODO(<lang>)` lines
- the `ROADMAP.md` entries those TODOs cite (`[H9]` → the H9 paragraph only)
- the exemplar pair
- the target path and file contract
- on a retry, the oracle's error, compacted to the first error and its source lines (≤ 30 lines)

Claude prompts are the phase templates in `prompts/`, filled with the same facts. Claude reads the repo
itself.

## State

Everything lives in SQLite (`claude/port/portctl.db`): tasks, dependencies, every attempt (prompt,
output, oracle log, seconds, tokens, cost) and every event. The app can be killed at any moment.
On restart, a running task goes back to pending. The Dart TODOs and the vectors are the only
contract between phases.

## GUI

Black, dense, fully verbose. On the left, phases with gate state and the task list, filterable. In the
centre, the live stream of the selected task (python grey, qwen cyan, claude amber), plus the exact
prompt, every attempt and the oracle output. On the right, lane status, measured qwen rates, Claude
spend, success rate per family, and the router's decision log with its reason. Controls: start, pause,
step once, approve gate, retry, skip, force route.

## Claude is manual by default

`CLAUDE_MODE = 'manual'` in `config.py`. A Claude task does not run `claude -p`. portctl writes its
prompt, with a suggested model and effort, to the **Handoffs** tab and to `claude/port/handoffs/<task>.r<n>.md`,
and waits (`awaiting`). You copy it into Claude Code, run it, and press **Done**. portctl then
verifies the work: the whole oracle for phase tasks, or the unit's test for units. If that is green, the task is
done. If it is red, you get a short follow-up fix prompt (round n+1, at most `MANUAL_ROUNDS`). Several
handoffs can wait at once whenever the task graph allows.

Suggested model and effort (`HINTS` in `config.py`, and `engine.hint()` for the dynamic cases):

| prompt | model · effort | why |
|---|---|---|
| s1 export, s1 vectors, s4 codegen | opus · high | everything downstream depends on them |
| core alphabet / layout / input, render, ui | opus · high | hazards H21/H9/D7/D1: subtle and cross-cutting |
| core values / timing, setup | sonnet · medium | mechanical |
| keypad, holder | sonnet · high | sizeable but well specified |
| unit exemplar | opus · medium | sets the style that qwen copies 200+ times |
| unit forced to Claude | haiku · medium | small, and the test decides |
| fix list ≤ 6 items / more | haiku · medium / sonnet · medium | |
| repair batch | sonnet · low | the code is small; the errors are given |
| oracle fix round | the task's model · medium | |

`CLAUDE_MODE = 'auto'` restores the `claude -p` worker (stream-parsed, budgeted, and resuming the same
session on fix rounds).

## Running it

```
python3 tools/portctl/portctl.py            # GUI
python3 tools/portctl/portctl.py --headless --auto   # terminal, gates auto-approved
python3 tools/portctl/portctl.py --reset    # start over (deletes claude/port/portctl.db)
python3 tools/portctl/portctl.py --done s2.ts.setup   # headless: you ran that handoff
```

Needs `ollama serve` with the models in `config.py`, the `claude` CLI logged in, and PySide6. Thresholds,
models, budget and oracle defaults are all in `config.py`. Each language's real commands come from
`ports/<lang>/portctl.json`, which its S2 setup task writes.

Files: `plan.py` (task graph), `engine.py` (gates, lanes, router, ladder, batcher, handlers),
`executors.py` (shell, python task functions, ollama, claude), `context.py` (prompt packing),
`store.py` (SQLite), `gui.py`, `prompts/*.md`.
