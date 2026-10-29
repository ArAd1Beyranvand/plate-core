# Port pass ledger

Resume from the first line without a commit hash. Format:
`phase · path · shortened: -N lines · todos: py/ts/kt · commits`

- P0 · ROADMAP.md, tools/port_inventory.dart, inventory.csv (C 82, B 99, A 2) · done
- P1 · plate_core/lib/src/widgets/plate_canvas.dart · fix: missing debug_validate_spec import (HEAD did not compile) · core b07cf35
- P1 · plate_core model/theme/validators/drawings · shortened: -36 lines net (specProblems +12) · core ef121e0 a34c4fb fe62282 0444c0e
- P1 · same files · todos: 45/45/45 · core 1d0ca40
- P1 · deferred: PlateFill/PlateSection sealed (no line win, H18 TODOs instead); noPanel → nullable panel (338 files, P8 codemod)
- P2 · plate_core/lib/src/input · shortened: -31 · core 37ce55f
- P2 · same · todos: 19/19/19 · core e7c4b0e
- P2 · deferred: PlateInputMachine pure/focus split (adds a class, no line win; D8 TODOs instead); fromValues kept (used by country golden tests)
- P3 · plate_core/lib/src/animation · shortened: -59 · core 46646c8 e511b62
- P3 · same · todos: 16/16/16 · core 9c1750d
- P4 · plate_core/lib/src/widgets (canvas excluded) · shortened: -9 · core a485a94
- P4 · same · todos: 21/21/21 · core 88451c6
- P4 · plate_canvas.dart · shortened: -21 · core 76a76b7
- P4 · plate_canvas.dart · todos: 18/18/18 · core 4a638be
- P5 · plate_core/test · todos: 11/11/11 (non-vector tests only) · core e8afb5d

- P6 · plate_alphabet · shortened: 0 (no real win; re-export-only `*_alphabets.dart` in ~30 country packages deferred to P8) · todos: 8/8/8 · alphabet 831a265
- P7 · plate_keypad · shortened: 0 (nothing dead or duplicated) · todos: 12/12/12 · keypad 59c9898
- P8 · all 182 country packages (C, then B, then A), 19 batches via claude/port/notes/p8.py · shortened: 0 (see deferred) · todos: 719/719/719 (barrel 182, validator 226, RegExp 156, table resolver 64, raster decal 57, flag asset 25, logic resolver 6, clipper 3) · per-package "todo(countries): batch N", root "batch N, package pointers"
- P8 · deferred: dot shorthands (no `prefer_dot_shorthands` lint in SDK 3.13, saves characters not lines); one canonical file layout and removal of ~30 re-export-only `*_alphabets.dart` (touches every package, needs your OK); noPanel → nullable panel (338 files)
- P8 · note: country golden tests fail on this machine before and after (checked albania, comoros at HEAD~1); not caused by comment-only commits
- P9 · plate_number_holder minimal/main.dart, newdesign/plate/live_plate.dart · todos: 10/10/10 · holder a41c5e2; ROADMAP "Holder spec" written
