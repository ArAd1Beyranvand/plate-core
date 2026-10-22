import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:plate_alphabet/plate_alphabet.dart';
import 'package:plate_core/plate_core.dart';

import 'cocos_keeling_islands_colors.dart';
import 'cocos_keeling_islands_country.dart';

/// Where the ink sits, in plate units.
///
/// Measured on the 330×118 original of `Cocos_(Keeling)_Is._C-400` (the
/// offline flattening is CHECK and stretched, so the original was used) and
/// scaled by 1.127 / 1.135 to the article's 372×134 mm. Ink y 14–87 →
/// 15.9–98.8 (83 tall). `C` x 39–73 → 44–82; the diamond x 134–143, centre
/// y ~50 → 151–161, cy 57; `400` x 195–315 → 220–355, pitch ~48.5. Caption
/// ink x 90–252 → 99–284, y 93–105 → 106–119.
///
/// Ink of 83 would need a ~154-unit box on a 134-unit plate. The box is 118
/// (as Tuvalu's), ink ~62 with its baseline on the reference's (98.8), so
/// ink is ~75% of the reference. The caption is 16, ink ~8.6 of 10.3 and
/// narrow enough to stay between the frame lines.
abstract final class _Layout {
  static const double width = 372, height = 134;
  static const double box = 118, cy = 68;
  static const double letterLeft = 44, letterRight = 82;
  static const double serialLeft = 220, serialRight = 355;
  static const double diamondCx = 156, diamondCy = 57;
  static const double diamondHalfW = 5, diamondHalfH = 5;
  static const double captionCx = 191.5, captionCy = 112.5;
  static const double captionW = 200, captionBox = 20, captionGlyph = 16;
}

/// The general-issue plate, `C · 400`: blue on pale grey, one letter, a
/// diamond separator, three digits, and the territory name under the number
/// (groups `letters`, `serial`). Pair [general] with
/// [CocosKeelingIslandsThemes.general]. The article shows this one current
/// plate (Australian standard 372×134 mm, series from 2000) and names no
/// Israel-specific value.
abstract final class CocosKeelingIslandsPlates {
  static final PlateSpec general = PlateSpec(
    id: 'cc.general',
    country: CocosKeelingIslandsCountry.cocos_keeling_islands,
    canvasWidth: _Layout.width,
    canvasHeight: _Layout.height,
    panel: const PlatePanel(box: PlateBox(0, 0, 0, 0)),
    noPanel: true,
    slots: <PlateSlot>[
      _field(CocosKeelingIslandsAlphabets.letters, _Layout.letterLeft, _Layout.letterRight, 1),
      _field(CocosKeelingIslandsAlphabets.digits, _Layout.serialLeft, _Layout.serialRight, 3),
    ],
    textGroups: const <PlateTextGroup>[
      PlateTextGroup(<int>[0], key: 'letters'),
      PlateTextGroup(<int>[1], key: 'serial'),
    ],
    labels: const <PlateLabel>[
      PlateLabel(
        text: 'COCOS (KEELING) ISLANDS',
        box: PlateBox(
          _Layout.captionCx - _Layout.captionW / 2,
          _Layout.captionCy - _Layout.captionBox / 2,
          _Layout.captionW,
          _Layout.captionBox,
        ),
        glyphHeight: _Layout.captionGlyph,
      ),
    ],
    decals: const <PlateDecal>[
      PlateDecal(
        drawing: PlateDrawing(_Layout.diamondHalfW * 2, _Layout.diamondHalfH * 2, <PlateShape>[
          PlatePolygonShape(<Offset>[
            Offset(0, _Layout.diamondHalfH),
            Offset(_Layout.diamondHalfW, 0),
            Offset(_Layout.diamondHalfW * 2, _Layout.diamondHalfH),
            Offset(_Layout.diamondHalfW, _Layout.diamondHalfH * 2),
          ], CocosKeelingIslandsColors.ink),
        ]),
        box: PlateBox(
          _Layout.diamondCx - _Layout.diamondHalfW,
          _Layout.diamondCy - _Layout.diamondHalfH,
          _Layout.diamondHalfW * 2,
          _Layout.diamondHalfH * 2,
        ),
      ),
    ],
  );

  static List<PlateSpec> get all => <PlateSpec>[general];

  /// One field of [length] glyphs spanning [left]..[right]; the spacing brings
  /// the font's ~0.6 em advance up to the printed pitch.
  static PlateSlot _field(PlateAlphabet alphabet, double left, double right, int length) =>
      PlateSlot(
        alphabet: alphabet,
        box: PlateBox(left, _Layout.cy - _Layout.box / 2, right - left, _Layout.box),
        length: length,
        spacing: max(0, (right - left) / length - 0.6 * 0.72 * _Layout.box),
      );
}
