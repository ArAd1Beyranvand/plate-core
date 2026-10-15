import 'dart:math';

import 'package:flutter/widgets.dart' show EdgeInsets;
import 'package:plate_alphabet/plate_alphabet.dart';
import 'package:plate_core/plate_core.dart';

import 'italy_colors.dart';
import 'italy_country.dart';

/// One field: [count] characters of the [alphabet] whose first character is centred on [cx], at
/// [pitch], in a box [top]..[top]+[height] tall.
class _Run {
  const _Run(
    this.key,
    this.alphabet,
    this.count,
    this.cx,
    this.pitch,
    this.top,
    this.height,
  );

  final String key;
  final PlateAlphabet alphabet;
  final int count;
  final double cx, pitch, top, height;
}

/// What one design shares: the canvas, the blue bands, the ring, the row
/// divider and the cells.
///
/// The left band's artwork sits in a 110-tall top row (stars centred 35.1,
/// `I` y 62.2–89.2); [bandScale] shrinks that block for a shorter top row.
/// [leftEnd] and [rightStart] are the band edges, [ring] the centre and
/// diameter of the yellow ring in the right band, and [rowEnd] the y of the
/// line under the top row (null on a one-row plate).
class _Design {
  const _Design({
    required this.id,
    required this.width,
    required this.height,
    required this.leftEnd,
    required this.rightStart,
    required this.bandCx,
    required this.bandScale,
    required this.ringCx,
    required this.ringCy,
    required this.ringDiameter,
    required this.runs,
    this.rowEnd,
  });

  final String id;
  final double width, height, leftEnd, rightStart;
  final double bandCx, bandScale;
  final double ringCx, ringCy, ringDiameter;
  final double? rowEnd;
  final List<_Run> runs;
}

/// Where the ink sits, in plate units.
///
/// Car plate (`1999_CZ_889_KF`, vector artwork, flattened to the documented
/// 520×110): blue bands x 3–51.5 and 470.5–517 under a 2.5 frame, so the
/// sections end at 52 and 470; stars x 10–43.5, y 18.5–51.75 (centre 26.75,
/// 35.1); `I` white, y 62.2–89.2, cap 27; yellow ring x 478–509, y 14.75–45.8
/// (diameter 31, centre 493.5, 30.3). Letters centred 93.0, 143.0 (pitch 50),
/// digits 222.4, 275.4, 328.2 (pitch 52.9), letters 381.9, 433.5 (pitch
/// 51.6); ink y 12.2–98 (centre 55.1).
///
/// Two-line plate (360×220, article) and motorcycle plate (177×177, article)
/// are read as fractions off photographs (`1999_ZA_198_SG`,
/// `Targa_motociclistica_Italia_1999_BB_03813_Roma`), both fitted CHECK and
/// stretched, so their numbers are good to a few units only. Two-line: bands
/// 0.01–0.178 and 0.83–0.985 of the width over the top half; `ZA` centred
/// 0.413 and 0.577 of the width, y 15–100; bottom row digits at 0.101, 0.274,
/// 0.444 and letters at 0.710, 0.885, y 120–210. Motorcycle: bands 0.03–0.226
/// and 0.775–0.985 over y 0–0.44; `BB` at 0.346, 0.524, y 9.7–70.8; digits at
/// 0.144, 0.327, 0.510, 0.678, 0.861, y 96.6–161.
///
/// Ink is about 55% of a box, and a box cannot leave the canvas. The car's 86
/// tall ink would need a 156 box on a 110 plate, so its ink is ~60 (70% of
/// reference); the two-line plate's rows are 110 tall for 90 of ink (~67%);
/// the motorcycle's top row 80 for 61 (~72%) and bottom 96 for 64 (~83%).
///
/// Not drawn: the Republic emblem between the groups, the year and province
/// code in the ring, the 360×110 front plate, and every special series
/// (trailer, police, military, Carabinieri, fire brigade, Red Cross, Port
/// Authority, diplomatic, test, agricultural, moped, historic); the offline
/// stage found no usable measurement for them. No diplomatic plate is
/// implemented, so nothing Israel-specific exists here to refuse.
abstract final class _Layout {
  static const _Design car = _Design(
    id: 'it.private',
    width: 520,
    height: 110,
    leftEnd: 52,
    rightStart: 470,
    bandCx: 26.75,
    bandScale: 1,
    ringCx: 493.5,
    ringCy: 30.3,
    ringDiameter: 31,
    runs: <_Run>[
      _Run('prefix', ItalyAlphabets.letters, 2, 93.0, 50.0, 0, 110),
      _Run('number', ItalyAlphabets.digits, 3, 222.4, 52.9, 0, 110),
      _Run('suffix', ItalyAlphabets.letters, 2, 381.9, 51.6, 0, 110),
    ],
  );

  static const _Design twoLine = _Design(
    id: 'it.twoline',
    width: 360,
    height: 220,
    leftEnd: 64,
    rightStart: 299,
    bandCx: 33.7,
    bandScale: 1,
    ringCx: 326,
    ringCy: 35,
    ringDiameter: 30,
    rowEnd: 110,
    runs: <_Run>[
      _Run('prefix', ItalyAlphabets.letters, 2, 148.7, 59.0, 2.5, 110),
      _Run('number', ItalyAlphabets.digits, 3, 36.4, 61.7, 110, 110),
      _Run('suffix', ItalyAlphabets.letters, 2, 255.6, 63.0, 110, 110),
    ],
  );

  static const _Design motorcycle = _Design(
    id: 'it.motorcycle',
    width: 177,
    height: 177,
    leftEnd: 40,
    rightStart: 137,
    bandCx: 22.5,
    bandScale: 0.69,
    ringCx: 155,
    ringCy: 24.2,
    ringDiameter: 29,
    rowEnd: 78,
    runs: <_Run>[
      _Run('prefix', ItalyAlphabets.letters, 2, 61.3, 31.5, 0, 80),
      _Run('number', ItalyAlphabets.digits, 5, 25.5, 31.7, 80.8, 96),
    ],
  );

  /// The stars' panel block and the `I` under it, at scale 1 (car).
  static const double panelWidth = 46, panelHeight = 70.4;
  static const double iTop = 62.2, iHeight = 27, iGlyph = 49, iWidth = 20;

  /// Ring thickness as a share of its diameter.
  static const double ringStroke = 0.1;
}

/// The Italian plates. Groups `prefix`, `number`, and `suffix` (absent on the
/// motorcycle plate).
///
/// [private] is the one-line car plate, `AA 000 AA`; [twoLine] puts the prefix
/// above the number and suffix; [motorcycle] is the square `AA 00000`. All are
/// black on white with the EU band on the left and a blue band with a yellow
/// ring on the right, painted by the background.
abstract final class ItalyPlates {
  static final PlateSpec private = _spec(_Layout.car);
  static final PlateSpec twoLine = _spec(_Layout.twoLine);
  static final PlateSpec motorcycle = _spec(_Layout.motorcycle);

  static List<PlateSpec> get all => <PlateSpec>[private, twoLine, motorcycle];

  static PlateSpec _spec(_Design d) {
    final double s = d.bandScale;
    final PlateSection bands = PlateSection.columns(<PlatePart>[
      PlatePart(PlateSection.fill(PlateFill.panel), end: d.leftEnd),
      PlatePart(PlateSection.plain, end: d.rightStart),
      const PlatePart(PlateSection.fill(PlateFill.panel)),
    ]);
    final double ring = d.ringDiameter;
    final double inner = ring * (1 - 2 * _Layout.ringStroke);
    final List<PlateSlot> slots = <PlateSlot>[];
    final List<PlateTextGroup> groups = <PlateTextGroup>[];
    for (final _Run r in d.runs) {
      groups.add(PlateTextGroup(<int>[slots.length], key: r.key));
      slots.add(
        PlateSlot(
          alphabet: r.alphabet,
          box: PlateBox(r.cx - r.pitch / 2, r.top, r.count * r.pitch, r.height),
          length: r.count,
          spacing: max(0, r.pitch - 0.6 * 0.72 * r.height),
        ),
      );
    }
    return PlateSpec(
      id: d.id,
      country: ItalyCountry.italy,
      canvasWidth: d.width,
      canvasHeight: d.height,
      panel: PlatePanel(
        box: PlateBox(
          d.bandCx - _Layout.panelWidth * s / 2,
          0,
          _Layout.panelWidth * s,
          _Layout.panelHeight * s,
        ),
        padding: EdgeInsets.zero,
      ),
      background: d.rowEnd == null
          ? bands
          : PlateSection.rows(<PlatePart>[
              PlatePart(bands, end: d.rowEnd, divider: 1.5),
              PlatePart(PlateSection.plain),
            ]),
      bands: <PlateBand>[
        PlateBand(
          box: PlateBox(d.ringCx - ring / 2, d.ringCy - ring / 2, ring, ring),
          color: ItalyColors.ringYellow,
          topCornerRadius: ring / 2,
          bottomCornerRadius: ring / 2,
        ),
        PlateBand(
          box: PlateBox(
            d.ringCx - inner / 2,
            d.ringCy - inner / 2,
            inner,
            inner,
          ),
          color: ItalyColors.euroBlue,
          topCornerRadius: inner / 2,
          bottomCornerRadius: inner / 2,
        ),
      ],
      slots: slots,
      labels: <PlateLabel>[
        PlateLabel(
          text: 'I',
          box: PlateBox(
            d.bandCx - _Layout.iWidth * s / 2,
            _Layout.iTop * s,
            _Layout.iWidth * s,
            _Layout.iHeight * s,
          ),
          glyphHeight: _Layout.iGlyph * s,
          color: ItalyColors.white,
        ),
      ],
      textGroups: groups,
    );
  }
}
