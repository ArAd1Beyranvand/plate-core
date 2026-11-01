{{> _common}}

## Task {{task}}: iframe host in the Flutter gallery

Change `plate_number_holder` minimally, following WEB_ARCH.md "Migration". Today's pages and the
in-app Flutter demos must keep working unchanged.

- Load `components/index.json` lazily (once, on the first country page, not on the homepage) and derive
  each country's language tabs from it. Hide or disable missing languages. With no registry at all,
  the gallery behaves exactly as today.
- Flutter tab: the existing in-app widget, for now.
- Other tabs: an iframe host widget (`package:web` + `HtmlElementView`) created only when the tab is
  selected and replaced on switch. It sets the sandbox and `allow` flags and checks message origins
  per protocol.md. It shows a skeleton only until `hello` (the component's own splash takes over, W11), a retry state on error or timeout, and
  auto-heights from `resize` messages, styled like the rest of the gallery.
- Routes per W12: `/plates/<country>` and `/plates/<country>/<lang>` (e.g. `/plates/germany/python`) as
  route parameters in `newdesign/app/location.dart`. Unknown or unbuilt languages fall back to the
  country page, old `#/plates/<country>` links still work, and switching tabs updates the route.
- Put the host and protocol code in their own folder (e.g. `lib/newdesign/embed/`) with unit tests
  for message parsing against `ports/web/protocol_vectors.json`.

Run `flutter analyze` and `flutter test` in `plate_number_holder` and leave both green. Run
`flutter build web` and confirm that the homepage requests no component URL.
