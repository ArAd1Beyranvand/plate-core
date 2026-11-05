#!/usr/bin/env python3
"""Plate package manager: commit / push / check / publish the *_plate packages to pub.dev, npm, JSR,
Maven Central and PyPI. Dashboard with no arguments, CLI otherwise (`package_manager.py --help`).

State lives in tools/package_state.json, logs in tools/manager_logs/, check reports in reports/.
"""
import sys

from platepub.cli import main

if __name__ == "__main__":
    sys.exit(main())
