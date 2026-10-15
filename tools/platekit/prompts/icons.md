### Icons — what to do with them

For every icon **on the plates** above (skip the ones the article says are
not printed, and say which):

1. Open its crop. Name what it is (the national flag, a city's coat of
   arms, the police badge…).
2. Find the vector. Look first in the page SVGs above; else search
   Wikimedia Commons (one API call, not a browser):
   `curl -sG https://commons.wikimedia.org/w/api.php --data-urlencode action=query --data-urlencode list=search --data-urlencode srnamespace=6 --data-urlencode "srsearch=<name> filetype:svg" --data-urlencode format=json`
   then resolve the file's URL with `prop=imageinfo&iiprop=url`. Prefer
   the official/current design; check the result against the crop.
3. Save it in the package: `{package}/assets/icons/<snake_name>.svg`, and
   list it under `flutter: assets:` in the pubspec. Record the Commons
   file page in a comment beside where it is used (licence trail).
4. Place it:
   - a flag in the side band → `PlateCountry.flag` as `SvgPlateAsset`;
   - anything on the face → `PlateDecal`, which takes an `ImageProvider`,
     so also rasterise it (`rsvg-convert -h 256 in.svg -o out.png`) and use
     `AssetImage('assets/icons/<name>.png', package: '{package}')`,
     box = the measured box above.
   A shape an algorithm can draw (stripes, a disc, a cross) is not an icon:
   paint it on the background instead.
5. An icon that varies per plate (a city's crest per registration area)
   is one decal per value, chosen by the spec builder's parameter — do
   not download all of them; do the one in the reference and say so.
