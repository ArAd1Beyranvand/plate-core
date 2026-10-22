import 'package:flutter/widgets.dart' show EdgeInsets, Offset;
import 'package:plate_alphabet/plate_alphabet.dart';
import 'package:plate_core/plate_core.dart';

import 'collectivity_of_saint_martin_colors.dart';
import 'collectivity_of_saint_martin_country.dart';

/// Where the ink sits, in plate units, measured off the flattened 2009
/// photograph (`platekit`, 520×110): blue band ends at 43.5 and the right band
/// starts at 473; the number is `6467-AAB`, digits spanning 102–261.5, the
/// hyphen at x≈285 (y≈54), letters 301.5–422.2. Reference ink is 7.5–102.2
/// (94.7 tall); ink is ~55% of a box and a box cannot leave the canvas, so the
/// 110 box gives ~60 ink, about 64% of the reference. The stars panel and the
/// `F` (y centre ≈ 87) follow `mayotte_plate`'s French geometry, scaled to the
/// narrower band. The right band holds a white box (x 477–515, y 8–46) with
/// the Saint-Martin logo — estimated, a simplified drawing: peaks, a wave and
/// the name in small type.
///
/// Fields: the digits and the letters are one slot each. The article gives
/// `1234-ABC` and `123-AB`, so each is a range (3–4 digits, 2–3 letters).
///
/// Not drawn: the 1993 yellow `123 ABC 97 1` series, which is history.
abstract final class _Layout {
  static const double width = 520, height = 110;
  static const double leftEnd = 43.5, rightStart = 473;

  static const double bandCx = 21.75;
  static const double panelWidth = 40, panelHeight = 61.2;
  static const double fTop = 65.5, fHeight = 22, fGlyph = 39, fWidth = 20;

  static const double logoLeft = 477, logoTop = 8;
  static const double logoWidth = 38, logoHeight = 38;
  static const double nameTop = 24, nameHeight = 7, nameGlyph = 7;

  static const double numberLeft = 102, numberWidth = 159.5;
  static const double lettersLeft = 301.5, lettersWidth = 120.7;

  static const double dashGlyph = 54, dashY = 54, dashX = 285;
}

/// The Saint-Martin logo, 100×100 units over the white box.
const PlateDrawing _logo = PlateDrawing(100, 100, <PlateShape>[
  PlateRectShape(0, 0, 100, 100, CollectivityOfSaintMartinColors.white),
  PlatePolygonShape(<Offset>[
    Offset(20, 40),
    Offset(35, 15),
    Offset(48, 30),
    Offset(60, 10),
    Offset(80, 40),
  ], CollectivityOfSaintMartinColors.logoGreen),
  PlateRectShape(15, 62, 70, 6, CollectivityOfSaintMartinColors.logoBlue),
  PlateRectShape(45, 70, 40, 6, CollectivityOfSaintMartinColors.logoBlue),
]);

/// Groups `number` and `letters` — the FNI `1234-ABC` with the EU band and `F`
/// on the left and the Saint-Martin logo on the right band.
abstract final class CollectivityOfSaintMartinPlates {
  static final PlateSpec private = _spec();

  static List<PlateSpec> get all => <PlateSpec>[private];

  static PlateSpec _spec() {
    return PlateSpec(
      id: 'mf.private',
      country: CollectivityOfSaintMartinCountry.collectivityOfSaintMartin,
      canvasWidth: _Layout.width,
      canvasHeight: _Layout.height,
      panel: PlatePanel(
        box: PlateBox(
          _Layout.bandCx - _Layout.panelWidth / 2,
          0,
          _Layout.panelWidth,
          _Layout.panelHeight,
        ),
        padding: EdgeInsets.zero,
      ),
      background: const PlateSection.columns(<PlatePart>[
        PlatePart(PlateSection.fill(PlateFill.panel), end: _Layout.leftEnd),
        PlatePart(PlateSection.plain, end: _Layout.rightStart),
        PlatePart(PlateSection.fill(PlateFill.panel)),
      ]),
      decals: const <PlateDecal>[
        PlateDecal(
          drawing: _logo,
          box: PlateBox(_Layout.logoLeft, _Layout.logoTop, _Layout.logoWidth, _Layout.logoHeight),
        ),
      ],
      slots: <PlateSlot>[
        PlateSlot(
          alphabet: CollectivityOfSaintMartinAlphabets.digits,
          box: const PlateBox(_Layout.numberLeft, 0, _Layout.numberWidth, _Layout.height),
          length: 4,
          minLength: 3,
        ),
        PlateSlot(
          alphabet: CollectivityOfSaintMartinAlphabets.letters,
          box: const PlateBox(_Layout.lettersLeft, 0, _Layout.lettersWidth, _Layout.height),
          length: 3,
          minLength: 2,
        ),
      ],
      labels: <PlateLabel>[
        PlateLabel(
          text: 'F',
          box: PlateBox(
            _Layout.bandCx - _Layout.fWidth / 2,
            _Layout.fTop,
            _Layout.fWidth,
            _Layout.fHeight,
          ),
          glyphHeight: _Layout.fGlyph,
          color: CollectivityOfSaintMartinColors.white,
        ),
        PlateLabel(
          text: 'Saint-Martin',
          box: PlateBox(_Layout.logoLeft, _Layout.nameTop, _Layout.logoWidth, _Layout.nameHeight),
          glyphHeight: _Layout.nameGlyph,
          color: CollectivityOfSaintMartinColors.logoGrey,
        ),
        PlateLabel(
          text: '-',
          box: PlateBox(
            _Layout.dashX - 15,
            _Layout.dashY - _Layout.dashGlyph / 2,
            30,
            _Layout.dashGlyph,
          ),
          glyphHeight: _Layout.dashGlyph,
        ),
      ],
      textGroups: const <PlateTextGroup>[
        PlateTextGroup(<int>[0], key: 'number'),
        PlateTextGroup(<int>[1], key: 'letters'),
      ],
    );
  }
}
