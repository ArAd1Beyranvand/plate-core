"""The Python web components (Pyodide runtime, shared core, one zip per country) built into deploy/."""
import sys

from .util import ROOT, Sh

BUILD = ROOT / "plate_core/python/web/build.py"


def build(sh, pkgs=None):
    """Builds the pages for `pkgs` (package names), or for every country when None. Returns the exit code."""
    arg = "--all" if not pkgs else ",".join(p.removesuffix("_plate") for p in pkgs)
    code, _ = sh.run([sys.executable, str(BUILD), arg], BUILD.parent, timeout=3600)
    return code
