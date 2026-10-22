import 'package:flutter/widgets.dart';
import 'package:plate_alphabet/plate_alphabet.dart';
import 'package:plate_core/plate_core.dart';

import 'anguilla_colors.dart';
import 'anguilla_country.dart';

/// Where the ink sits, in millimetres on the documented 300×152 plate.
///
/// Measured off `License_Plate_2007_Anguilla` flattened to a 152×76 plate
/// (aspect 2.00 against the documented 1.97): x scaled by 300/152, y by 2.
///
/// * Gradient (sampled down the left and right edges): flat blue to 11.5% of
///   the height, ramping to white by 39%, white to 62%, ramping back to blue
///   by 89%. The fog ellipse is centred on the plate and wide enough that its
///   horizontal edge never shows: radius 58.5 in y, full strength out to 30%
///   of it.
/// * Caption "Anguilla": ink y 11..33, x centre 149.7; "Rainbow City": ink
///   y 126..141, x centre 148.5. Both mixed-case with descenders, so ink is
///   ~0.67 of the glyph height.
/// * Letter `A`: ink x 94.8..135.2, y 44..112.4 (68.4 tall, centre 78.2).
/// * Digits `123`: ink x 159..251, same rows. The article allows four
///   digits (`A 1234`), the picture shows three; the box is centred on the
///   picture's run and holds four.
/// * Coat of arms: shield x 20..65, y 44..108.6, drawn at the Commons
///   artwork's 0.8 aspect.
///
/// **Narrower than the real face.** The plate's condensed face prints a
/// digit ~30 wide; DejaVu Bold is far wider, so the runs are scaled down to
/// their boxes. `plate_core` is unchanged.
abstract final class _Layout {
  static const double width = 300;
  static const double height = 152;

  static const double glyphHeight = 124; // 68.4 ink / 0.55
  static const double rowTop = 78.2 - glyphHeight / 2;

  static const double letterLeft = 85;
  static const double letterWidth = 60;
  static const double digitsLeft = 148;
  static const double digitsWidth = 114;

  static const double captionGlyph = 33; // 22 ink / 0.67
  static const double captionBoxWidth = 140;
  static const double captionBoxHeight = 30;
  static const double captionTop = 22 - captionBoxHeight / 2;
  static const double cityGlyph = 22; // 15 ink / 0.67
  static const double cityTop = 133.5 - captionBoxHeight / 2;

  static const double shieldLeft = 16.1;
  static const double shieldTop = 44;
  static const double shieldHeight = 66;
  static const double shieldWidth = 52.8;
}

/// Anguilla's plate geometry. One design, the 2007 plate: a vehicle-type
/// letter (`type`) and one to four digits (`serial`).
///
/// Not implemented: the 1950s white-on-black plate (superseded), and the
/// Governor's crown-emblem plate (the article gives no usable image).
abstract final class AnguillaPlates {
  static const PlateSpec private = PlateSpec(
    id: 'ai.private',
    country: AnguillaCountry.anguilla,
    canvasWidth: _Layout.width,
    canvasHeight: _Layout.height,
    noPanel: true,
    panel: PlatePanel(box: PlateBox(0, 0, 0, _Layout.height)),
    background: PlateSection.fill(
      PlateFill.stripes(
        <PlateFill>[PlateFill.panel, PlateFill.panel],
        stops: <double>[_Layout.height / 2],
        fog: PlateFog(
          center: Offset(_Layout.width / 2, _Layout.height / 2),
          radii: Size(4000, 58.5),
          plateau: 0.3,
        ),
      ),
    ),
    slots: <PlateSlot>[
      PlateSlot(
        alphabet: AnguillaAlphabets.letters,
        box: PlateBox(_Layout.letterLeft, _Layout.rowTop, _Layout.letterWidth, _Layout.glyphHeight),
      ),
      PlateSlot(
        alphabet: AnguillaAlphabets.digits,
        box: PlateBox(_Layout.digitsLeft, _Layout.rowTop, _Layout.digitsWidth, _Layout.glyphHeight),
        length: 4,
        minLength: 1,
      ),
    ],
    labels: <PlateLabel>[
      PlateLabel(
        text: 'Anguilla',
        box: PlateBox(
          (_Layout.width - _Layout.captionBoxWidth) / 2,
          _Layout.captionTop,
          _Layout.captionBoxWidth,
          _Layout.captionBoxHeight,
        ),
        glyphHeight: _Layout.captionGlyph,
        color: AnguillaColors.caption,
      ),
      PlateLabel(
        text: 'Rainbow City',
        box: PlateBox(
          (_Layout.width - _Layout.captionBoxWidth) / 2,
          _Layout.cityTop,
          _Layout.captionBoxWidth,
          _Layout.captionBoxHeight,
        ),
        glyphHeight: _Layout.cityGlyph,
        color: AnguillaColors.caption,
      ),
    ],
    decals: <PlateDecal>[
      // https://commons.wikimedia.org/wiki/File:Coat_of_arms_of_Anguilla.svg,
      // rasterised: a heraldic emblem, not something shapes can draw.
      PlateDecal(
        image: AssetImage(
          'assets/anguilla/icons/coat_of_arms_of_anguilla.png',
          package: 'caribbean_plate',
        ),
        box: PlateBox(
          _Layout.shieldLeft,
          _Layout.shieldTop,
          _Layout.shieldWidth,
          _Layout.shieldHeight,
        ),
      ),
    ],
    textGroups: <PlateTextGroup>[
      PlateTextGroup(<int>[0], key: 'type'),
      PlateTextGroup(<int>[1], key: 'serial'),
    ],
  );
}
