## Unreleased

- Each field (prefix, number, suffix) is one `PlateSlot` with a `length` instead of one slot per character. A value is one string per slot: `['AB', '1234', 'MD']`.
- `MaliValidator` gated on a `serial` group no spec has, so it never ran; it now waits for the `suffix` and checks the 2-4-2 lengths.

## 0.1.0

First pub.dev release.
