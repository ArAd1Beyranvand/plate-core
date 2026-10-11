"""Headless runner: python3 analyzer_cli.py --country iran --model qwen3:14b

Shares analyzer/core.py with the GUI. Cached unit results in out/units are
reused unless --redo is given.
"""

import argparse
import sys

from analyzer import core


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--country', action='append', help='repeatable; default: all')
    ap.add_argument('--model', help='Ollama model name (see --list-models)')
    ap.add_argument('--endpoint', default=core.Settings.endpoint)
    ap.add_argument('--num-ctx', type=int, default=core.Settings.num_ctx)
    ap.add_argument('--temperature', type=float, default=core.Settings.temperature)
    ap.add_argument('--think', action='store_true')
    ap.add_argument('--retries', type=int, default=core.Settings.retries)
    ap.add_argument('--skip-done', action='store_true', help='skip countries that already have a report')
    ap.add_argument('--redo', action='store_true', help='discard cached unit results first')
    ap.add_argument('--rebuild', action='store_true', help='rerun registry + Dart dump + prepass first')
    ap.add_argument('--list-models', action='store_true')
    ap.add_argument('--quiet', action='store_true', help='do not stream tokens')
    a = ap.parse_args()

    if a.list_models:
        print('\n'.join(core.list_models(a.endpoint)))
        return 0
    sink = core.Sink()
    if a.quiet:
        sink.token = lambda t: None
    if a.rebuild and not core.rebuild(sink):
        return 1
    if not a.model:
        ap.error('--model is required (try --list-models)')
    settings = core.Settings(endpoint=a.endpoint, model=a.model, num_ctx=a.num_ctx,
                             temperature=a.temperature, think=a.think, retries=a.retries)
    todo = a.country or core.countries()
    failed = 0
    for c in todo:
        if a.skip_done and core.report_status(c) is not None:
            print(f'[{c}] skipped: report exists')
            continue
        if a.redo:
            core.reset_country(c)
        failed += core.run_country(c, settings, sink)
    return 1 if failed else 0


if __name__ == '__main__':
    sys.exit(main())
