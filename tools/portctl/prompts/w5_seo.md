{{> _common}}

## Task {{task}}: SEO in the HTML skeleton and the loading pages

Implement WEB_ARCH.md W12 and W13. Search engines and link previews only see static HTML, so the text
has to be there before any runtime boots. Write it like a person describing the page, never keyword
lists or hidden text. It doubles as what the user reads while the page loads.

- Gallery skeleton `plate_number_holder/web/index.html`: a real `<title>` and meta description,
  canonical, Open Graph/Twitter tags, JSON-LD (`WebSite` + `ItemList` of countries), and a short
  readable pre-boot block (what the site is, a few country links as real `<a href>`) that Flutter
  replaces on start. Keep it small: no extra request on the homepage.
- Every component splash (the W11 `index.html` of each language's embed shell, via its template, so
  every build gets it): `<title>` "<Country> license plates · <Language>", a description, canonical to
  `/plates/<country>/<lang>`, an `<h1>`, one or two sentences about the country's plate format taken from
  `ports/data` (formats, regions, example), and the runtime status line ("Starting Python…"). Text comes
  from data, not hand-written per country.
- Per-route static pages: extend `tools/web/deploy.py` to emit `deploy/plates/<country>/index.html` and
  `deploy/plates/<country>/<lang>/index.html` for every registry entry. Each is the gallery shell with
  that route's title, meta, canonical and pre-boot text, so a crawler gets content and a user lands on
  the right route (W12 path routes). Also emit `sitemap.xml` and `robots.txt`.
- `tools/web/seo_check.py`: for germany and india in every built language, assert a unique title,
  description, canonical, `<h1>`, at least 40 words of visible text, no duplicate descriptions across
  pages, every sitemap URL resolves to a file in `deploy/`, and the homepage still fetches no
  `/components/` URL. Exit non-zero on a failure.

Run deploy for germany and india, then `python3 tools/web/seo_check.py`, and leave it green.
