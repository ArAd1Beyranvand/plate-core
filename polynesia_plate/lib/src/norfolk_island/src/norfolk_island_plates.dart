import 'package:plate_alphabet/plate_alphabet.dart';
import 'package:plate_core/plate_core.dart';

import 'norfolk_island_country.dart';

/// Where the ink sits, in plate units. The article gives no size for the
/// 1961 plate beyond "shorter than 372 × 134 mm"; the canvas is the flattened
/// photo's own 540 × 280 (aspect 1.93).
///
/// Measured off the flattened photo `AUS.NI3203`:
/// - block digit: x 41.2–121.5, ink y 64.8–241.5 (cy 153.15);
/// - number: three digits, x 197.2–485, same rows;
/// - diamond separator between them, centre ≈ (167, 160);
/// - caption "N·I": x 203.8–325.8, ink y 18.8–55.5 (cy 37.15, h 36.7).
///
/// The digit ink is 176.7 tall on a 280 plate, which would need a box of
/// about 340; the box is held to [digitBox] so it stays inside the canvas
/// (ink ≈ 51% of the box, ~128 or 72% of the photo's). Three digits then fill
/// the number span at DejaVu widths; the real die is narrower.
abstract final class _Layout {
  static const double width = 540, height = 280;

  static const double digitCy = 153.15, digitBox = 240;
  static const double blockLeft = 33.4, blockWidth = 96;
  static const double serialLeft = 197.2, serialWidth = 287.8;

  static const double dotCx = 167, dotCy = 160, dotGlyph = 40;
  static const double capCx = 264.8, capCy = 37.15, capWidth = 160;
  static const double capHeight = 50, capGlyph = 64;
}

/// Norfolk Island's plate: one block digit and a three-digit number, black on
/// yellow ([NorfolkIslandThemes.private]). Groups `block`, `serial`.
///
/// The article shows one plate; the administrative `A-123` (red on white) and
/// motorcycle `A C-12` plates it mentions have no picture and are not
/// modelled. The photo's holes and the sticker are not drawn. No
/// Israel-specific value exists.
abstract final class NorfolkIslandPlates {
  static final PlateSpec private = PlateSpec(
    id: 'nf.private',
    country: NorfolkIslandCountry.norfolk_island,
    canvasWidth: _Layout.width,
    canvasHeight: _Layout.height,
    panel: const PlatePanel(box: PlateBox(0, 0, 0, 0)),
    noPanel: true,
    slots: const <PlateSlot>[
      PlateSlot(
        alphabet: NorfolkIslandAlphabets.digits,
        box: PlateBox(
          _Layout.blockLeft,
          _Layout.digitCy - _Layout.digitBox / 2,
          _Layout.blockWidth,
          _Layout.digitBox,
        ),
        length: 1,
      ),
      PlateSlot(
        alphabet: NorfolkIslandAlphabets.digits,
        box: PlateBox(
          _Layout.serialLeft,
          _Layout.digitCy - _Layout.digitBox / 2,
          _Layout.serialWidth,
          _Layout.digitBox,
        ),
        length: 3,
      ),
    ],
    labels: const <PlateLabel>[
      PlateLabel(
        text: 'N·I',
        box: PlateBox(
          _Layout.capCx - _Layout.capWidth / 2,
          _Layout.capCy - _Layout.capHeight / 2,
          _Layout.capWidth,
          _Layout.capHeight,
        ),
        glyphHeight: _Layout.capGlyph,
      ),
      PlateLabel(
        text: '◆',
        box: PlateBox(_Layout.dotCx - 20, _Layout.dotCy - 20, 40, 40),
        glyphHeight: _Layout.dotGlyph,
      ),
    ],
    textGroups: const <PlateTextGroup>[
      PlateTextGroup(<int>[0], key: 'block'),
      PlateTextGroup(<int>[1], key: 'serial'),
    ],
  );

  static List<PlateSpec> get all => <PlateSpec>[private];
}
