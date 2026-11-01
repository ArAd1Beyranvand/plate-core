{{> _common}}

## Task {{task}}: the gallery loads Dart plate packages only when needed

Implement WEB_ARCH.md W14 in `plate_number_holder`. Today every `*_plate` package and every
`screens/gallery/sources/<country>.dart` is imported eagerly through `sources/sources.dart`, so the
homepage downloads all of them. Change it so each country's Dart code is a deferred library:

- Split what the homepage, search and country lists need (name, flag, regions, counts, short strings)
  into eager metadata, generated from the sources by a script in `tools/web/` (`gen_deferred.py` or a
  Dart tool) so it cannot drift. Generate `lib/newdesign/data/deferred_sources.g.dart`: one
  `import '…/<country>.dart' deferred as <country>;` per country and a `Future<GallerySource>
  loadSource(String slug)` that calls `loadLibrary()` once and caches the result.
- Every place that builds plates (country page, region page, playground, previews in lists and the
  hero) awaits `loadSource` first, with a skeleton in the gallery's style while loading and an error
  plus retry state on failure. Lists load only the countries they show.
- No eager import of any `*_plate` package or country source may remain outside deferred libraries.
  Add a test that greps `lib/` for that, and unit tests for the loader (cache, unknown slug).
- Behaviour and visuals are unchanged once loaded. Routes (W12) keep working on a cold deep link.

Run `flutter analyze` and `flutter test` and leave both green. Then `flutter build web --release` and
report the size of `main.dart.js` before and after, plus the number of `*.part.js` files.
