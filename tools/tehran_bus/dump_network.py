#!/usr/bin/env python3
"""Dump Tehran bus/subway stations, lines and line-station order to JSON + CSV.

Usage: dump_network.py [outdir]
Uses the app's bulk sync endpoint (no auth). The server 500s for serverTime below
a cutoff, so we bisect for the oldest accepted value to get the full tables.
"""
import csv, json, sys, urllib.request, urllib.error
from pathlib import Path

BASE = "https://application2.irantracking.com/modsapi/api/PublicTransport/"
OUT = Path(sys.argv[1] if len(sys.argv) > 1 else "tehran_bus_out")


def call(endpoint, body, timeout=120):
    req = urllib.request.Request(BASE + endpoint, json.dumps(body).encode(),
                                 {"Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            return json.load(r)
    except (urllib.error.HTTPError, TimeoutError, urllib.error.URLError):
        return None


def oldest_sync(endpoint):
    lo, hi = 1_700_000_000_000, 1_750_000_000_000  # lo fails, hi works
    while hi - lo > 1000:
        mid = (lo + hi) // 2
        if call(endpoint, {"serverTime": mid}, 30) is not None:
            hi = mid
        else:
            lo = mid
    return call(endpoint, {"serverTime": hi})


def write(name, rows):
    (OUT / f"{name}.json").write_text(json.dumps(rows, ensure_ascii=False, indent=1))
    if rows:
        keys = sorted({k for r in rows for k in r})
        with open(OUT / f"{name}.csv", "w", newline="", encoding="utf-8-sig") as f:
            w = csv.DictWriter(f, keys)
            w.writeheader()
            w.writerows(rows)


OUT.mkdir(parents=True, exist_ok=True)
for kind, endpoint in (("bus", "LastRoutesStationsUpdate"), ("subway", "SubwayRoutesStations")):
    d = oldest_sync(endpoint)
    if not d:
        print(kind, "failed")
        continue
    for part in ("Routes", "Stations", "RouteStations"):
        write(f"{kind}_{part.lower()}", d.get(part, []))
        print(kind, part, len(d.get(part, [])))
