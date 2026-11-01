{{> _common}}

## Task {{task}}: Flutter components as independent builds

Following the Flutter decision in WEB_ARCH.md, make every `*_plate` package buildable as its own web
component in `deploy/components/<country>/flutter/`. It speaks the same protocol as the other
languages, so a Dart embed shell implements `ports/web/protocol.md`. Prefer one generic shell app
with a per-country generated `main` (or `--dart-define`) over 180 hand-made apps. CanvasKit/skwasm
and the shared engine assets come from one shared path, not one copy per country.

Then switch the gallery's Flutter tab to the iframe only where the registry says a Flutter build
exists, keeping the in-app widget (a deferred library, W14) as the fallback. The gallery keeps its
plate packages (W9); do not remove them from `pubspec.yaml`. The embed shell imports only its own
country's package. Add `flutter` to `ports/web/registry.py`'s scan.
Provide `tools/web/build_flutter.py <country>|--all|--changed`. Build germany and india, regenerate
the registry, and leave `flutter test` in `plate_number_holder` green.
