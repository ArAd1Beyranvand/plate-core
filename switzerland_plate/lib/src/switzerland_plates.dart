import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:plate_alphabet/plate_alphabet.dart';
import 'package:plate_core/plate_core.dart';

import 'switzerland_colors.dart';
import 'switzerland_country.dart';
import 'switzerland_missions.dart';
import 'switzerland_regions.dart';

/// Where the ink sits, in the flat unit the offline stage rectified every
/// photograph to (520 × 256 per plate, normalised non-uniformly), and how it
/// maps to a canvas.
///
/// A canvas is 1.6 × the physical size in mm: high rear 300 × 160, long rear
/// 500 × 110, front 300 × 80. The motorcycle (352 × 256) and scooter
/// (310 × 256) are from the measured photo aspects 1.375 and 1.21: the article
/// gives no size. A flat x maps to `x · width / 520`, a flat y to
/// `y · height / 256`.
///
/// The ink rows and columns are the dark-pixel extents of the flat images.
/// Ink is ~0.55 of the slot (`glyphStyle`: 0.72 of the slot, caps ~0.76 of
/// that), so a slot is the ink divided by 0.55 and centred on the ink. The
/// long and front canvases are too short for that: the box is clamped to the
/// canvas, so rendered ink is ~70–84% of the reference there.
///
/// A fixed field's `spacing` is `max(0, pitch - 0.6 · 0.72 · height)` with the
/// pitch taken as the span over the length; a variable field has none.
///
/// The cantonal arms printed on the right of the high and small plates are
/// not drawn: they are a different art for each canton and none was
/// obtainable. The shield is drawn by hand.
abstract final class _Layout {
  static const double flatWidth = 520;
  static const double flatHeight = 256;
  static const double inkRatio = 0.55;
  static const double glyphRatio = 0.72;

  static const double highWidth = 480, highHeight = 256;
  static const double longWidth = 800, longHeight = 176;
  static const double frontWidth = 480, frontHeight = 128;
  static const double motoWidth = 352, scooterWidth = 310, smallHeight = 256;

  // High rear: shield x 64–135, y 18.5–103.5; canton ink x 203–317, y
  // 18–104.2; number ink y 125.2–238, 5 digits x 75–444 (a 6th would reach
  // 37.5–481.5).
  static const List<double> highShield = <double>[64, 18.5, 135, 103.5];
  static const List<double> highCanton = <double>[203, 317, 18, 104.2];
  static const List<double> highNumber = <double>[37.5, 481.5, 125.2, 238];

  // Dealer: canton x 205–319, y 17.8–93.2; digits y 117.5–238, 4 digits
  // x 46–337; dot x 370–386; `U` x 418–481.
  static const List<double> dealerCanton = <double>[205, 319, 17.8, 93.2];
  static const List<double> dealerNumber = <double>[46, 337, 117.5, 238];
  static const List<double> dealerDot = <double>[370, 386, 117.5, 238];
  static const List<double> dealerMark = <double>[418, 481, 117.5, 238];

  // Temporary: canton x 206–316, y 22–114.5; number x 54–397, y 146.2–238;
  // sticker x 430–482, y 148–237.5, in a ~5 wide red rim.
  static const List<double> tempCanton = <double>[206, 316, 22, 114.5];
  static const List<double> tempNumber = <double>[54, 397, 146.2, 238];
  static const List<double> tempSticker = <double>[430, 148, 482, 237.5];
  static const double tempRim = 5;

  // Long rear: shield x 12–52, y 65.5–190.5; letters x 62–146; dot 158–169;
  // number x 185–459; ink y 44.5–214.5. The red and military plates share the
  // geometry (estimated from unrectified originals).
  static const List<double> longShield = <double>[12, 65.5, 52, 190.5];
  static const List<double> longCanton = <double>[62, 146, 44.5, 214.5];
  static const List<double> longDot = <double>[158, 169, 44.5, 214.5];
  static const List<double> longNumber = <double>[185, 459, 44.5, 214.5];

  // Front (the 1999 green plate): canton x 64–168, dot 198–208, number from
  // 245 (4 digits to 451; widened to 505 for 6), ink y 45.5–198. The shield
  // is not measured; it is placed left of the canton.
  static const List<double> frontShield = <double>[12, 75, 54, 168];
  static const List<double> frontCanton = <double>[64, 168, 45.5, 198];
  static const List<double> frontDot = <double>[198, 208, 45.5, 198];
  static const List<double> frontNumber = <double>[245, 505, 45.5, 198];

  // Customs: shield x 58–96, y 57–192; canton 128–210; dot 222–232; number
  // measured at one digit over 245–281, here up to two over 240–292; sticker
  // x 296–332, y 34–227.5; `Z` 347–384; ink y 37–226.2.
  static const List<double> customsShield = <double>[58, 57, 96, 192];
  static const List<double> customsCanton = <double>[128, 210, 37, 226.2];
  static const List<double> customsDot = <double>[222, 232, 37, 226.2];
  static const List<double> customsNumber = <double>[240, 292, 37, 226.2];
  static const List<double> customsSticker = <double>[296, 34, 332, 227.5];
  static const List<double> customsMark = <double>[347, 384, 37, 226.2];

  // Small (motorcycle, scooter): shield x 27–117, y 28.5–104; canton row
  // ink y 17.8–115.8, centred on x 260; number row y 131.8–238, 5 digits
  // x 29–490. The scooter reuses the motorcycle rows (its photo could not be
  // rectified), on a narrower canvas.
  static const List<double> smallShield = <double>[27, 28.5, 117, 104];
  static const List<double> smallCanton = <double>[203, 317, 17.8, 115.8];
  static const List<double> smallNumber = <double>[29, 490, 131.8, 238];

  // Diplomatic (CD, CC): ink y ~44–205, band letters ~27–193.
  static const double dipTop = 44, dipBottom = 205;
  static const double dipPrefixTop = 27, dipPrefixBottom = 193;
}

/// One canvas and the maps from the flat unit into it.
class _Frame {
  const _Frame(this.width, this.height);

  final double width, height;

  double x(double v) => v * width / _Layout.flatWidth;
  double y(double v) => v * height / _Layout.flatHeight;

  PlateBox area(List<double> r) => PlateBox(x(r[0]), y(r[1]), x(r[2]) - x(r[0]), y(r[3]) - y(r[1]));

  /// A slot box over flat columns [r]`[0]..[1]` for ink rows [r]`[2]..[3]`.
  PlateBox slotBox(List<double> r) {
    final double centre = y((r[2] + r[3]) / 2);
    final double room = 2 * min(centre, height - centre);
    final double h = min(y(r[3] - r[2]) / _Layout.inkRatio, room);
    return PlateBox(x(r[0]), centre - h / 2, x(r[1]) - x(r[0]), h);
  }

  /// A field of [alphabet] over [r]; fixed when [minLength] is [length].
  PlateSlot field(
    PlateAlphabet alphabet,
    List<double> r, {
    int length = 1,
    int? minLength,
    Color? color,
  }) {
    final PlateBox box = slotBox(r);
    final bool fixed = (minLength ?? length) == length && length > 1;
    final double pitch = box.width / length;
    return PlateSlot(
      alphabet: alphabet,
      box: box,
      length: length,
      minLength: minLength,
      color: color,
      spacing: fixed ? max(0, pitch - 0.6 * _Layout.glyphRatio * box.height) : 0,
    );
  }

  /// The separator dot over [r], a middle dot in the ink colour.
  PlateLabel dot(List<double> r) {
    final PlateBox box = slotBox(r);
    return PlateLabel(text: '•', box: box, glyphHeight: box.height * 0.5);
  }

  PlateDecal shield(List<double> r) => PlateDecal(
    image: const AssetImage('assets/icons/swiss_shield.png', package: 'switzerland_plate'),
    box: area(r),
  );
}

/// Switzerland's current plates.
///
/// * [high] — the 300 × 160 rear plate, canton over number; [dealer] and
///   [temporary] are the same canvas with a `U` mark or a sticker.
/// * [long] — the 500 × 110 rear plate on one line; [military] opens with a
///   lone `M`.
/// * [front] — 300 × 80.
/// * [customs] — duty-unpaid plate: canton, control number, sticker, `Z`.
/// * [motorcycle], [scooter] — canton over a five-digit number.
/// * [diplomatic], [consular] — `CD` / `CC` band, canton, serial, country
///   code. Code 7 is refused; see [SwitzerlandMissions].
///
/// The colour is the theme: utility blue, exceptional gold and the red
/// bicycle-carrier plate are [high] or [long] with the matching
/// `SwitzerlandThemes` livery.
///
/// Not implemented: moped and Segway plates (their photographs could not be
/// rectified and have no artwork), the discontinued Administration (`A`) and
/// PTT/SBB (`P`) plates, the `AT` diplomatic prefix (no picture), and the
/// 3 + 3 digit gap of the red plate.
abstract final class SwitzerlandPlates {
  static const String cantonKey = 'canton';
  static const String numberKey = 'number';
  static const String markKey = 'mark';
  static const String stickerKey = 'sticker';
  static const String prefixKey = 'prefix';
  static const String serialKey = 'serial';
  static const String codeKey = 'code';

  static PlateSpec _spec(
    String id,
    _Frame f, {
    required List<PlateSlot> slots,
    required List<String> keys,
    List<PlateDecal> decals = const <PlateDecal>[],
    List<PlateLabel> labels = const <PlateLabel>[],
    List<PlateBand> bands = const <PlateBand>[],
    PlateSection background = PlateSection.plain,
    List<PlateRestriction> restrictions = const <PlateRestriction>[],
  }) => PlateSpec(
    id: id,
    country: SwitzerlandCountry.switzerland,
    canvasWidth: f.width,
    canvasHeight: f.height,
    noPanel: true,
    panel: PlatePanel(box: PlateBox(0, 0, 0, f.height)),
    background: background,
    slots: slots,
    textGroups: <PlateTextGroup>[
      for (int i = 0; i < keys.length; i++) PlateTextGroup(<int>[i], key: keys[i]),
    ],
    decals: decals,
    labels: labels,
    bands: bands,
    restrictions: restrictions,
    resolveRegion: SwitzerlandRegions.captionOf,
  );

  static const _Frame _high = _Frame(_Layout.highWidth, _Layout.highHeight);
  static const _Frame _long = _Frame(_Layout.longWidth, _Layout.longHeight);
  static const _Frame _front = _Frame(_Layout.frontWidth, _Layout.frontHeight);
  static const _Frame _moto = _Frame(_Layout.motoWidth, _Layout.smallHeight);
  static const _Frame _scooter = _Frame(_Layout.scooterWidth, _Layout.smallHeight);

  static PlateSlot _canton(_Frame f, List<double> r, {int minLength = 2}) =>
      f.field(SwitzerlandAlphabets.letters, r, length: 2, minLength: minLength);

  /// `GE 123456`: canton, then one to six digits. Groups `canton`, `number`.
  static final PlateSpec high = _spec(
    'ch.high',
    _high,
    slots: <PlateSlot>[
      _canton(_high, _Layout.highCanton),
      _high.field(SwitzerlandAlphabets.digits, _Layout.highNumber, length: 6, minLength: 1),
    ],
    keys: const <String>[cantonKey, numberKey],
    decals: <PlateDecal>[_high.shield(_Layout.highShield)],
  );

  /// `GE 1234 • U`: a dealer's plate. Groups `canton`, `number`, `mark`.
  static final PlateSpec dealer = _spec(
    'ch.dealer',
    _high,
    slots: <PlateSlot>[
      _canton(_high, _Layout.dealerCanton),
      _high.field(SwitzerlandAlphabets.digits, _Layout.dealerNumber, length: 4, minLength: 1),
      _high.field(SwitzerlandAlphabets.dealerMark, _Layout.dealerMark),
    ],
    keys: const <String>[cantonKey, numberKey, markKey],
    decals: <PlateDecal>[_high.shield(_Layout.highShield)],
    labels: <PlateLabel>[_high.dot(_Layout.dealerDot)],
  );

  /// A temporary plate with its validity sticker (the month). Groups
  /// `canton`, `number`, `sticker`.
  static final PlateSpec temporary = _spec(
    'ch.temporary',
    _high,
    slots: <PlateSlot>[
      _canton(_high, _Layout.tempCanton),
      _high.field(SwitzerlandAlphabets.digits, _Layout.tempNumber, length: 5, minLength: 1),
      _high.field(
        SwitzerlandAlphabets.digits,
        <double>[
          _Layout.tempSticker[0] + _Layout.tempRim,
          _Layout.tempSticker[2] - _Layout.tempRim,
          _Layout.tempSticker[1] + _Layout.tempRim,
          _Layout.tempSticker[3] - _Layout.tempRim,
        ],
        length: 2,
        minLength: 1,
      ),
    ],
    keys: const <String>[cantonKey, numberKey, stickerKey],
    decals: <PlateDecal>[_high.shield(_Layout.highShield)],
    bands: <PlateBand>[
      PlateBand(box: _high.area(_Layout.tempSticker), color: SwitzerlandColors.stickerRed),
      PlateBand(
        box: _high.area(<double>[
          _Layout.tempSticker[0] + _Layout.tempRim,
          _Layout.tempSticker[1] + _Layout.tempRim,
          _Layout.tempSticker[2] - _Layout.tempRim,
          _Layout.tempSticker[3] - _Layout.tempRim,
        ]),
        color: SwitzerlandColors.white,
      ),
    ],
  );

  static PlateSpec _longPlate(String id, {required int cantonMin}) => _spec(
    id,
    _long,
    slots: <PlateSlot>[
      _canton(_long, _Layout.longCanton, minLength: cantonMin),
      _long.field(SwitzerlandAlphabets.digits, _Layout.longNumber, length: 6, minLength: 1),
    ],
    keys: const <String>[cantonKey, numberKey],
    decals: <PlateDecal>[_long.shield(_Layout.longShield)],
    labels: <PlateLabel>[_long.dot(_Layout.longDot)],
  );

  /// `GE • 123456` on one line. Groups `canton`, `number`. The red
  /// bicycle-carrier plate is this spec with `SwitzerlandThemes.red`.
  static final PlateSpec long = _longPlate('ch.long', cantonMin: 2);

  /// The military plate: a lone `M` or a two-letter prefix, then the number.
  static final PlateSpec military = _longPlate('ch.military', cantonMin: 1);

  /// The 300 × 80 front plate. Groups `canton`, `number`.
  static final PlateSpec front = _spec(
    'ch.front',
    _front,
    slots: <PlateSlot>[
      _canton(_front, _Layout.frontCanton),
      _front.field(SwitzerlandAlphabets.digits, _Layout.frontNumber, length: 6, minLength: 1),
    ],
    keys: const <String>[cantonKey, numberKey],
    decals: <PlateDecal>[_front.shield(_Layout.frontShield)],
    labels: <PlateLabel>[_front.dot(_Layout.frontDot)],
  );

  /// Duty-unpaid plate: canton, one or two digits, sticker, `Z`. Groups
  /// `canton`, `number`, `mark`.
  static final PlateSpec customs = _spec(
    'ch.customs',
    _long,
    slots: <PlateSlot>[
      _canton(_long, _Layout.customsCanton),
      _long.field(SwitzerlandAlphabets.digits, _Layout.customsNumber, length: 2, minLength: 1),
      _long.field(SwitzerlandAlphabets.customsMark, _Layout.customsMark),
    ],
    keys: const <String>[cantonKey, numberKey, markKey],
    decals: <PlateDecal>[_long.shield(_Layout.customsShield)],
    labels: <PlateLabel>[_long.dot(_Layout.customsDot)],
    bands: <PlateBand>[
      PlateBand(box: _long.area(_Layout.customsSticker), color: SwitzerlandColors.customsRed),
    ],
  );

  static PlateSpec _small(String id, _Frame f) => _spec(
    id,
    f,
    slots: <PlateSlot>[
      _canton(f, _Layout.smallCanton),
      f.field(SwitzerlandAlphabets.digits, _Layout.smallNumber, length: 5, minLength: 1),
    ],
    keys: const <String>[cantonKey, numberKey],
    decals: <PlateDecal>[f.shield(_Layout.smallShield)],
  );

  /// Motorcycle plate, 352 × 256: canton over up to five digits.
  static final PlateSpec motorcycle = _small('ch.motorcycle', _moto);

  /// Scooter plate, 310 × 256; wear `SwitzerlandThemes.scooter`.
  static final PlateSpec scooter = _small('ch.scooter', _scooter);

  /// `CD GE 29 • 201`: band prefix, canton, serial, country code. Groups
  /// `prefix`, `canton`, `serial`, `code`.
  static final PlateSpec diplomatic = _diplomatic(
    'ch.diplomatic',
    alphabet: SwitzerlandAlphabets.diplomaticCd,
    band: SwitzerlandColors.diplomaticBlue,
    bandEnd: 110,
    prefix: <double>[14, 102],
    canton: <double>[119, 202],
    serial: <double>[230, 358],
    code: <double>[405, 493],
    dot: <double>[380, 390],
  );

  /// The `CC` consular plate: the same fields on a green band.
  static final PlateSpec consular = _diplomatic(
    'ch.consular',
    alphabet: SwitzerlandAlphabets.diplomaticCc,
    band: SwitzerlandColors.consularGreen,
    bandEnd: 150,
    prefix: <double>[18, 142],
    canton: <double>[168, 286],
    serial: <double>[303, 352],
    code: <double>[393, 500],
    dot: <double>[366, 375],
  );

  /// The band is a left column running to the plate's edge. Its colour is the
  /// category's own, as a validity band's would be.
  static PlateSpec _diplomatic(
    String id, {
    required PlateAlphabet alphabet,
    required Color band,
    required double bandEnd,
    required List<double> prefix,
    required List<double> canton,
    required List<double> serial,
    required List<double> code,
    required List<double> dot,
  }) {
    List<double> row(List<double> x, double top, double bottom) => <double>[
      x[0],
      x[1],
      top,
      bottom,
    ];
    return _spec(
      id,
      _long,
      slots: <PlateSlot>[
        _long.field(
          alphabet,
          row(prefix, _Layout.dipPrefixTop, _Layout.dipPrefixBottom),
          color: SwitzerlandColors.white,
        ),
        _canton(_long, row(canton, _Layout.dipTop, _Layout.dipBottom)),
        _long.field(
          SwitzerlandAlphabets.digits,
          row(serial, _Layout.dipTop, _Layout.dipBottom),
          length: 3,
          minLength: 1,
        ),
        _long.field(
          SwitzerlandAlphabets.digits,
          row(code, _Layout.dipTop, _Layout.dipBottom),
          length: 3,
          minLength: 1,
        ),
      ],
      keys: const <String>[prefixKey, cantonKey, serialKey, codeKey],
      labels: <PlateLabel>[_long.dot(row(dot, _Layout.dipTop, _Layout.dipBottom))],
      background: PlateSection.columns(<PlatePart>[
        PlatePart(PlateSection.fill(PlateFill.color(band)), end: _long.x(bandEnd)),
        const PlatePart(PlateSection.fill(PlateFill.field)),
      ]),
      restrictions: const <PlateRestriction>[SwitzerlandMissions.restriction],
    );
  }
}
