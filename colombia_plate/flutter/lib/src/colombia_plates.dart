import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:plate_core/plate_core.dart';

import 'colombia_alphabets.dart';
import 'colombia_colors.dart';
import 'colombia_country.dart';

/// Where the ink sits on a Colombian plate, in millimetres.
///
/// The article gives no size. The canvas is 330×165: a 330 mm width at the
/// 2:1 the private artwork measures (its plate is 336×168 px). Every
/// reference's plate rectangle was mapped onto it.
///
/// * Private (artwork, `NAZ 827 ARMENIA`): serial ink y 37.3..120.8 (83.5
///   tall); letter centres 33.9, 82.0, 128.2, digit centres 199.4, 248.0,
///   296.6. That is six cells at pitch 47.6 with a 23.6 gap after the
///   split, the row centred. The ministry roundel sits in the gap, ink
///   x 155.2..170.9, y 70.7..86.4. Caption ink y 134.6..155.2, x 111..219.
///   Screw holes 6.9 across, centres x 69.2 / 262.7, y 17.2 / 150.8.
/// * Administrative staff (`AT 0282` photo): centres 35.4, 83.5 | 152.2,
///   200.4, 248.5, 295.6, roundel centre 118.8. The same pitch and gap with
///   the split after two cells, which is what fixes the gap model.
/// * Antique (`AID 899` photo): the same serial; full-height cyan strips to
///   x 86 and from x 244; `ANTIGUO` ink x ~111..220, y ~12.6..25.7.
/// * Police (`60-0007` photo): ink y 37.1..119.6, centres 32.5, 82.1 |
///   162.7, 206.1, 250.2, 295.9, a pitch of 45.7 and a gap of 36. Dash ink
///   x 113.1..136.3, y 76.3..84.6. `COLOMBIA` ink y 14.4..28.9, x ~124..205 by
///   eye; `POLICIA NACIONAL` ink x 69.7..249.4, y 134.1..150.6.
/// * Diplomatic corps (`A FR 000` photo, normalised by its field inside a
///   5 mm rim): band to y 38; `COLOMBIA` ink ~x 96..246, y ~11.6..32.4,
///   estimated by eye where the band's gradient defeated the mask. Serial
///   ink y 41..123.5; centres 34.3 | 99.9, 147.2 | 208.5, 253.6, 298.3.
///   Dashed rule at y ~125.5, ~1.2 thick, estimated by eye: sixteen dashes
///   from x 16 to 314.
///
/// **Under-height ink, accepted.** The plates are stamped in a condensed
/// face, a 40 mm wide glyph 83 mm tall. A slot scales its glyph down to fit
/// its cell, and DejaVu Bold is far wider than that, so the serial is
/// width-limited below the reference height (~49 of 83 mm). Captions are
/// sized to the measured ink *width* for the same reason, so they come out
/// shorter than the reference too. A narrow glyph (`I`, `1`) is not width-
/// limited and stands taller than its neighbours.
///
/// **Not drawn.** The ministry roundel's artwork (a fisheye `◉` stands in
/// for it), the antique plate's car graphic, the diplomatic plate's crest,
/// QR code, hologram and printed control number.
abstract final class _Layout {
  static const double width = 330, height = 165, centre = width / 2;

  // The shared `ABC·123` design.
  static const double pitch = 47.6, gap = 23.6, serialTop = 24;
  static const double serialHeight = 110, roundelY = 78.5, roundelGlyph = 28;
  static const PlateBox caption = PlateBox(15, 125, 300, 40);
  static const double captionGlyph = 29;

  /// The most caption characters that clear the lower screw holes (x 72.7
  /// to 259.3) at [captionGlyph]; `BOGOTA D.C.` just does. Longer captions
  /// shrink in proportion.
  static const int captionFit = 11;
  static const double holeSize = 6.9;
  static const List<double> holeX = <double>[69.2, 262.7];
  static const List<double> holeY = <double>[17.2, 150.8];

  // Antique.
  static const double stripLeftEnd = 86, stripRightStart = 244;
  static const PlateBox heading = PlateBox(60, 4, 210, 30);
  static const double headingGlyph = 24;

  // Police.
  static const double policePitch = 45.7, policeGap = 36;
  static const PlateBox policeDash = PlateBox(113.1, 76.3, 23.2, 8.2);
  static const PlateBox policeTop = PlateBox(92, 6, 150, 30);
  static const double policeTopGlyph = 19;
  static const PlateBox policeBottom = PlateBox(30, 127, 260, 30);
  static const double policeBottomGlyph = 23.5;

  // Diplomatic corps.
  static const double band = 38;
  static const PlateBox dipCaption = PlateBox(85, 2, 170, 40);
  static const double dipCaptionGlyph = 35, dipCell = 44.9, dipSerialTop = 27;
  static const double dipSerialHeight = 110, dipTypeCentre = 34.3;
  static const double dipCountryLeft = 99.9 - 47.3 / 2, dipCountryPitch = 47.3;
  static const double dipNumberLeft = 208.5 - 44.9 / 2, dipNumberPitch = 44.9;
  static const double dashY = 124.9, dashThickness = 1.2, dashLeft = 16;
  static const double dashRight = 314;
  static const int dashCount = 16;
  static const double dashLength = 12;
}

final List<PlateBand> _holes = <PlateBand>[
  for (final double x in _Layout.holeX)
    for (final double y in _Layout.holeY)
      PlateBand(
        box: PlateBox.centered(x, y, _Layout.holeSize, _Layout.holeSize),
        color: ColombiaColors.hole,
        topCornerRadius: _Layout.holeSize / 2,
        bottomCornerRadius: _Layout.holeSize / 2,
      ),
];

/// One kind of `ABC·123` plate: which characters it carries, in which
/// order, and what is printed above and below. Every one is the same design;
/// the colours are the theme's (see `ColombiaThemes`).
@immutable
class ColombiaSeries {
  const ColombiaSeries({
    required this.id,
    required this.english,
    required this.spanish,
    this.letters = 3,
    this.digits = 3,
    this.digitsFirst = false,
    this.fixed = '',
    this.caption,
    this.antique = false,
  });

  final String id, english, spanish;

  /// Letters in the series, [fixed] included.
  final int letters, digits;

  /// `123·ABC`, the mototaxi order.
  final bool digitsFirst;

  /// The letters every plate of the series starts with: `O`, `CC`, `R`.
  final String fixed;

  /// The caption under the serial, or null for the municipality of issue.
  final String? caption;

  /// Cyan side strips and `ANTIGUO` across the top.
  final bool antique;

  static const ColombiaSeries private = ColombiaSeries(
    id: 'private',
    english: 'Private',
    spanish: 'Particular',
  );
  static const ColombiaSeries commercial = ColombiaSeries(
    id: 'commercial',
    english: 'Public service',
    spanish: 'Servicio público',
  );
  static const ColombiaSeries official = ColombiaSeries(
    id: 'official',
    english: 'Official',
    spanish: 'Oficial',
    fixed: 'O',
  );
  static const ColombiaSeries antiqueCar = ColombiaSeries(
    id: 'antique',
    english: 'Antique car',
    spanish: 'Auto antiguo',
    antique: true,
  );
  static const ColombiaSeries mototaxi = ColombiaSeries(
    id: 'mototaxi',
    english: 'Auto rickshaw',
    spanish: 'Mototaxi',
    digitsFirst: true,
  );
  static const ColombiaSeries trailer = ColombiaSeries(
    id: 'trailer',
    english: 'Trailer',
    spanish: 'Remolque',
    letters: 1,
    digits: 5,
    fixed: 'R',
  );
  static const ColombiaSeries tankTruck = ColombiaSeries(
    id: 'tank',
    english: 'Tank truck',
    spanish: 'Carrotanque',
    letters: 1,
    digits: 4,
    fixed: 'T',
  );
  static const ColombiaSeries consular = ColombiaSeries(
    id: 'cc',
    english: 'Consular corps',
    spanish: 'Cuerpo consular',
    letters: 2,
    digits: 4,
    fixed: 'CC',
    caption: 'COLOMBIA',
  );
  static const ColombiaSeries organization = ColombiaSeries(
    id: 'oi',
    english: 'International organization',
    spanish: 'Organización internacional',
    letters: 2,
    digits: 4,
    fixed: 'OI',
    caption: 'COLOMBIA',
  );
  static const ColombiaSeries staff = ColombiaSeries(
    id: 'at',
    english: 'Non-diplomatic staff',
    spanish: 'Servicio administrativo y técnico',
    letters: 2,
    digits: 4,
    fixed: 'AT',
    caption: 'COLOMBIA',
  );

  static const List<ColombiaSeries> values = <ColombiaSeries>[
    private,
    commercial,
    official,
    antiqueCar,
    mototaxi,
    trailer,
    tankTruck,
    consular,
    organization,
    staff,
  ];
}

const PlatePanel _noPanel = PlatePanel(box: PlateBox(0, 0, 0, _Layout.height));

abstract final class ColombiaPlates {
  static const double _top = _Layout.serialTop, _height = _Layout.serialHeight;

  static PlateSpec standard({
    ColombiaSeries series = ColombiaSeries.private,
    String city = 'BOGOTA D.C.',
  }) {
    final String caption = series.caption ?? city;
    final int split = series.digitsFirst ? series.digits : series.letters;
    final (PlateAlphabet first, PlateAlphabet second) = series.digitsFirst
        ? (ColombiaAlphabets.digits, ColombiaAlphabets.letters)
        : (ColombiaAlphabets.letters, ColombiaAlphabets.digits);
    final PlateRowLayout row = plateRow(
      <PlateRowItem>[
        PlateRowRun(first, split),
        const PlateRowText.styled(
          '◉',
          _Layout.gap,
          top: _Layout.roundelY - _Layout.gap / 2,
          height: _Layout.gap,
          glyphHeight: _Layout.roundelGlyph,
        ),
        PlateRowRun(second, series.letters + series.digits - split),
      ],
      centre: _Layout.centre,
      top: _top,
      height: _height,
      pitch: _Layout.pitch,
    );

    return PlateSpec(
      id: 'co.${series.id}',
      country: ColombiaCountry.colombia,
      canvasWidth: _Layout.width,
      canvasHeight: _Layout.height,
      noPanel: true,
      panel: _noPanel,
      background: series.antique
          ? const PlateSection.columns(<PlatePart>[
              PlatePart(
                PlateSection.fill(PlateFill.divider),
                end: _Layout.stripLeftEnd,
              ),
              PlatePart(PlateSection.plain, end: _Layout.stripRightStart),
              PlatePart(PlateSection.fill(PlateFill.divider)),
            ])
          : PlateSection.plain,
      bands: _holes,
      labels: <PlateLabel>[
        ...row.labels,
        PlateLabel(
          text: caption,
          box: _Layout.caption,
          glyphHeight:
              _Layout.captionGlyph *
              min(1, _Layout.captionFit / caption.length),
        ),
        if (series.antique)
          const PlateLabel(
            text: 'ANTIGUO',
            box: _Layout.heading,
            glyphHeight: _Layout.headingGlyph,
            color: ColombiaColors.antiqueBlue,
          ),
      ],
      slots: row.slots,
      textGroups: <PlateTextGroup>[
        PlateTextGroup(const <int>[
          0,
        ], key: series.digitsFirst ? 'number' : 'letters'),
        PlateTextGroup(
          const <int>[1],
          prefix: ' ',
          key: series.digitsFirst ? 'letters' : 'number',
        ),
      ],
    );
  }

  static final PlateSpec police = PlateSpec(
    id: 'co.police',
    country: ColombiaCountry.colombia,
    canvasWidth: _Layout.width,
    canvasHeight: _Layout.height,
    noPanel: true,
    panel: _noPanel,
    rules: const <PlateRule>[PlateRule(box: _Layout.policeDash)],
    labels: const <PlateLabel>[
      PlateLabel(
        text: 'COLOMBIA',
        box: _Layout.policeTop,
        glyphHeight: _Layout.policeTopGlyph,
      ),
      PlateLabel(
        text: 'POLICIA NACIONAL',
        box: _Layout.policeBottom,
        glyphHeight: _Layout.policeBottomGlyph,
      ),
    ],
    slots: plateRow(
      const <PlateRowItem>[
        PlateRowRun(ColombiaAlphabets.digits, 2),
        PlateRowRun(ColombiaAlphabets.digits, 4),
      ],
      centre: _Layout.centre,
      top: _top,
      height: _height,
      pitch: _Layout.policePitch,
      gap: _Layout.policeGap,
    ).slots,
    textGroups: const <PlateTextGroup>[
      PlateTextGroup(<int>[0], key: 'unit'),
      PlateTextGroup(<int>[1], prefix: '-', key: 'number'),
    ],
  );

  static final PlateSpec diplomatic = PlateSpec(
    id: 'co.cd',
    country: ColombiaCountry.colombia,
    canvasWidth: _Layout.width,
    canvasHeight: _Layout.height,
    noPanel: true,
    panel: _noPanel,
    background: const PlateSection.rows(<PlatePart>[
      PlatePart(
        PlateSection.fill(PlateFill.color(ColombiaColors.diplomaticBand)),
        end: _Layout.band,
      ),
      PlatePart(PlateSection.plain),
    ]),
    rules: plateStipple(
      count: _Layout.dashCount,
      left: _Layout.dashLeft,
      top: _Layout.dashY,
      width: _Layout.dashLength,
      height: _Layout.dashThickness,
      stepX:
          (_Layout.dashRight - _Layout.dashLeft - _Layout.dashLength) /
          (_Layout.dashCount - 1),
    ),
    labels: const <PlateLabel>[
      PlateLabel(
        text: 'COLOMBIA',
        box: _Layout.dipCaption,
        glyphHeight: _Layout.dipCaptionGlyph,
        color: ColombiaColors.diplomaticNavy,
      ),
    ],
    slots: <PlateSlot>[
      for (final (PlateAlphabet a, int n, double left, double pitch) in [
        (
          ColombiaAlphabets.letters,
          1,
          _Layout.dipTypeCentre - _Layout.dipCell / 2,
          _Layout.dipCell,
        ),
        (
          ColombiaAlphabets.letters,
          2,
          _Layout.dipCountryLeft,
          _Layout.dipCountryPitch,
        ),
        (
          ColombiaAlphabets.digits,
          3,
          _Layout.dipNumberLeft,
          _Layout.dipNumberPitch,
        ),
      ])
        plateRun(
          a,
          n,
          left: left,
          pitch: pitch,
          top: _Layout.dipSerialTop,
          height: _Layout.dipSerialHeight,
        ),
    ],
    textGroups: const <PlateTextGroup>[
      PlateTextGroup(<int>[0], key: 'type'),
      PlateTextGroup(<int>[1], prefix: ' ', key: 'country'),
      PlateTextGroup(<int>[2], prefix: ' ', key: 'number'),
    ],
  );
}
