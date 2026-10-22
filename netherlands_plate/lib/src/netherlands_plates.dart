import 'dart:math' as math;

import 'package:plate_alphabet/plate_alphabet.dart';
import 'package:plate_core/plate_core.dart';

import 'netherlands_country.dart';

/// Where the ink sits, in plate units. Each reference was flattened to the
/// 520×110 mm of a Dutch plate (4 px per unit) and projected onto each axis.
///
/// EU panel (`Dutch_plate_yellow_NL_code_10`): blue x 0–49, running the full
/// height to the plate edge, so it is painted in the background, not boxed.
///
/// Ink y 18–91.25 (73 tall, centre 54.6). Ink is about 0.55 of a box, so 73
/// would need a 133 box on a 110 canvas; the box is the canvas height and the
/// ink lands at ~60, about 83 % of the reference.
///
/// Dash (same plate): x 144.5–162.5, y 46.75–56 (18 × 9.25), centred in the
/// gap between two fields.
///
/// Field x spans are the measured `glyphs@x-span` of each `Dutch_plate_yellow_
/// NL_code_*` row: first run is the panel, the next three the fields. Printed
/// pitch is ~54 (two glyphs 105 wide, three 160), so `spacing` is
/// `54 - 0.6 * 0.72 * 110`.
abstract final class _Layout {
  static const double width = 520, height = 110;
  static const double panelEnd = 49;
  static const PlateBox panelBox = PlateBox(0, 0, panelEnd, height);

  static const double pitch = 54;
  static final double spacing = math.max(0, pitch - 0.6 * 0.72 * height);

  static const double dashWidth = 18, dashHeight = 9.25, dashTop = 46.75;
}

enum _Kind { letters, digits }

/// One printed field: its kind, shortest and longest length, and measured ink
/// x span (of the longest value the reference shows).
class _Field {
  const _Field(this.kind, this.length, this.left, this.right, {int? min})
    : minLength = min ?? length;

  final _Kind kind;
  final int length, minLength;
  final double left, right;

  PlateSlot get slot {
    final bool fixed = minLength == length;
    final double centre = (left + right) / 2;
    final double w = length * _Layout.pitch;
    return PlateSlot(
      alphabet: kind == _Kind.letters ? NetherlandsAlphabets.letters : NetherlandsAlphabets.digits,
      box: PlateBox(centre - w / 2, 0, w, _Layout.height),
      length: length,
      minLength: minLength,
      spacing: fixed ? _Layout.spacing : 0,
    );
  }
}

const _Kind _l = _Kind.letters;
const _Kind _d = _Kind.digits;

/// The Dutch plates. Groups `a`, `b`, `c`, one per field.
///
/// Every field is one slot, the dashes painted rules between them. The nine
/// sidecode designs (6–14 in the article) differ only in which fields are
/// letters or digits and how long they are, so they are one builder with a
/// field list. The special plates share it too: [royal], [trailer], [special]
/// (`BN`, `GV`, `ZZ`: two letters and two pairs of digits), [diplomatic]
/// (`CD`, no EU panel), [consular] (`CDJ`), the green [dealer] plate and the
/// [bfg] plate, which separates its fields with spaces.
///
/// Dealer and BFG spans are the standard pitch laid from the photographed
/// start (250 px photographs), not measured runs.
///
/// Not implemented: the pre-1999 sidecodes 1–5 and the light-blue 1973–78
/// plates (historical), the blue taxi and electric-scooter plates and the
/// white/black classic plates (no reference), motorcycles (a two-row plate
/// with no documented size), military, RC and Utrecht plates (references too
/// distorted to measure), and the Caribbean plates (North American size, no
/// EU panel).
abstract final class NetherlandsPlates {
  /// `99-XX-XX`, 1999–2008.
  static final PlateSpec sidecode6 = _plate('nl.sidecode6', const <_Field>[
    _Field(_d, 2, 79.8, 182),
    _Field(_l, 2, 224, 328.5),
    _Field(_l, 2, 370, 474.5),
  ]);

  /// `99-XXX-9`, 2006–.
  static final PlateSpec sidecode7 = _plate('nl.sidecode7', const <_Field>[
    _Field(_d, 2, 87.5, 189.8),
    _Field(_l, 3, 231.8, 394.2),
    _Field(_d, 1, 436.5, 481),
  ]);

  /// `9-XXX-99`.
  static final PlateSpec sidecode8 = _plate('nl.sidecode8', const <_Field>[
    _Field(_d, 1, 85.2, 129.8),
    _Field(_l, 3, 171.8, 333.8),
    _Field(_d, 2, 376.2, 479),
  ]);

  /// `XX-999-X`.
  static final PlateSpec sidecode9 = _plate('nl.sidecode9', const <_Field>[
    _Field(_l, 2, 85.2, 188.8),
    _Field(_d, 3, 231, 391.8),
    _Field(_l, 1, 434.5, 480.8),
  ]);

  /// `X-999-XX`, 2011–.
  static final PlateSpec sidecode10 = _plate('nl.sidecode10', const <_Field>[
    _Field(_l, 1, 87.2, 133.2),
    _Field(_d, 3, 175.5, 335.5),
    _Field(_l, 2, 377.8, 482.8),
  ]);

  /// `XXX-99-X`, 2015–.
  static final PlateSpec sidecode11 = _plate('nl.sidecode11', const <_Field>[
    _Field(_l, 3, 87.5, 249.2),
    _Field(_d, 2, 291.5, 394.2),
    _Field(_l, 1, 436.8, 483),
  ]);

  /// `X-99-XXX`, 2021–.
  static final PlateSpec sidecode12 = _plate('nl.sidecode12', const <_Field>[
    _Field(_l, 1, 86.5, 133),
    _Field(_d, 2, 175.2, 277.8),
    _Field(_l, 3, 319.8, 482),
  ]);

  /// `9-XX-999`, 2016–.
  static final PlateSpec sidecode13 = _plate('nl.sidecode13', const <_Field>[
    _Field(_d, 1, 85.8, 130),
    _Field(_l, 2, 172.2, 276.5),
    _Field(_d, 3, 318.8, 479),
  ]);

  /// `999-XX-9`, 2016–2020.
  static final PlateSpec sidecode14 = _plate('nl.sidecode14', const <_Field>[
    _Field(_d, 3, 82.8, 243),
    _Field(_l, 2, 285.2, 389.5),
    _Field(_d, 1, 431.8, 476.2),
  ]);

  /// `AA-86`: two letters and two or three digits (`AA-??` or `AA-???`).
  static final PlateSpec royal = _plate('nl.royal', const <_Field>[
    _Field(_l, 2, 152.2, 273.8),
    _Field(_d, 3, 311, 418.8, min: 2),
  ]);

  /// `WX-12-NZ` / `OK-11-YJ`: trailers (`W`) and semi-trailers (`O`).
  static final PlateSpec trailer = _plate('nl.trailer', const <_Field>[
    _Field(_l, 2, 97.8, 195.8),
    _Field(_d, 2, 237.8, 335.8),
    _Field(_l, 2, 377.8, 475.8),
  ]);

  /// `GV-78-54`, `BN-91-89`, `ZZ-85-21`: two letters, two pairs of digits.
  static final PlateSpec special = _plate('nl.special', const <_Field>[
    _Field(_l, 2, 80.2, 185.8),
    _Field(_d, 2, 221.2, 325),
    _Field(_d, 2, 370, 477.5),
  ]);

  /// `CD-79-31`: diplomatic plates carry no EU panel.
  static final PlateSpec diplomatic = _plate('nl.diplomatic', const <_Field>[
    _Field(_l, 2, 51.8, 158.8),
    _Field(_d, 2, 200.8, 307.8),
    _Field(_d, 2, 349.8, 456.8),
  ], panel: false);

  /// `CDJ-253`: International Court of Justice; panel, no dash.
  static final PlateSpec consular = _plate('nl.consular', const <_Field>[
    _Field(_l, 3, 100, 258),
    _Field(_d, 3, 300, 458),
  ]);

  /// `49-47-HA`: dealer plates, green, no EU panel (photograph estimate).
  static final PlateSpec dealer = _plate('nl.dealer', const <_Field>[
    _Field(_d, 2, 52, 156),
    _Field(_d, 2, 198, 302),
    _Field(_l, 2, 344, 448),
  ], panel: false);

  /// `EM 818 N`: BFG plates, fields set by spaces (photograph estimate).
  static final PlateSpec bfg = _plate('nl.bfg', const <_Field>[
    _Field(_l, 2, 83, 177),
    _Field(_d, 3, 204, 354),
    _Field(_l, 1, 395, 458),
  ], dashes: false);

  static List<PlateSpec> get all => <PlateSpec>[
    sidecode6,
    sidecode7,
    sidecode8,
    sidecode9,
    sidecode10,
    sidecode11,
    sidecode12,
    sidecode13,
    sidecode14,
    royal,
    trailer,
    special,
    diplomatic,
    consular,
    dealer,
    bfg,
  ];

  static PlateSpec _plate(String id, List<_Field> fields, {bool panel = true, bool dashes = true}) {
    final bool hasDash = dashes && fields.length > 1;
    return PlateSpec(
      id: id,
      country: NetherlandsCountry.netherlands,
      canvasWidth: _Layout.width,
      canvasHeight: _Layout.height,
      panel: PlatePanel(box: panel ? _Layout.panelBox : const PlateBox(0, 0, 0, 0)),
      noPanel: !panel,
      background: PlateSection.columns(<PlatePart>[
        if (panel) ...const <PlatePart>[
          PlatePart(PlateSection.fill(PlateFill.panel), end: _Layout.panelEnd),
        ],
        const PlatePart(PlateSection.plain),
      ]),
      slots: <PlateSlot>[for (final _Field f in fields) f.slot],
      rules: <PlateRule>[
        if (hasDash)
          for (int i = 0; i + 1 < fields.length; i++)
            PlateRule(
              box: PlateBox(
                (fields[i].right + fields[i + 1].left) / 2 - _Layout.dashWidth / 2,
                _Layout.dashTop,
                _Layout.dashWidth,
                _Layout.dashHeight,
              ),
            ),
      ],
      textGroups: <PlateTextGroup>[
        for (int i = 0; i < fields.length; i++)
          PlateTextGroup(<int>[i], key: String.fromCharCode(0x61 + i)),
      ],
    );
  }
}
