import 'package:plate_alphabet/plate_alphabet.dart';
import 'package:plate_core/plate_core.dart';

import 'british_virgin_islands_country.dart';

/// Where the ink sits, in millimetres on the documented 300×152 plate.
///
/// Measured off the flattened photos (`platekit`, 300×152 plate units, aspect
/// 2.00–2.10 against the documented 1.97). Ink heights are converted to glyph
/// heights at ~0.55 (caps) and ~0.67 (the taxi's mixed-case line). Per plate,
/// ink y-extent / x-extent:
///
/// * Private (`PV18107`): caption 2.5..18.5 (top clipped in the photo, height
///   assumed from the others) x 67..234; run 28..106.2 x 12..288; slogan
///   116.5..131.5 x 36..265. Aspect 2.10, so the run is a little loose.
/// * Government (`GV-0603`): caption 22..37.8 x 73.5..228.5; run 44.2..128.8
///   x 13.5..284.5, `GV` 13.5..83, dash centre 111.5, digits 136..284.5;
///   slogan 113.7..128.4 x 45..256.
/// * Commercial (`CM-6242`): caption 25.8..40.2 x 73.8..229.8; run
///   45.5..108.5, `CM` 20.8..92.2, dash centre 113, digits 134.5..285.8;
///   slogan 118.2..131.5 x 45.2..260.
/// * Taxi (`TAXI-801`): caption 12.8..31.2 x 75..231 (serif face); run
///   44.2..110.2, `TAXI` 39.2..134, dash centre 145.5, digits 157.5..259;
///   slogan 130.5..141.2 x 81..228 (italic mixed case).
///
/// **Taller runs are capped.** The government run's ink is 84.6 tall, which
/// would need a 154 glyph on a 152 plate; it is 130 (85%), kept centred on
/// the measured row. The private run is 120 (84% of 142) for the same reason.
/// The real faces are condensed; DejaVu Bold is wider, so runs are scaled to
/// their boxes. `plate_core` is unchanged.
abstract final class _Layout {
  static const double width = 300;
  static const double height = 152;

  static const double captionBoxWidth = 200;
  static const double captionBoxHeight = 30;
  static const double sloganBoxWidth = 260;
  static const double dashGlyph = 60;
  static const double dashBoxWidth = 30;
}

/// A category's measured rows; the rest of the plate is the same design.
class _Design {
  const _Design({
    required this.id,
    required this.prefixLength,
    this.prefixMinLength,
    required this.prefixLeft,
    required this.prefixWidth,
    required this.digitsLength,
    this.digitsMinLength,
    required this.digitsLeft,
    required this.digitsWidth,
    required this.runCentre,
    required this.runGlyph,
    this.dashCentre,
    required this.captionCentreX,
    required this.captionCentreY,
    required this.captionGlyph,
    required this.sloganCentreX,
    required this.sloganCentreY,
    required this.sloganGlyph,
    this.sloganText = 'NATURE’S LITTLE SECRETS',
  });

  final String id;
  final int prefixLength;
  final int? prefixMinLength;
  final double prefixLeft;
  final double prefixWidth;
  final int digitsLength;
  final int? digitsMinLength;
  final double digitsLeft;
  final double digitsWidth;
  final double runCentre;
  final double runGlyph;

  /// Null when the prefix runs straight into the digits (private).
  final double? dashCentre;
  final double captionCentreX;
  final double captionCentreY;
  final double captionGlyph;
  final double sloganCentreX;
  final double sloganCentreY;
  final double sloganGlyph;
  final String sloganText;

  PlateSpec build() => PlateSpec(
    id: id,
    country: BritishVirginIslandsCountry.british_virgin_islands,
    canvasWidth: _Layout.width,
    canvasHeight: _Layout.height,
    noPanel: true,
    panel: const PlatePanel(box: PlateBox(0, 0, 0, _Layout.height)),
    slots: <PlateSlot>[
      PlateSlot(
        alphabet: BritishVirginIslandsAlphabets.letters,
        box: PlateBox(prefixLeft, runCentre - runGlyph / 2, prefixWidth, runGlyph),
        length: prefixLength,
        minLength: prefixMinLength ?? prefixLength,
      ),
      PlateSlot(
        alphabet: BritishVirginIslandsAlphabets.digits,
        box: PlateBox(digitsLeft, runCentre - runGlyph / 2, digitsWidth, runGlyph),
        length: digitsLength,
        minLength: digitsMinLength ?? digitsLength,
      ),
    ],
    labels: <PlateLabel>[
      PlateLabel(
        text: 'VIRGIN ISLANDS',
        box: PlateBox(
          captionCentreX - _Layout.captionBoxWidth / 2,
          captionCentreY - _Layout.captionBoxHeight / 2,
          _Layout.captionBoxWidth,
          _Layout.captionBoxHeight,
        ),
        glyphHeight: captionGlyph,
      ),
      PlateLabel(
        text: sloganText,
        box: PlateBox(
          sloganCentreX - _Layout.sloganBoxWidth / 2,
          sloganCentreY - _Layout.captionBoxHeight / 2,
          _Layout.sloganBoxWidth,
          _Layout.captionBoxHeight,
        ),
        glyphHeight: sloganGlyph,
      ),
      if (dashCentre != null)
        PlateLabel(
          text: '-',
          box: PlateBox(
            dashCentre! - _Layout.dashBoxWidth / 2,
            runCentre - _Layout.dashGlyph / 2,
            _Layout.dashBoxWidth,
            _Layout.dashGlyph,
          ),
          glyphHeight: _Layout.dashGlyph,
        ),
    ],
    textGroups: const <PlateTextGroup>[
      PlateTextGroup(<int>[0], key: 'prefix'),
      PlateTextGroup(<int>[1], key: 'serial'),
    ],
  );
}

/// The Virgin Islands plates: one design (a class prefix and a serial between
/// the caption `VIRGIN ISLANDS` and the slogan), four categories that differ
/// in colour, field lengths and measured rows. Colour is on the theme.
///
/// Not implemented: rental vehicles (`RT 1234`, black on green) — the article
/// has no picture, so there is nothing to measure the colours or rows from;
/// the pre-1995 numerals-only plates and the 1995–96 `VI 1234` plates
/// (superseded).
abstract final class BritishVirginIslandsPlates {
  /// `PV` + five digits, black on yellow, no dash.
  static final PlateSpec private = const _Design(
    id: 'vg.private',
    prefixLength: 2,
    prefixLeft: 12,
    prefixWidth: 84,
    digitsLength: 5,
    digitsLeft: 97,
    digitsWidth: 191,
    runCentre: 67.1,
    runGlyph: 120, // 78.2 ink / 0.55 = 142, capped (see _Layout)
    captionCentreX: 150.5,
    captionCentreY: 10.5,
    captionGlyph: 29, // 16 ink / 0.55
    sloganCentreX: 150.5,
    sloganCentreY: 124,
    sloganGlyph: 27, // 15 ink / 0.55
  ).build();

  /// `GV-` + four digits, white on red.
  static final PlateSpec government = const _Design(
    id: 'vg.government',
    prefixLength: 2,
    prefixLeft: 13.5,
    prefixWidth: 69.5,
    digitsLength: 4,
    digitsLeft: 136,
    digitsWidth: 148.5,
    runCentre: 86.5,
    runGlyph: 130, // 84.6 ink / 0.55 = 154, capped (see _Layout)
    dashCentre: 111.5,
    captionCentreX: 151,
    captionCentreY: 29.9,
    captionGlyph: 29, // 15.8 ink / 0.55
    sloganCentreX: 150.5,
    sloganCentreY: 121,
    sloganGlyph: 27, // 14.7 ink / 0.55
  ).build();

  /// `CM-` + four digits, black on pale blue.
  static final PlateSpec commercial = const _Design(
    id: 'vg.commercial',
    prefixLength: 2,
    prefixLeft: 20.8,
    prefixWidth: 71.4,
    digitsLength: 4,
    digitsLeft: 134.5,
    digitsWidth: 151.3,
    runCentre: 77,
    runGlyph: 114.5, // 63 ink / 0.55
    dashCentre: 113,
    captionCentreX: 151.8,
    captionCentreY: 33,
    captionGlyph: 26, // 14.4 ink / 0.55
    sloganCentreX: 152.6,
    sloganCentreY: 124.9,
    sloganGlyph: 24, // 13.3 ink / 0.55
  ).build();

  /// `TAXI-123` or `TX-1234`, black on grey-white. One slot pair covers both
  /// the article's formats: the prefix is two to four letters and the serial
  /// three or four digits; the validator ties `TAXI` to three digits.
  static final PlateSpec taxi = const _Design(
    id: 'vg.taxi',
    prefixLength: 4,
    prefixMinLength: 2,
    prefixLeft: 39.2,
    prefixWidth: 94.8,
    digitsLength: 4,
    digitsMinLength: 3,
    digitsLeft: 157.5,
    digitsWidth: 101.5,
    runCentre: 77.2,
    runGlyph: 120, // 66 ink / 0.55
    dashCentre: 145.5,
    captionCentreX: 153,
    captionCentreY: 22,
    captionGlyph: 33, // 18.4 ink / 0.55; serif face, DejaVu is heavier
    sloganCentreX: 154.5,
    sloganCentreY: 135.9,
    sloganGlyph: 16, // 10.7 ink / 0.67, italic mixed case in the photo
    sloganText: 'Nature’s Little Secrets',
  ).build();
}
