# WEB_ARCH: one gallery, independent component builds, lazy iframes

Answer to `WEB_SPEC.md`. W-decisions are binding for every port task once this phase's gate is
approved, like ROADMAP D1–D10. Drafts: `web/components.schema.json`, `web/protocol.md`.

## Current gallery

- `plate_number_holder` is the gallery. Entry `lib/main.dart` → `newdesign/app/pd_app.dart`. The hash
  URL strategy (`app/url_strategy/url_strategy_web.dart`) lets any static host serve deep links.
  `lib/minimal` and `lib/screens` are the older shells.
- Routes (`newdesign/app/location.dart:13-15`): `/plates/:region`, `/plates/:country` (CountryPage),
  `/plates/:country/:spec` (Playground). Slugs come from `newdesign/data/catalogue.dart` (`slug`).
- Country → widget: every country is a `GallerySource` in `screens/gallery/sources/<country>.dart`
  (e.g. `germany.dart`, which imports `package:germany_plate`), listed in `sources.dart`
  (`gallerySources`, `allGallerySources:681`). Each source lists `GalleryEntry`s (spec, validator,
  sample values). Pages render entries through two widgets in `newdesign/plate/live_plate.dart`:
  - `StaticPlate` (:453): previews on the country page (`country_page.dart:420,575`), region page and landing.
  - `LivePlate` (:72): the interactive plate and keypad in the playground (`playground_page.dart:280`)
    and the landing hero.
- `pubspec.yaml` has 215 `*_plate` path dependencies. All of them compile into one `main.dart.js`
  (4.5 MB uncompressed; a `main.dart.wasm` build exists too). Every visitor downloads every country.

## Reuse

- **Flutter**: every `*_plate` package as is. `GalleryEntry` and the sources are the metadata the
  gallery keeps. `LivePlate` + keypad become the body of the Flutter embed shell (W9).
- **Data**: `ports/data` (182 country JSON files plus alphabets, from S1) is the shared source for
  TS/Kotlin/Python codegen (D3) and for the registry's country list.
- **TypeScript** (`ports/ts`): core, render and `src/ui` (`svg.ts`, headless `PlateCanvas`, the
  `<plate-canvas>` element) are already browser code. The embed shell adds an entry, the protocol and the keypad.
- **Python** (`ports/py`): core and render are stdlib-only. `plates.ui` was rewritten from PySide6 to
  `svg.py` + headless `plate_canvas.py` + `dom.py` (DOM inputs over the SVG, the TS model), and
  `web/check.mjs` runs the package in Pyodide 0.28 (CPython 3.13). Green.
- **Kotlin**: nothing ported yet. It starts directly on the web target (W5).
- **Dropped**: the per-language holder apps (old S5) and any per-language gallery.

## Decisions

- **W1 · One gallery.** `plate_number_holder` stays the only site, and stays Flutter.
  Why: it owns navigation, design and SEO-free hash routing already. No second gallery to keep in sync.
- **W2 · Component = country × language, one static folder** `components/<country>/<lang>/index.html`.
  Why: a plain URL is the only contract the gallery needs. Each folder is cacheable and deployable on its own.
- **W3 · Registry is generated, never hand-edited.** `components/index.json` is written by
  `ports/web/registry.py` from what exists under `deploy/components/`. Missing = absent.
  Why: a new language or country deploys without touching the gallery (WEB_SPEC §9).
- **W4 · Lazy at two levels.** The gallery fetches the registry on the first country page, never on
  the homepage, and creates an iframe only when a non-Flutter tab is selected, one at a time.
  Why: the homepage then downloads no component code (WEB_SPEC §4, §9).
- **W5 · Browser targets.** TS: Vite, vanilla TS, SVG + DOM inputs. Python: Pyodide, `plates.ui`
  (SVG + DOM). Kotlin: Kotlin Multiplatform, `jvm` for tests plus **both** `js(IR)` and `wasmJs`, with
  UI as an SVG/DOM painter over the display list in a `webMain` set shared by both, not Compose. The
  Kotlin `index.html` feature-detects WasmGC (`WebAssembly.validate` on a tiny GC module) and loads only
  the Wasm build or only the JS build (user decision).
  Why: one UI model (D1 display list → SVG, inputs at slot boxes) in all three. Compose for Web
  ships ~2–3 MB of Skiko per page for what is an SVG and a few inputs.
- **W6 · Shared runtime + thin country entry.** Each language builds one content-hashed runtime
  (`shared/<lang>/<hash>/`: core, render, ui, keypad, protocol client) and per country only its data
  and `[D4-code]` units. Why: a cache hit on the runtime makes a second country cost a few KB.
- **W7 · Countries never import each other or a global list.** Codegen emits one module per country.
  Any index maps id → lazy import. Why: WEB_SPEC level 2. A one-country build must tree-shake to one country.
- **W8 · One protocol for all languages** (`web/protocol.md`): `postMessage` envelope
  `{ns:"plate-embed", v:1, type, payload}`. The host checks `event.source === iframe.contentWindow`
  and the origin. The component answers only the origin that sent `init`.
  Why: the gallery treats all four languages identically.
- **W9 · Flutter, stepwise; the gallery keeps its plate packages.** Step 1: the Flutter tab keeps
  today's in-app `LivePlate`. Step 2 (W3 phase): a generic Dart embed shell built per country
  (`--dart-define=COUNTRY=…`, generated `main`), CanvasKit from the shared path, as the independent
  Flutter component. Gallery previews (`StaticPlate`) stay Flutter, with no SVG previews.
  Why: the site skeleton is Flutter (user decision). Its size is handled by W14, not by SVG.
- **W14 · Dart plate packages load when needed.** The gallery imports each `*_plate` package and its
  `screens/gallery/sources/<country>.dart` with `deferred as`, behind one generated loader
  (`lib/newdesign/data/deferred_sources.g.dart`: country slug → `loadLibrary()` + source). The eager part
  is only light metadata (names, flags, regions, counts, the strings the homepage and lists need),
  generated from the sources so it cannot drift. A country page, region page, playground or preview
  awaits its country's library (skeleton while loading, cached after) before building `StaticPlate`
  or `LivePlate`. Lists that show many plate previews load only the visible countries' libraries.
  Why: the homepage then downloads the framework plus metadata, not 215 packages, and each country's
  Dart code arrives as its own `main.dart.js_<n>.part.js` like the other languages' components.
- **W10 · One domain, sandboxed.** Every country × language build is deployed on the gallery's own
  domain under `/components/` and downloaded only when the user opens that country in that language.
  `sandbox="allow-scripts allow-same-origin allow-forms"`. Why: no CORS for wasm or assets, one deploy,
  and the code is ours (user decision; no subdomain).
- **W11 · Loading lives in the component's HTML; the host only covers the gap.** Each component's
  `index.html` has an inline splash in plain HTML/CSS (no runtime, gallery look, e.g. "Starting
  Python…") that paints from the first byte and is removed at `ready`. It also works when the component
  is opened on its own. The Flutter host shows a skeleton only until `hello`, then shows the iframe, and
  keeps only the timeout and retry state. Why: only the component knows its runtime's real progress, and
  the host stays language-agnostic. The component may post `progress` `{stage, fraction}`.
- **W12 · The language is a route parameter.** Routes are `/plates/<country>` (Flutter tab) and
  `/plates/<country>/<lang>` with `lang` ∈ registry keys (`flutter`, `typescript`, `kotlin`, `python`),
  parsed in `newdesign/app/location.dart`. An unknown or unbuilt language falls back to the country page.
  Old `#/plates/<country>` links keep working. Switching tabs replaces the route, so back/forward and
  sharing land on the same country and language. Why: one URL per country × language is what users
  share and what search engines index (W13).
- **W13 · SEO lives in static HTML, written naturally.** The gallery's `web/index.html` skeleton
  (title, description, canonical, Open Graph, JSON-LD, a `<noscript>`/pre-boot text block) and every
  component's `index.html` splash (W11) carry real, readable text about that country's plates and that
  language: an `<h1>`, a sentence or two, and the plate format. It reads as the loading page, not as
  keyword stuffing. Per-route static pages (`deploy/plates/<country>/<lang>/index.html`) are generated
  at deploy so crawlers get content without running Flutter. A `sitemap.xml` lists them.

## Registry

`deploy/components/index.json`, schema `web/components.schema.json`:

```json
{ "version": 1, "generated": "2026-10-30T12:00:00Z",
  "components": { "germany": { "typescript": { "url": "/components/germany/typescript/", "hash": "a1b2c3" },
                               "python":     { "url": "/components/germany/python/",     "hash": "d4e5f6" } } } }
```

- Keys are the gallery slugs (`catalogue.dart` `slug`), and languages are `flutter|typescript|kotlin|python`.
- An entry exists only if its `index.html` was built. `hash` busts the iframe URL (`?v=hash`), so the
  registry can be revalidated cheaply while the folders stay immutable.
- About 180 × 4 entries is about 30 KB raw (about 4 KB gzipped). Above about 2,000 countries it shards
  per country (`index/<country>.json`), and the schema already allows that (`shards`).

## Protocol

Full table in `web/protocol.md`. Summary:

| dir | type | payload |
|---|---|---|
| C→H | `hello` | `{lang, country, version}`, sent on boot before init |
| H→C | `init` | `{spec?, values?, theme:"light"\|"dark", locale, keypad:bool}` |
| C→H | `ready` | `{specs:[{id,label}], height}` |
| C→H | `resize` | `{height}`, from a ResizeObserver on the document |
| C→H | `change` | `{spec, values, text, complete, valid}` |
| H→C | `action` | `{name:"setSpec"\|"setValues"\|"clear"\|"focus"\|"setTheme", args}` |
| C→H | `error` | `{code, message, fatal}` |

The host shows a skeleton until `ready`. If no `hello` arrives within 15 s, or after a fatal error,
it shows the retry state. Unknown `type` or `v` are ignored, never thrown.

## Browser limits

- **Python / Pyodide 0.28** (CPython 3.13). Measured here: `pyodide.asm.wasm` 8.6 MB (2.8 MB gzip) +
  `python_stdlib.zip` 2.4 MB + 1.1 MB JS. Load the pinned version from jsDelivr, so it is shared and
  cached across every country and every site using it. Cold start is about 2–4 s on desktop, so the
  host must show a loading state. Pure Python only, with no threads or sockets, which our code
  already respects. The country module is fetched as a small `.py` (or zip) into the FS. Node check:
  boot + import + render about 2.4 s.
- **Kotlin**: both builds ship (W5). Wasm needs WasmGC (Chrome 119+, Firefox 120+, Safari 18.2+),
  and other browsers get JS IR. With per-country DCE expect about 100–300 KB per country for JS.
  Sharing a runtime across separately built bundles is hard, so accept a full bundle per country
  first and measure in S5. Compose is rejected (W5).
- **TypeScript**: no limits. Vite builds the shared runtime as a library chunk, and the country
  entries import it through an import map in each `index.html`.
- **Flutter**: each `flutter build web` is about 1.5–2.5 MB of `main.dart.js` per country (framework
  included, no sharing between apps). CanvasKit (about 7 MB) is shared through the CDN path. 180 builds
  take about 1–2 min each, so builds are incremental (changed packages only) and parallel.
  Deferred imports inside the gallery would cut the gallery's size but not give independent deploys, so
  they are not used for components.
- **iframes**: auto-height via `resize` messages. Keyboard focus stays inside the iframe, and the
  keypad lives in the component, not the host. Both must be hash-routed with no `history` push inside
  the component.

## Build and deploy

```
deploy/
  index.html, main.dart.js …          gallery (built only when lib/ changes)
  shared/{ts,kt,py,flutter}/<hash>/   runtimes, Cache-Control: immutable
  components/index.json               registry, no-cache
  components/<country>/<lang>/        index.html (no-cache) + country assets (hashed, immutable)
```

- Per language, `ports/<lang>/portctl.json` gets `web_build` (`{country}`), `web_build_all`
  (incremental) and `web_out`.
- `tools/web/deploy.py --changed` builds what git says changed: a `*_plate` package → that country's
  flutter component; `ports/data/countries/x.json` → x in every language; `ports/<lang>/src` core →
  that language's runtime only (countries keep pointing at it through the hash in their `index.html`,
  which is rebuilt, but country chunks stay cached).
- No duplication: country code is generated from `ports/data` (D3), and runtimes are built once per language.

## Migration

1. **A1 (now)**: TS gets Vite and a web entry, and Python is already on Pyodide. Every phase keeps
   `oracle_all` green and adds `web_check`.
2. **S2–S4**: as planned, with W5–W7 binding. Codegen emits per-country modules.
3. **W1**: `ports/web/` holds registry.py, schema, protocol, vectors and the TS reference client.
4. **S5**: per-language embed shell + `web_build`. Germany and India build independently.
5. **W2**: deferred Dart packages (W14), then the gallery iframe host. With no registry, or an empty one, the gallery is byte-for-byte today's
   behaviour, so it can ship at any time.
6. **W3**: Flutter per-country builds. The Flutter tab switches to the iframe only where one exists.
7. **W4**: deploy.py + perf_check.py. The homepage fetches no `/components/`.
8. **W5**: SEO (W13): skeleton and splash text, per-route static pages, sitemap, `seo_check.py`.

Every step is additive. Nothing in the gallery is deleted before its replacement is live.

## Open questions

Settled by the user: one domain (W10), Flutter previews kept (W9), the loading splash lives in the
component (W11), and Kotlin ships both JS and Wasm (W5).

1. Preload Pyodide (`<link rel="prefetch">` of the shared runtime) when the user hovers the Python tab?
   It is cheap and cached, but it is a download before a click.
