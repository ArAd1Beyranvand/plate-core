import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:plate_alphabet/plate_alphabet.dart';
import 'package:plate_core/plate_core.dart';

import 'senegal_country.dart';
import 'senegal_themes.dart';

/// Where the ink sits, in plate units. Every plate is 520 wide.
///
/// The article gives 52×11 cm (one row), 32×20 cm (truck rear) and 24×13 cm
/// (motorcycle), so the canvases are 520×110, 520×325 and 520×281. The
/// references are photographs flattened to 520×110 whatever their shape, so
/// every y measured off the two-row plates is multiplied by 325/110 and
/// 281/110 (their photos fit at aspect 1.52 and 1.76, about 3% under the
/// article, as the one-row photos do). Centres are of ink runs on the flat
/// photos:
///
/// * old `DK-1234-AB` (flat v2), ink y 17.5–87.5: `DK` 55.4, 110 (pitch 54.6);
///   dashes 155.3 and 365.8; digits 188.8–318.7 (pitch 43.3); `AB` 413.9,
///   466.9. v1 (`TH-1234-A`) is the same plate with a single closing letter,
///   centred in the same field.
/// * current front `AA-012-BC`, ink y 20–94.2: `AA` 76, 128.4 (pitch 52.4);
///   dots 167.5 and 332.6; digits 201.2, 247.9, 297.1 (pitch 48); `BC` 372.5,
///   420.8; the region `DK` x 469.5–497.8 ink y 21.5–41.8 and the department
///   `01` y 68.5–88.8.
/// * truck rear, ink rows y 26.6–144 and 181.7–295.5: `AA` 184.4, 270.4 (pitch
///   86), dash 334.8; `012` 107.5, 184.6, 265.6 (pitch 79), dash 311.5; `BC`
///   367.6, 447 (pitch 79.4); `DK` y 32.5–65 and `01` y 107.8–140.3 at x
///   424.8–471.5; blue block x 9.75–62.25, y to 162.
/// * motorcycle, ink rows y 18.5–116 and 161.1–254.4: `AA` 219, 296.7 (pitch
///   77.7), dash 348; `123` 139.3, 210.4, 279.4 (pitch 70), dash 333; `BC`
///   396.8, 463.5 (pitch 66.7); `DK` y 18.5–47.9 and `01` y 83.1–111.9 at x
///   418.5–459.2; blue block x 9.5–79.5, y to 139.
///
/// Ink is ~55% of a slot box (`glyphStyle`: 0.72 of the box, a cap three
/// quarters of that). The reference ink of 70–118 would need boxes of 127–215;
/// the one-row boxes are capped at 100–102 on the 110-unit plate, the tall
/// plates at 140 and 124 so both rows fit, which lands the ink at 60–80% of
/// the reference. The 0.72 is the engine's and is left alone.
abstract final class _Layout {
  static const double width = 520;

  /// Separator glyph boxes are this wide, centred on the printed mark.
  static const double markWidth = 30;

  static const double oldHeight = 110, oldBox = 100, oldCy = 53;
  static const double currentHeight = 110, currentBox = 102, currentCy = 57.1;

  /// The region and department stacked at the right of the current front plate.
  static const double codeBox = 36;
  static const PlatePanel currentPanel = PlatePanel(
    box: PlateBox(0, 0, 38, 110),
    padding: EdgeInsets.fromLTRB(9.5, 19, 3, 21),
  );
  static const PlateSection currentBackground =
      PlateSection.columns(<PlatePart>[
        PlatePart(PlateSection.fill(PlateFill.panel), end: 38),
        PlatePart(PlateSection.plain),
      ]);
}

/// One field: its group key, its alphabet, its first ink centre, its pitch,
/// its longest and shortest length and its row's centre and box height.
class _Run {
  const _Run(
    this.key,
    this.letters,
    this.firstCentre,
    this.pitch,
    this.count,
    this.cy,
    this.box, {
    this.min,
  });

  final String key;
  final bool letters;
  final double firstCentre, pitch, cy, box;
  final int count;
  final int? min;
}

/// A printed separator: a dash or dot centred on [cx].
class _Mark {
  const _Mark(this.text, this.cx, this.cy, this.box);

  final String text;
  final double cx, cy, box;
}

/// Senegal's plates.
///
/// * [old] — 1989–2019 `DK-1234-A`/`DK-1234-AB`: white on blue, region code,
///   four digits, one or two letters (one slot with `minLength`, so both
///   photographed versions are this spec).
/// * [current] — `AA-012-BC` over a blue strip with the flag and `SN`, and the
///   region and department stacked at the right.
/// * [truckRear] — the same fields on two rows (32×20 cm), strip at the top
///   left, region and department beside the first row.
/// * [motorcycle] — the two-row layout at 24×13 cm.
///
/// Not implemented: the pre-2009 Ziguinchor plate (pictured, unticked), the
/// 2000s version with a country strip, and any other class the article does not
/// picture. The article names no Israel-specific value.
abstract final class SenegalPlates {
  static final PlateSpec old = _build(
    id: 'sn.old',
    height: _Layout.oldHeight,
    runs: const <_Run>[
      _Run('region', true, 55.4, 54.6, 2, _Layout.oldCy, _Layout.oldBox),
      _Run('number', false, 188.8, 43.3, 4, _Layout.oldCy, _Layout.oldBox),
      _Run(
        'letters',
        true,
        413.9,
        53,
        2,
        _Layout.oldCy,
        _Layout.oldBox,
        min: 1,
      ),
    ],
    marks: const <_Mark>[
      _Mark('-', 155.3, _Layout.oldCy, _Layout.oldBox),
      _Mark('-', 365.8, _Layout.oldCy, _Layout.oldBox),
    ],
  );

  static final PlateSpec current = _build(
    id: 'sn.current',
    height: _Layout.currentHeight,
    runs: const <_Run>[
      _Run('series', true, 76, 52.4, 2, _Layout.currentCy, _Layout.currentBox),
      _Run(
        'number',
        false,
        201.2,
        48,
        3,
        _Layout.currentCy,
        _Layout.currentBox,
      ),
      _Run(
        'letters',
        true,
        372.5,
        48.3,
        2,
        _Layout.currentCy,
        _Layout.currentBox,
      ),
      _Run('region', true, 483.6, 14.2, 2, 31.65, _Layout.codeBox),
      _Run('department', false, 483.6, 14.2, 2, 78.65, _Layout.codeBox),
    ],
    marks: const <_Mark>[
      _Mark('·', 167.5, _Layout.currentCy, _Layout.currentBox),
      _Mark('·', 332.6, _Layout.currentCy, _Layout.currentBox),
    ],
    background: _Layout.currentBackground,
    panel: _Layout.currentPanel,
  );

  static final PlateSpec truckRear = _build(
    id: 'sn.truckRear',
    height: 325,
    runs: const <_Run>[
      _Run('series', true, 184.4, 86, 2, 85.3, 140),
      _Run('number', false, 107.5, 79, 3, 238.6, 140),
      _Run('letters', true, 367.6, 79.4, 2, 238.6, 140),
      _Run('region', true, 448.2, 23.5, 2, 48.75, 60),
      _Run('department', false, 448.2, 23.5, 2, 124, 60),
    ],
    marks: const <_Mark>[
      _Mark('-', 334.8, 85.3, 140),
      _Mark('-', 311.5, 238.6, 140),
    ],
    background: _twoRowBackground(62, 165),
    panel: const PlatePanel(
      box: PlateBox(0, 0, 62, 165),
      padding: EdgeInsets.fromLTRB(16, 31, 3.5, 20),
    ),
  );

  static final PlateSpec motorcycle = _build(
    id: 'sn.motorcycle',
    height: 281,
    runs: const <_Run>[
      _Run('series', true, 219, 77.7, 2, 67, 124),
      _Run('number', false, 139.3, 70, 3, 207.8, 124),
      _Run('letters', true, 396.8, 66.7, 2, 207.8, 124),
      _Run('region', true, 439, 20.4, 2, 33.2, 52),
      _Run('department', false, 439, 20.4, 2, 97.5, 52),
    ],
    marks: const <_Mark>[_Mark('-', 348, 67, 124), _Mark('-', 333, 207.8, 124)],
    background: _twoRowBackground(80, 139),
    panel: const PlatePanel(
      box: PlateBox(0, 0, 80, 139),
      padding: EdgeInsets.fromLTRB(18, 21, 6.5, 10),
    ),
  );

  static List<PlateSpec> get all => <PlateSpec>[
    old,
    current,
    truckRear,
    motorcycle,
  ];

  /// The theme each spec is drawn in.
  static PlateTheme themeOf(PlateSpec spec) => switch (spec.id) {
    'sn.old' => SenegalThemes.old,
    'sn.current' => SenegalThemes.current,
    _ => SenegalThemes.twoRow,
  };

  /// The strip is a block in the top left corner, run out under the frame.
  static PlateSection _twoRowBackground(double endX, double endY) =>
      PlateSection.columns(<PlatePart>[
        PlatePart(
          PlateSection.rows(<PlatePart>[
            PlatePart(PlateSection.fill(PlateFill.panel), end: endY),
            const PlatePart(PlateSection.plain),
          ]),
          end: endX,
        ),
        const PlatePart(PlateSection.plain),
      ]);

  static PlateSpec _build({
    required String id,
    required double height,
    required List<_Run> runs,
    required List<_Mark> marks,
    PlateSection background = PlateSection.plain,
    PlatePanel? panel,
  }) {
    final slots = <PlateSlot>[];
    final groups = <PlateTextGroup>[];
    for (final run in runs) {
      groups.add(PlateTextGroup(<int>[slots.length], key: run.key));
      final bool variable = run.min != null;
      slots.add(
        PlateSlot(
          alphabet: run.letters
              ? SenegalAlphabets.letters
              : SenegalAlphabets.digits,
          box: PlateBox(
            run.firstCentre - run.pitch / 2,
            run.cy - run.box / 2,
            run.count * run.pitch,
            run.box,
          ),
          length: run.count,
          minLength: run.min,
          spacing: variable ? 0 : max(0, run.pitch - 0.6 * 0.72 * run.box),
        ),
      );
    }
    return PlateSpec(
      id: id,
      country: SenegalCountry.senegal,
      canvasWidth: _Layout.width,
      canvasHeight: height,
      panel: panel ?? const PlatePanel(box: PlateBox(0, 0, 0, 0)),
      noPanel: panel == null,
      background: background,
      slots: slots,
      labels: <PlateLabel>[
        for (final mark in marks)
          PlateLabel(
            text: mark.text,
            box: PlateBox(
              mark.cx - _Layout.markWidth / 2,
              mark.cy - mark.box / 2,
              _Layout.markWidth,
              mark.box,
            ),
            glyphHeight: mark.box,
          ),
      ],
      textGroups: groups,
    );
  }
}
