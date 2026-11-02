## Unreleased

- The series (1–3 digits) and the government number (1–6 digits) are single
  variable fields; each digit run is one slot. Values are one string per field:
  `['131', '2180']`.
- Removed the `seriesDigits` and `numberDigits` parameters and `seriesLengths`:
  `TunisiaPlates.standard`, `square` and `government` are now fields, not
  methods.

## 0.1.0

First pub.dev release.
