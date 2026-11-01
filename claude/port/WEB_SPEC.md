# Web spec: one central gallery, independent component builds, lazy iframes

The user's requirements, verbatim in substance. `WEB_ARCH.md` (written by portctl task `a0.arch`)
turns them into decisions W1…Wn; once approved those are binding like ROADMAP D1–D10.

## 1. Background
Interactive license plate input + display components for many countries, in Flutter (Dart), Python,
Kotlin and TypeScript. ~240 Flutter packages. The existing website is a fully interactive Flutter Web
gallery (`plate_number_holder`).

## 2. Main change
No separate galleries per language. ONE central gallery: the existing Flutter gallery stays the main
app (not discarded, not rewritten). It owns navigation, country selection, language selection,
component selection, component information, a consistent UX, and hosts the demos. The component
implementations are built and loaded independently.

## 3. Independent web builds + lazy-loaded iframes
Each plate component is an independent web app. On e.g. `platexample.ir/#/plates/germany` the user
picks Flutter / Python / Kotlin / TypeScript. Flutter shows via the existing mechanism; the others load
their independent build into an iframe **only when selected**; switching language replaces it. The
gallery knows only where builds are deployed, not their internals.

## 4. Build every component independently
Today all Flutter plate components are compiled into one app. New: every country × language
(Germany/Flutter, Germany/Python, … India/TypeScript …) is independently buildable and deployable.
Two levels of lazy loading:
- Level 1, language: Python/Kotlin/TypeScript code is not downloaded until that language is selected.
- Level 2, component: opening Germany/Python downloads no other country's code.

## 5. Keep the existing Flutter gallery
Preserve navigation, country pages, interactive demos, UI/design and components. The gallery may use
HTML/JS where needed for iframes and messaging. No rewrite in HTML/TS.

## 6. Structure (conceptual, not mandatory)
gallery/(flutter_gallery: navigation, country_pages, language_selector, iframe_host; component_registry/
components.json), implementations/{flutter,python,kotlin,typescript}/<country>/, deployment/.
What matters: independent builds and deployments.

## 7. Component registry
Central registry: per country, per language `{available, url}` (e.g. `/components/germany/python/`).
The gallery derives its language tabs and iframe URL from it. Missing implementations must be supported.

## 8. Iframe communication
Fully interactive components. Standard messaging, e.g. `window.postMessage()`: gallery → initial
config; component → loading status; component → content changed; gallery → component actions;
component → errors. Consider sizing, responsive layout, loading indicators, error handling, sandbox
permissions, origin validation. Must feel like one website.

## 9. Performance
Light initial load; no download of other languages or unrelated countries; independent caching per
component; update one component without rebuilding the gallery; deploy a new language without
modifying the gallery. Homepage downloads no component app. Germany + Python loads only Germany/Python.

## 10. Process
Before implementing: (1) examine the existing gallery; (2) how country pages and components are
imported/rendered; (3) the Python/Kotlin/TypeScript work done or planned; (4) what of it is reusable as
independent component apps; (5) best architecture for independent builds + iframe integration;
(6) technical limits, especially Python and Kotlin in browsers; (7) independent build/deploy without
duplicating code; (8) migration that preserves the gallery and breaks nothing.
Do not rewrite the gallery, delete existing work, or create extra standalone galleries. Goal: one
gallery able to show hundreds or thousands of interactive components in several languages, loading
only the one the user wants.
