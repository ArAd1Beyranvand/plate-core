---
name: plref
description: Refactor a plate package for meaning — trim redundant comments, merge duplicated logic, use modern Dart, make code and docs read as expert. Usage /plref <package>
---

Refactor one plate package (`$ARGUMENTS`, e.g. `plate_core`). Read every file in `lib/` first, then edit. Priority order: **meaning**, then duplication, then brevity.

## 1. Comments: delete, don't rewrite
- Keep only constraints, invariants, and design rationale (why a raster cache, why two layers, why an ordering matters). Delete anything the signature or code already says.
- Delete doc comments that restate the member name (`/// The focused slot.` on `focusedSlot`), and class docs that list the fields.
- Collapse multi-paragraph essays to the one fact a maintainer would otherwise break. Keep the rationale, drop the narration.
- No country names in `plate_core`, even in comments. Describe by property ("a gapped register"), not by example.
- No process words: "now", "previously", "we", "as discussed", phase/ticket numbers.
- Public API docs: one summary sentence, then only what is non-obvious (nullability, ordering, units, who owns what).
- Prefer present-tense, third-person, concrete nouns. Drop hedges ("basically", "simply", "just").

## 2. Duplication: find the shared shape
- Same traversal written twice (tree walks, leaf/divider lookups) becomes one method on the owning type (e.g. `PlateSection.layout`).
- Several write paths ending in the same validate, store, notify sequence become one private `_store`.
- Paired near-identical methods (sync A / sync B) become one helper with a parameter.
- Repeated casts or fallbacks (`as ValueNotifier<…>`, mirror-alphabet fallback) get one named helper.
- Same widget constructed in two branches differs only by data: build the data in the branch, construct once.
- Repeated TextStyle or box construction becomes one private class or const.
- Trivial wrappers that only forward (`_resolveInputSource`) are inlined.

## 3. Modern Dart
- `firstOrNull`, `indexed`, records for multi-value returns, collection `for`/`if`, pattern matching and switch expressions, `final x = field;` for promotion, `??=`, null-aware elements, dot-shorthand where the SDK allows it.
- Replace manual loops with `every`/`any`/`fold` only when it reads shorter and clearer.
- `show` clauses on exports so the public surface is deliberate; alphabetize export blocks.

## 4. Structure (project CLAUDE.md rules still apply)
- No functions returning widgets, including local closures (`Widget text(String v) => …`, `Widget buildFace(theme) {…}`). Turn each into a private `StatelessWidget`/`StatefulWidget` with named parameters (e.g. `_Face`, `_LabelText`, `_SlotBox`). Only a `builder:` callback a Flutter API demands is allowed, and its body should just construct a widget class. Grep: `grep -rnE "(Widget|Positioned|SizedBox|Text)\s+_?[a-z]\w*\(" lib | grep -v "Widget build("`.
- A stateful wrapper may pass through when its feature is absent (e.g. `_Livery` returns `builder(base)` with no resolver) so the caller builds one tree, not two.
- Variation is data. Fixed-canvas layout, with no `LayoutBuilder`, `Expanded`, `AspectRatio`, `MediaQuery` inside plates. Report violations (such as `CountryPanel`'s `LayoutBuilder`) rather than silently rewriting them if it changes behaviour.
- Keep public API and behaviour identical. If a refactor changes behaviour, stop and report.

## 5. Procedure
1. `git status` must be clean. Work in the package's own repo.
2. Read all files, list findings, then edit file by file.
3. `dart format lib`, `flutter analyze --no-pub` (clean), `flutter test --no-pub`. Compare against the baseline failures recorded before you started; any new failure is yours.
4. Commit in the package repo with the co-author trailer and net line counts.
5. Report: lines removed, pre-existing failing tests, rule conflicts found but not changed.

## 6. Don'ts
- Don't touch files outside the named package, and don't edit tests to make a refactor pass.
- Don't rename public symbols without being asked.
- Don't add comments to compensate for unclear code; rename or restructure.
