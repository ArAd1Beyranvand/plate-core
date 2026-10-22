import 'dart:math';

import 'package:plate_alphabet/plate_alphabet.dart';
import 'package:plate_core/plate_core.dart';

import 'liberia_colors.dart';
import 'liberia_country.dart';

/// Where the ink sits, in plate units (520×264).
///
/// Measured off `Liberia_diplomatic_license_plate_for_U.S.__February_2017`,
/// flattened by the offline stage to 520×264 (aspect 1.97, the article's
/// 300×152 mm). Numbers are display px of the 2000 px-wide flat × 0.26:
///
/// * Number ink y 68.9..196.3 (127 tall, cy 132.6); `1` x 144..195, `CD`
///   204..315, `13` 325..436.
/// * Header "REPUBLIC OF LIBERIA" x 114..408, y 12.5..48 (35.5 of ink).
/// * Flag x 11.7..82, y 7.3..54.6 (the artwork is squashed to 1.48).
/// * LB oval: centre (71.5, 130.8), outer radius 56, stroke ~2; "LB" ink 57
///   tall.
/// * Year sticker x 439.4..506.5, y 208..254.3, outlined box, two lines.
///
/// The reference font is condensed and none ships, so the header, "LB" and the
/// number are smaller than the ink they copy: 127 units of ink would need a
/// ~176-unit glyph in a wide face. The slots use a 100-unit box, with a pitch
/// that fits three-three-two characters between x 144 and 510. The two screw
/// holes are not drawn. The article names nothing Israel-specific.
abstract final class _Layout {
  static const double width = 520;
  static const double height = 264;

  static const double numberCy = 132.6;
  static const double box = 100;
  static const double pitch = 0.6 * 0.72 * box;
  static const double missionLeft = 144;
  static const double statusLeft = missionLeft + 3 * pitch + 10;
  static const double numberLeft = statusLeft + 3 * pitch + 10;

  static const double headerCx = 261, headerCy = 30, headerWidth = 300;
  static const double headerGlyph = 24;

  static const PlateBox flag = PlateBox(11.7, 7.3, 70.3, 47.3);

  static const double ovalCx = 71.5, ovalCy = 130.8;
  static const double ovalRadius = 55, ovalStroke = 4;
  static const double lbGlyph = 60;

  static const PlateBox sticker = PlateBox(439.4, 208, 67.1, 46.3);
}

/// The diplomatic plate: mission digits, `CD`/`CMD`, number — `1 CD 13`.
/// Groups `mission`, `status`, `number`. Pair with
/// [LiberiaThemes.diplomatic].
///
/// Only the diplomatic plate was measured. Private plates ("A", "B", "C"
/// prefixes) have no reference and are not implemented.
abstract final class LiberiaPlates {
  static final PlateSpec diplomatic = PlateSpec(
    id: 'lr.diplomatic',
    country: LiberiaCountry.liberia,
    canvasWidth: _Layout.width,
    canvasHeight: _Layout.height,
    panel: const PlatePanel(box: PlateBox(0, 0, 0, 0)),
    noPanel: true,
    slots: <PlateSlot>[
      _field(LiberiaAlphabets.digits, 3, 1, _Layout.missionLeft),
      _field(LiberiaAlphabets.letters, 3, 2, _Layout.statusLeft),
      _field(LiberiaAlphabets.digits, 2, 1, _Layout.numberLeft),
    ],
    labels: const <PlateLabel>[
      PlateLabel(
        text: 'REPUBLIC OF LIBERIA',
        box: PlateBox(111, 18, 300, 24),
        glyphHeight: _Layout.headerGlyph,
      ),
      PlateLabel(text: 'LB', box: PlateBox(36.5, 100.8, 70, 60), glyphHeight: _Layout.lbGlyph),
      PlateLabel(text: 'Year', box: PlateBox(439.4, 220, 67.1, 14), glyphHeight: 14),
      PlateLabel(text: 'Sticker', box: PlateBox(439.4, 234, 67.1, 14), glyphHeight: 14),
    ],
    decals: const <PlateDecal>[
      PlateDecal(drawing: LiberiaCountry.flag, box: _Layout.flag),
      PlateDecal(drawing: _oval, box: PlateBox(0, 0, 520, 264)),
      PlateDecal(drawing: _stickerFrame, box: _Layout.sticker),
    ],
    textGroups: const <PlateTextGroup>[
      PlateTextGroup(<int>[0], key: 'mission'),
      PlateTextGroup(<int>[1], key: 'status'),
      PlateTextGroup(<int>[2], key: 'number'),
    ],
  );

  static List<PlateSpec> get all => <PlateSpec>[diplomatic];

  /// The LB oval, drawn over the whole plate so its coordinates are plate
  /// coordinates.
  static const PlateDrawing _oval = PlateDrawing(520, 264, <PlateShape>[
    PlateRingShape(
      _Layout.ovalCx,
      _Layout.ovalCy,
      _Layout.ovalRadius,
      _Layout.ovalStroke,
      LiberiaColors.ink,
    ),
  ]);

  /// The year sticker's outline: a 1.2-unit rule on four sides.
  static const PlateDrawing _stickerFrame = PlateDrawing(67.1, 46.3, <PlateShape>[
    PlateRectShape(0, 0, 67.1, 1.2, LiberiaColors.ink),
    PlateRectShape(0, 45.1, 67.1, 1.2, LiberiaColors.ink),
    PlateRectShape(0, 0, 1.2, 46.3, LiberiaColors.ink),
    PlateRectShape(65.9, 0, 1.2, 46.3, LiberiaColors.ink),
  ]);

  static PlateSlot _field(PlateAlphabet alphabet, int length, int minLength, double left) =>
      PlateSlot(
        alphabet: alphabet,
        box: PlateBox(
          left,
          _Layout.numberCy - _Layout.box / 2,
          length * _Layout.pitch,
          _Layout.box,
        ),
        length: length,
        minLength: minLength,
        spacing: max(0, _Layout.pitch - 0.6 * 0.72 * _Layout.box),
      );
}
