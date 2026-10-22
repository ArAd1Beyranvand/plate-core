import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

import 'package:plate_alphabet/plate_alphabet.dart' show ChristmasIslandAlphabets;

import 'christmas_island_country.dart';

/// Where the ink sits, in plate coordinates (mm, 372×134 from the article).
/// The flattened references are ~372 units wide, so their pixel extents
/// carry over directly.
///
/// Graphic (`Australia_..._graphic`): one ink row y 40.2..114.8 (74.6 tall),
/// `C` 27.2..66.2, `I` 90.8..113, diamond between, digits 169..356.2.
///
/// Issued (`XI.plate`): caption ink y 9.2..25.5 x 71.8..298.2; main row
/// y 31.5..107 with `C` 16.5..53.2, `I` to ~95, emblem ~110..180, digits
/// 204..357; bottom line y 108.5..122 x 58.8..313.
///
/// **Under-height ink, accepted.** Ink is ~0.55 of a slot, so 75 units of ink
/// would need a ~136 slot on a 134 plate. The graphic's row is centred at
/// 77.5 (off the plate's centre, 67), which a 112 slot cannot reach inside
/// the canvas; it is centred at 72 instead. The issued plate uses 104.
///
/// **Fields, not cells.** `CI` is one slot and the four digits another; the
/// fonts' advance is already wider than the printed pitch, so `spacing` is 0.
abstract final class _Layout {
  static const double width = 372;
  static const double height = 134;

  static const double gSlotHeight = 112;
  static const double gSlotTop = 72 - gSlotHeight / 2;
  static const double gLettersLeft = 27.2;
  static const double gLettersWidth = 113 - 27.2;
  static const double gDigitsLeft = 169;
  static const double gDigitsWidth = 356.2 - 169;
  static const double diamondCentre = 141;
  static const double diamondSize = 30;

  static const double ySlotHeight = 104;
  static const double ySlotTop = 69.25 - ySlotHeight / 2;
  static const double yLettersLeft = 16.5;
  static const double yLettersWidth = 95 - 16.5;
  static const double yDigitsLeft = 204;
  static const double yDigitsWidth = 357 - 204;

  /// Caption ink 16.3 tall → glyph 16.3 / 0.55; centred at y 17.35, x 185.
  static const double captionGlyph = 29.6;
  static const double captionCentreY = 17.35;
  static const double captionCentreX = 185;
  static const double captionWidth = 260;

  /// Bottom line ink 13.5 tall → 24.5; centred at y 115.25, x 186.
  static const double bottomGlyph = 24.5;
  static const double bottomCentreY = 115.25;
  static const double bottomCentreX = 186;
  static const double bottomWidth = 270;

  /// Emblem crop of the flattened photo (x 100..190, y 28..108).
  static const PlateBox emblem = PlateBox(100, 28, 90, 80);
}

/// Christmas Island's plates: `CI•1234`, two letters and four digits.
///
/// [standard] is the black-on-white graphic; [yellow] is the issued plate
/// with a caption, the island's emblem and `INDIAN OCEAN AUSTRALIA`. Text
/// groups: `letters` and `serial`.
///
/// Not implemented: the 1972 series (white-on-blue, `CHRISTMAS ISLAND` over
/// up to three digits) — superseded, current series since 2003.
abstract final class ChristmasIslandPlates {
  static const List<PlateTextGroup> _groups = <PlateTextGroup>[
    PlateTextGroup(<int>[0], key: 'letters'),
    PlateTextGroup(<int>[1], key: 'serial'),
  ];

  static PlateSlot _letters(double left, double width, double top, double h) => PlateSlot(
    alphabet: ChristmasIslandAlphabets.letters,
    box: PlateBox(left, top, width, h),
    length: 2,
  );

  static PlateSlot _digits(double left, double width, double top, double h) => PlateSlot(
    alphabet: ChristmasIslandAlphabets.digits,
    box: PlateBox(left, top, width, h),
    length: 4,
  );

  static PlateLabel _line(String text, double cx, double cy, double width, double glyph) =>
      PlateLabel(text: text, box: PlateBox(cx - width / 2, cy - 9, width, 18), glyphHeight: glyph);

  static final PlateSpec standard = PlateSpec(
    id: 'cx.standard',
    country: ChristmasIslandCountry.christmas_island,
    canvasWidth: _Layout.width,
    canvasHeight: _Layout.height,
    noPanel: true,
    panel: const PlatePanel(box: PlateBox(0, 0, 0, _Layout.height)),
    slots: <PlateSlot>[
      _letters(_Layout.gLettersLeft, _Layout.gLettersWidth, _Layout.gSlotTop, _Layout.gSlotHeight),
      _digits(_Layout.gDigitsLeft, _Layout.gDigitsWidth, _Layout.gSlotTop, _Layout.gSlotHeight),
    ],
    labels: <PlateLabel>[
      PlateLabel(
        text: '◆',
        box: PlateBox(
          _Layout.diamondCentre - _Layout.diamondSize / 2,
          72 - _Layout.diamondSize / 2,
          _Layout.diamondSize,
          _Layout.diamondSize,
        ),
        glyphHeight: _Layout.diamondSize,
      ),
    ],
    textGroups: _groups,
  );

  static final PlateSpec yellow = PlateSpec(
    id: 'cx.yellow',
    country: ChristmasIslandCountry.christmas_island,
    canvasWidth: _Layout.width,
    canvasHeight: _Layout.height,
    noPanel: true,
    panel: const PlatePanel(box: PlateBox(0, 0, 0, _Layout.height)),
    slots: <PlateSlot>[
      _letters(_Layout.yLettersLeft, _Layout.yLettersWidth, _Layout.ySlotTop, _Layout.ySlotHeight),
      _digits(_Layout.yDigitsLeft, _Layout.yDigitsWidth, _Layout.ySlotTop, _Layout.ySlotHeight),
    ],
    labels: <PlateLabel>[
      _line(
        'CHRISTMAS ISLAND',
        _Layout.captionCentreX,
        _Layout.captionCentreY,
        _Layout.captionWidth,
        _Layout.captionGlyph,
      ),
      _line(
        'INDIAN OCEAN AUSTRALIA',
        _Layout.bottomCentreX,
        _Layout.bottomCentreY,
        _Layout.bottomWidth,
        _Layout.bottomGlyph,
      ),
    ],
    // A crab and whale shark over a sun: an emblem, not boxes and text.
    decals: const <PlateDecal>[
      PlateDecal(
        image: AssetImage('assets/christmas_island/ci_emblem.png', package: 'indian_ocean_plate'),
        box: _Layout.emblem,
      ),
    ],
    textGroups: _groups,
  );
}
