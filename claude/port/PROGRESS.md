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
