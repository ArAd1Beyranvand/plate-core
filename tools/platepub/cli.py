"""plateman: status / sync / doctor / init / run / daily / pyweb / gui."""
import argparse
import signal
import sys
import threading

from . import manifests
from .areas import describe
from .engine import Engine, Options
from .registries import EARLY, REGISTRIES
from . import pyweb
from .util import Sh, default_proxy, packages

ALL = ",".join(REGISTRIES)


def regs_arg(s):
    keys = list(REGISTRIES) if s == "all" else EARLY if s == "early" else s.split(",")
    bad = [k for k in keys if k not in REGISTRIES]
    if bad:
        raise argparse.ArgumentTypeError(f"unknown registry {bad}; choose from {ALL}, early, all")
    return list(keys)


def build_parser():
    ap = argparse.ArgumentParser(prog="plateman", description=__doc__)
    sub = ap.add_subparsers(dest="cmd")
    common = argparse.ArgumentParser(add_help=False)
    common.add_argument("pkgs", nargs="*", help="package names or substrings (default: all)")
    common.add_argument("-r", "--reg", type=regs_arg, default=None, metavar="REGS",
                        help=f"comma list of {ALL}; or 'early' (npm,jsr,maven,pypi) / 'all'")
    common.add_argument("--proxy", default=None, help="default: git's http.proxy or $HTTPS_PROXY")

    s = sub.add_parser("status", parents=[common], help="what is published where")
    s.add_argument("--pending", action="store_true", help="only packages missing on some selected registry")
    sub.add_parser("sync", parents=[common], help="ask the registries what is really published")
    sub.add_parser("doctor", parents=[common], help="check tools and credentials")
    i = sub.add_parser("init", parents=[common], help="write missing package.json / jsr.json / pyproject.toml / build.gradle.kts")
    i.add_argument("--force", action="store_true", help="overwrite existing manifests")

    run = argparse.ArgumentParser(add_help=False)
    run.add_argument("--steps", default=None, help="comma list of commit,push,check,publish")
    run.add_argument("--check-mode", choices=("dry-run", "pana", "both"), default="dry-run")
    run.add_argument("--need-full", action="store_true", help="pub.dev: publish only at full pub points")
    run.add_argument("--republish", action="store_true", help="bump the version of already-published units and publish again")
    run.add_argument("-j", "--workers", type=int, default=4)
    run.add_argument("-y", "--yes", action="store_true", help="do not ask before publishing")
    r = sub.add_parser("run", parents=[common, run], help="run steps on packages (default steps: check,publish)")
    r.add_argument("--all", action="store_true", help="include packages already published everywhere")
    r.add_argument("-n", "--dry-run", action="store_true", help="only print the plan")
    d = sub.add_parser("daily", parents=[run], help="publish new pub.dev packages in bursts until the day limit")
    d.add_argument("--reg", default="pubdev", choices=list(REGISTRIES))
    d.add_argument("--batch", type=int, default=4, help="packages per burst")
    d.add_argument("--proxy", default=None)
    sub.add_parser("pyweb", parents=[common], help="build the Python web components into deploy/ (default: every country)")
    sub.add_parser("gui", help="open the dashboard")
    return ap


def pick(args):
    """Resolve package names / substrings given on the command line."""
    allp = packages()
    if not args.pkgs:
        return allp
    out = [p for p in allp if any(p == a or p == f"{a}_plate" or a in p for a in args.pkgs)]
    miss = [a for a in args.pkgs if not any(p == a or p == f"{a}_plate" or a in p for p in allp)]
    if miss:
        sys.exit(f"no package matches: {', '.join(miss)}")
    return out


def confirm(n, regs, yes):
    if yes or not sys.stdin.isatty():
        return yes
    return input(f"{n} unit(s) will be REALLY published to {', '.join(regs)} (irreversible). Type 'yes': ").strip() == "yes"


def table(eng, pkgs, regs, pending):
    head = ["package", "country", "git"] + regs
    rows = []
    for p in pkgs:
        g = eng.state.git(p)
        git = "?" if g.get("dirty") is None else ("dirty" if g["dirty"] else "clean") + (f" ↑{g['unpushed']}" if g.get("unpushed") else "")
        cells = []
        for r in regs:
            if not REGISTRIES[r].present(p):
                cells.append("-")
            elif eng.state.published(p, r):
                cells.append("✔ " + (eng.state.reg(p, r).get("version") or ""))
            else:
                cells.append("·")
        if pending and not any(c == "·" for c in cells):
            continue
        rows.append([p, describe(p)[0] + (f" / {describe(p)[1]}" if describe(p)[1] else ""), git, *cells])
    w = [max(len(str(x[i])) for x in rows + [head]) for i in range(len(head))]
    for row in [head] + rows:
        print("  ".join(str(c).ljust(w[i]) for i, c in enumerate(row)))
    print(f"\n{len(rows)} package(s).  ✔ published   · not yet   - no manifest for that registry")
    for r in regs:
        for used, n, win in eng.quota.used(r):
            print(f"{REGISTRIES[r].label} quota: {used}/{n} new packages in the last {win // 3600 or win // 60}{'h' if win >= 3600 else 'min'}")


def main(argv=None):
    args = build_parser().parse_args(argv)
    if args.cmd in (None, "gui"):
        from .gui import main as gui
        return gui()
    stop = threading.Event()
    signal.signal(signal.SIGINT, lambda *_: (print("\nstopping after the running commands..."), stop.set()))
    eng = Engine(stop=stop)
    proxy = getattr(args, "proxy", None)
    proxy = default_proxy() if proxy is None else proxy

    if args.cmd == "daily":
        o = Options(steps=set((args.steps or "check,publish").split(",")), regs=[args.reg], check_mode=args.check_mode,
                    need_full=args.need_full, republish=False, workers=args.batch, proxy=proxy)
        todo = eng.pending(args.reg)
        print(f"{len(todo)} package(s) pending on {REGISTRIES[args.reg].label}; quota {eng.quota.used(args.reg)}")
        if "publish" in o.steps and todo and not confirm(len(todo), [args.reg], args.yes):
            return print("aborted (pass --yes to skip the question)")
        n, msg = eng.daily(o, args.reg, args.batch, poll=lambda s: None)
        return print(f"Published {n}. {msg}")

    if args.cmd == "pyweb":
        sys.exit(pyweb.build(Sh(print, proxy), pick(args) if args.pkgs else None))
    pkgs = pick(args)
    regs = args.reg or (["pubdev"] if args.cmd == "run" else list(REGISTRIES))
    if args.cmd == "status":
        eng.refresh_git(pkgs)
        return table(eng, pkgs, regs, args.pending)
    if args.cmd == "sync":
        res = eng.sync(regs, pkgs, proxy)
        unreachable = sum(f is None for _, f in res)
        return print(f"Checked {len(res)} unit(s); {unreachable} unreachable." + ("  Is the proxy right?" if unreachable else ""))
    if args.cmd == "doctor":
        sh = Sh(lambda s: None, proxy)
        for r in regs:
            print(f"\n{REGISTRIES[r].label}")
            for what, ok, detail in REGISTRIES[r].doctor(sh):
                print(f"  {'✔' if ok else '✖'} {what:<22} {'' if ok else detail}")
        return
    if args.cmd == "init":
        for p in pkgs:
            for f in manifests.init(p, [r for r in regs if r != "pubdev"], print, args.force):
                print("wrote", f)
        return
    # run
    steps = set((args.steps or "check,publish").split(","))
    o = Options(steps=steps, regs=regs, check_mode=args.check_mode, need_full=args.need_full,
                republish=args.republish, workers=args.workers, proxy=proxy)
    units = eng.units(regs, pkgs)
    if "publish" in steps and not (args.all or args.republish):
        units = [(p, r) for p, r in units if not eng.state.published(p, r)]
    targets = sorted({p for p, _ in units}, key=lambda p: (p != "plate_core", p))
    if not targets:
        return print("Nothing to do: every selected unit is already published (use --all or --republish).")
    print(f"{len(units)} unit(s) in {len(targets)} package(s); steps: {', '.join(sorted(steps))}")
    if args.dry_run:
        for p, r in units:
            print(f"  {p:<34} {r}")
        return
    if "publish" in steps and not confirm(len(units), regs, args.yes):
        return print("aborted (pass --yes to skip the question)")
    eng.refresh_git(targets)
    failed = eng.run(targets, o)
    for p, r, w in eng.deferred:
        print(f"deferred by quota: {p} on {r} (wait {int(w // 60)} min)")
    print(f"Done. {len(failed)} failed: {', '.join(sorted(failed))}" if failed else "Done, no failures.")
    sys.exit(1 if failed else 0)
