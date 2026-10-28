import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

import 'tunisia_alphabets.dart';
import 'tunisia_colors.dart';
import 'tunisia_country.dart';

/// Ink positions in millimetres, measured from photographs (no artwork
/// exists). Each plate's rim was mapped to the article's rear size, 520x110
/// (275x200 for the two-line plate). The photos measure 4.60-4.97 aspect
/// against the documented 4.73, so x carries a few millimetres of
/// perspective; rows are centred on the plate rather than placed at each
/// photo's offset.
///
/// Under-height ink is accepted: the photos' digits are 64-77 mm tall in a
/// condensed face. `glyphStyle` sets 0.72 of the slot and a bold digit is
/// ~0.73 of that, so 66 mm would need a 126 mm slot on a 110 mm plate, and
/// the fallback face's digits are wider than the plate's, so a glyph is
/// width-limited by its cell first. Labels are sized to the measured ink
/// width for the same reason.
///
/// Cells are fixed: the plates are lettered by hand on a proportional face
/// (the `1` is half a cell) and a `PlateSlot` is a fixed cell.
abstract final class _Layout {
  static const double width = 520;
  static const double height = 110;
  static const double centre = width / 2;

  // Ordinary one-line plate.
  static const double pitch = 45.6;
  static const double slotTop = 3;
  static const double slotHeight = 107;

  /// تونس is boxed at its ink width; the gaps put its centre 92.8 after the
  /// last series centre and 94.5 before the first number centre.
  static const double tunisWidth = 108;
  static const double tunisGapBefore = 92.8 - pitch / 2 - tunisWidth / 2;
  static const double tunisGapAfter = 94.5 - pitch / 2 - tunisWidth / 2;

  // Two-line plate, 275×200.
  static const double squareWidth = 275;
  static const double squareHeight = 200;
  static const double squarePitch = 44.6;
  static const double squareSlotHeight = 100;
  static const double squareRow1Top = 54.2 - squareSlotHeight / 2;
  static const double squareRow2Top = 143 - squareSlotHeight / 2;
  static const double squareTunisGap = 81.1 - squarePitch / 2 - tunisWidth / 2;

  /// The rim is ~7 mm on the 200 mm plate, not 0.041 of it.
  static const double squareRim = 7 / squareHeight;

  // Government.
  static const double govPitch = 46.1;
  static const double govSlotTop = 1;
  static const double govSlotHeight = 106;
  static const double govDashWidth = 28.5;
  static const double govDashThickness = 11.8;
  static const double govDashY = 60;
  static const double govGapBefore = 67.4 - govPitch / 2 - govDashWidth / 2;
  static const double govGapAfter = 61.1 - govPitch / 2 - govDashWidth / 2;

  // Military.
  static const double milCentre = 320.3;
  static const double milSlotTop = 4;
  static const double milSlotHeight = 106;
  static const PlateBox milFlag = PlateBox(57.1, 20.3, 79.7, 67.8);

  // Diplomatic.
  static const double dipPitch = 44;
  static const double dipSlotTop = 0;
  static const double dipSlotHeight = 104;
  static const double dipLatinWidth = 75.1;
  static const double dipArabicWidth = 125;

  /// Gaps between runs, from the measured ink edges.
  static const double dipGap1 = 131.6 - 113.0;
  static const double dipGap2 = 229.7 - 206.7;
  static const double dipGap3 = 393.8 - 354.7;

  // Temporary and dealer.
  static const double tmpPitch = 39;
  static const double tmpDashWidth = 20.5;
  static const double tmpDashThickness = 11.9;
  static const double tmpDashY = 56.5;
  static const double tmpCaptionWidth = 102;
  static const double tmpGapBefore = 65.7 - tmpPitch / 2 - tmpDashWidth / 2;
  static const double tmpGapAfter =
      106.9 - tmpDashWidth / 2 - tmpCaptionWidth / 2;

  static const double labelSlack = 40;

  /// Amiri Bold: the stamped تونس is a Naskh hand, ت raised over و.
  static const String tunisFont = 'TunisiaAmiri';

  /// Label glyph heights, fitted on the goldens so each word's ink matches
  /// the measured width.
  static const double tunisGlyph = 92;

  /// Smaller on the square, where a three-digit series leaves no room.
  static const double squareTunisGlyph = 76;
  static const double tmpCaptionGlyph = 80;

  /// Label box centres, fitted so the ink centres land on the measured ones.
  static const double tunisY = 50;
  static const double squareTunisY = 138;
  static const double dipLatinY = 55.4;
  static const double dipArabicY = 41;
  static const double tmpCaptionY = 53;
}

/// One stretch of a centred row, left to right: digit cells, a fixed word, a
/// dash, or empty space.
final class _Run {
  const _Run.digits(String this.key, this.count, {this.minLength})
    : text = null,
      font = null,
      width = 0,
      glyph = 0,
      thickness = 0,
      y = 0;

  /// A word boxed [width] wide, its box centred at plate y [y]. The box is not
  /// the ink: Arabic sits low in its line, so [y] is fitted. [font] is a
  /// family bundled by this package, or null for the theme's.
  const _Run.text(String this.text, this.width, this.glyph, this.y, {this.font})
    : key = null,
      count = 0,
      minLength = null,
      thickness = 0;

  /// A dash [width] long and [thickness] thick, centred at plate y [y].
  const _Run.dash(this.width, this.thickness, this.y)
    : key = null,
      font = null,
      text = null,
      count = 0,
      minLength = null,
      glyph = 0;

  const _Run.gap(this.width)
    : key = null,
      font = null,
      text = null,
      count = 0,
      minLength = null,
      glyph = 0,
      thickness = 0,
      y = 0;

  final String? key;
  final int count;
  final int? minLength;
  final String? text;
  final String? font;
  final double width;
  final double glyph;
  final double thickness;
  final double y;
}

typedef _Row = ({
  List<PlateSlot> slots,
  List<PlateLabel> labels,
  List<PlateRule> rules,
  List<PlateTextGroup> groups,
});

/// A diplomatic plate's code: Latin and Arabic initials, fixed by the
/// vehicle's status. The glyph heights fit each word to the `CD` boxes.
@immutable
class TunisiaMission {
  const TunisiaMission({
    required this.id,
    required this.latin,
    required this.arabic,
    required this.latinGlyph,
    required this.arabicGlyph,
  });

  final String id;
  final String latin;
  final String arabic;
  final double latinGlyph;
  final double arabicGlyph;

  /// Corps diplomatique, `CD س د`. Measured.
  static const TunisiaMission corps = TunisiaMission(
    id: 'cd',
    latin: 'CD',
    arabic: 'س\u200Cد',
    latinGlyph: 72,
    arabicGlyph: 95,
  );

  /// Mission diplomatique, `MD ب د`. No photo: the `CD` boxes.
  static const TunisiaMission mission = TunisiaMission(
    id: 'md',
    latin: 'MD',
    arabic: 'ب\u200Cد',
    latinGlyph: 62,
    arabicGlyph: 95,
  );

  /// Chef de mission diplomatique, `CMD ر ب د`, an ambassador's car. No
  /// photo: the `CD` boxes, the words shrunk to fit them.
  static const TunisiaMission chief = TunisiaMission(
    id: 'cmd',
    latin: 'CMD',
    arabic: 'ر\u200Cب\u200Cد',
    latinGlyph: 44,
    arabicGlyph: 80,
  );

  static const List<TunisiaMission> values = <TunisiaMission>[
    corps,
    mission,
    chief,
  ];
}

/// The word after a temporary plate's serial: `ن ت` for a vehicle under
/// suspended duty (RS), `ع ع` for a dealer's test vehicle.
@immutable
class TunisiaSuffix {
  const TunisiaSuffix({required this.id, required this.arabic});

  final String id;
  final String arabic;

  static const TunisiaSuffix suspended = TunisiaSuffix(
    id: 'rs',
    arabic: 'ن\u200Cت',
  );
  static const TunisiaSuffix dealer = TunisiaSuffix(
    id: 'ww',
    arabic: 'ع\u200Cع',
  );
}

/// * [standard]: 520x110, `NNN تونس NNNN`. Ordinary and rental cars differ
///   by theme.
/// * [square]: the 275x200 two-line rear plate, number over series and تونس.
/// * [government]: `NN - NNNNNN`, ministry and vehicle.
/// * [diplomatic]: `NN CD س د NN`; `MD` and `CMD` by [TunisiaMission].
/// * [military]: five digits with the flag at the left.
/// * [temporary]: `NNNNN - ن ت`, or `ع ع` for a dealer ([TunisiaSuffix]).
///
/// Every spec is one centred row built by `_row`; they differ in the runs.
/// Text groups: `series`, `number`; government `ministry`, `number`;
/// diplomatic `country`, `serial`; military and temporary `serial`.
///
/// Not implemented: the motorcycle plate (its one photo is too small and
/// shows an undocumented format), the pre-1975 series, and the sticker on the
/// military photo. Screw holes are not printed.
abstract final class TunisiaPlates {
  /// The flag cropped to the disc, as the military plate prints it.
  static const PlateDrawing _militaryFlag =
      PlateDrawing(55.2, 46.9, <PlateShape>[
        PlateRectShape(0, 0, 55.2, 46.9, TunisiaColors.flagRed),
        PlateCircleShape(27.6, 23.45, 20, Color(0xFFFFFFFF)),
        PlateCrescentShape(27.6, 23.45, 15, 4, 12, TunisiaColors.flagRed),
        PlateStarShape(31.6, 23.45, 9, TunisiaColors.flagRed, rotation: 270),
      ]);

  static final Map<TunisiaMission, PlateSpec> _diplomatic =
      <TunisiaMission, PlateSpec>{};
  static final Map<TunisiaSuffix, PlateSpec> _temporary =
      <TunisiaSuffix, PlateSpec>{};

  /// The series is one field of 1-3 digits, printed without leading zeros.
  static final PlateSpec standard = _standardSpec();

  static final PlateSpec square = _squareSpec();

  /// A ministry code and a vehicle number of 1-6 digits.
  static final PlateSpec government = _governmentSpec();

  static PlateSpec diplomatic([
    TunisiaMission mission = TunisiaMission.corps,
  ]) => _diplomatic[mission] ??= _diplomaticSpec(mission);

  static PlateSpec temporary([
    TunisiaSuffix suffix = TunisiaSuffix.suspended,
  ]) => _temporary[suffix] ??= _temporarySpec(suffix);

  /// Lays [runs] out left to right, centred on [centre]. Group indices start
  /// at [first], for a spec whose earlier row already holds slots.
  static _Row _row(
    List<_Run> runs, {
    required double pitch,
    required double top,
    required double height,
    double centre = _Layout.centre,
    double canvasWidth = _Layout.width,
    double canvasHeight = _Layout.height,
    int first = 0,
  }) {
    double extent(_Run r) => r.key != null ? r.count * pitch : r.width;
    double x = centre - runs.fold<double>(0, (s, r) => s + extent(r)) / 2;
    int index = first;
    final List<PlateSlot> slots = <PlateSlot>[];
    final List<PlateLabel> labels = <PlateLabel>[];
    final List<PlateRule> rules = <PlateRule>[];
    final List<PlateTextGroup> groups = <PlateTextGroup>[];
    for (final _Run r in runs) {
      if (r.key != null) {
        slots.add(
          PlateSlot(
            alphabet: TunisiaAlphabets.digits,
            box: PlateBox(x, top, r.count * pitch, height),
            length: r.count,
            minLength: r.minLength,
            spacing: r.minLength == null
                ? max(0, pitch - 0.6 * 0.72 * height)
                : 0,
          ),
        );
        groups.add(PlateTextGroup(<int>[index], key: r.key));
        index += 1;
      } else if (r.text != null) {
        // A label is centred in its box only while its line fits: a wider one
        // overflows to the right. Arabic advances run well past the ink, so
        // the box gets as much slack on both sides as the canvas allows and
        // reaches the nearer edge vertically.
        final double slack = <double>[
          _Layout.labelSlack,
          x,
          canvasWidth - x - r.width,
        ].reduce(min);
        final double half = r.y < canvasHeight / 2 ? r.y : canvasHeight - r.y;
        labels.add(
          PlateLabel(
            text: r.text!,
            box: PlateBox(x - slack, r.y - half, r.width + 2 * slack, 2 * half),
            glyphHeight: r.glyph,
            fontFamily: r.font,
            fontPackage: r.font == null ? null : 'tunisia_plate',
          ),
        );
      } else if (r.thickness > 0) {
        rules.add(
          PlateRule(
            box: PlateBox(x, r.y - r.thickness / 2, r.width, r.thickness),
          ),
        );
      }
      x += extent(r);
    }
    return (slots: slots, labels: labels, rules: rules, groups: groups);
  }

  static PlateSpec _spec(
    String id,
    _Row row, {
    double width = _Layout.width,
    double height = _Layout.height,
    double? rim,
    List<PlateDecal> decals = const <PlateDecal>[],
  }) => PlateSpec(
    id: 'tn.$id',
    country: TunisiaCountry.tunisia,
    canvasWidth: width,
    canvasHeight: height,
    borderWidthRatioOverride: rim,
    noPanel: true,
    panel: PlatePanel(box: PlateBox(0, 0, 0, height)),
    slots: row.slots,
    labels: row.labels,
    rules: row.rules,
    decals: decals,
    textGroups: row.groups,
  );

  static PlateSpec _standardSpec() => _spec(
    'standard',
    _row(
      <_Run>[
        const _Run.digits('series', 3, minLength: 1),
        const _Run.gap(_Layout.tunisGapBefore),
        const _Run.text(
          'تونس',
          _Layout.tunisWidth,
          _Layout.tunisGlyph,
          _Layout.tunisY,
          font: _Layout.tunisFont,
        ),
        const _Run.gap(_Layout.tunisGapAfter),
        const _Run.digits('number', 4),
      ],
      pitch: _Layout.pitch,
      top: _Layout.slotTop,
      height: _Layout.slotHeight,
    ),
  );

  static PlateSpec _squareSpec() {
    const double centre = _Layout.squareWidth / 2;
    final _Row upper = _row(
      const <_Run>[_Run.digits('number', 4)],
      pitch: _Layout.squarePitch,
      top: _Layout.squareRow1Top,
      height: _Layout.squareSlotHeight,
      centre: centre,
      canvasWidth: _Layout.squareWidth,
      canvasHeight: _Layout.squareHeight,
    );
    final _Row lower = _row(
      <_Run>[
        const _Run.digits('series', 3, minLength: 1),
        const _Run.gap(_Layout.squareTunisGap),
        const _Run.text(
          'تونس',
          _Layout.tunisWidth,
          _Layout.squareTunisGlyph,
          _Layout.squareTunisY,
          font: _Layout.tunisFont,
        ),
      ],
      pitch: _Layout.squarePitch,
      top: _Layout.squareRow2Top,
      height: _Layout.squareSlotHeight,
      centre: centre,
      canvasWidth: _Layout.squareWidth,
      canvasHeight: _Layout.squareHeight,
      first: 1,
    );
    return _spec(
      'square',
      (
        slots: <PlateSlot>[...upper.slots, ...lower.slots],
        labels: lower.labels,
        rules: const <PlateRule>[],
        // Series first, as on the one-line plate.
        groups: <PlateTextGroup>[...lower.groups, ...upper.groups],
      ),
      width: _Layout.squareWidth,
      height: _Layout.squareHeight,
      rim: _Layout.squareRim,
    );
  }

  static PlateSpec _governmentSpec() => _spec(
    'government',
    _row(
      <_Run>[
        const _Run.digits('ministry', 2),
        const _Run.gap(_Layout.govGapBefore),
        const _Run.dash(
          _Layout.govDashWidth,
          _Layout.govDashThickness,
          _Layout.govDashY,
        ),
        const _Run.gap(_Layout.govGapAfter),
        const _Run.digits('number', 6, minLength: 1),
      ],
      pitch: _Layout.govPitch,
      top: _Layout.govSlotTop,
      height: _Layout.govSlotHeight,
    ),
  );

  static PlateSpec _diplomaticSpec(TunisiaMission m) => _spec(
    'diplomatic.${m.id}',
    _row(
      <_Run>[
        const _Run.digits('country', 2),
        const _Run.gap(_Layout.dipGap1),
        _Run.text(
          m.latin,
          _Layout.dipLatinWidth,
          m.latinGlyph,
          _Layout.dipLatinY,
        ),
        const _Run.gap(_Layout.dipGap2),
        _Run.text(
          m.arabic,
          _Layout.dipArabicWidth,
          m.arabicGlyph,
          _Layout.dipArabicY,
        ),
        const _Run.gap(_Layout.dipGap3),
        const _Run.digits('serial', 2),
      ],
      pitch: _Layout.dipPitch,
      top: _Layout.dipSlotTop,
      height: _Layout.dipSlotHeight,
    ),
  );

  static final PlateSpec military = _spec(
    'military',
    _row(
      const <_Run>[_Run.digits('serial', 5)],
      pitch: _Layout.pitch,
      top: _Layout.milSlotTop,
      height: _Layout.milSlotHeight,
      centre: _Layout.milCentre,
    ),
    decals: const <PlateDecal>[
      PlateDecal(drawing: _militaryFlag, box: _Layout.milFlag),
    ],
  );

  static PlateSpec _temporarySpec(TunisiaSuffix s) => _spec(
    'temporary.${s.id}',
    _row(
      <_Run>[
        const _Run.digits('serial', 5),
        const _Run.gap(_Layout.tmpGapBefore),
        const _Run.dash(
          _Layout.tmpDashWidth,
          _Layout.tmpDashThickness,
          _Layout.tmpDashY,
        ),
        const _Run.gap(_Layout.tmpGapAfter),
        _Run.text(
          s.arabic,
          _Layout.tmpCaptionWidth,
          _Layout.tmpCaptionGlyph,
          _Layout.tmpCaptionY,
        ),
      ],
      pitch: _Layout.tmpPitch,
      top: _Layout.slotTop,
      height: _Layout.slotHeight,
    ),
  );
}
