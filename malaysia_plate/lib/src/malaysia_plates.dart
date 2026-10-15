import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

import 'malaysia_alphabets.dart';
import 'malaysia_colors.dart';
import 'malaysia_country.dart';
import 'malaysia_regions.dart';

/// Where the ink sits on a Malaysian plate, in millimetres.
///
/// The article gives no plate dimensions. The JPJ specification sheet gives
/// the characters — Arial Bold, 70 mm tall, 40 mm wide — so every photo was
/// scaled by its measured cap height (70 mm) and the rest read off in mm:
///
/// * QAB 8557 K (unframed): plate 471×98; first ink 47.5 from the left, last
///   44 from the right; 15 above, 13 below; glyphs ~37 wide; digit pitch 40;
///   prefix→number gap 26.7 of ink.
/// * Penang PFQ 5217: letter pitch 41.3, digit pitch 42.7, gap 28.
/// * QAF/6229 (two-row): plate 247×173; rows of ink at y 16–86 and 88–158.
/// * 99-64-DC (diplomatic): condensed glyphs ~25 wide at pitch ~31, hyphens
///   ~7 wide, 11.6 from the left edge.
/// * The JPJePlate artwork, its 1241×251 px interior mapped to 520×110.
///
/// **Under-height ink, accepted.** 70 mm of ink would need a 133 mm slot on a
/// 98 mm plate (`glyphStyle` sets 0.72 of the slot, and a bold cap is ~0.73 of
/// that). Slots here are as tall as the plate allows, and the glyph is then
/// width-limited by the 40 mm cell, because DejaVu Bold is wider than Arial
/// Bold. The serial reads ~70% of reference height; `plate_core` is unchanged.
abstract final class _Layout {
  // Single row.
  static const double height = 98;
  static const double slotTop = 2;
  static const double slotHeight = 94;
  static const double leftMargin = 46;
  static const double rightMargin = 42;
  static const double letterPitch = 41;
  static const double digitPitch = 40;

  /// Cell-to-cell gap between prefix and number: the 26.7 mm ink gap less the
  /// ~1.5 mm of air either glyph has in its cell.
  static const double wordGap = 24;

  /// Number→suffix gap, chosen so QAB 8557 K comes out at its measured 471.
  static const double suffixGap = 35;

  // Two row.
  static const double twoRowWidth = 247;
  static const double twoRowHeight = 173;
  static const double row1Top = 4;
  static const double row2Top = 88;
  static const double rowHeight = 82;

  // Diplomatic NN-NN-XX.
  static const double dipWidth = 236;
  static const double dipLeft = 10;
  static const double dipPitch = 31;
  static const double hyphenWidth = 14;

  /// A label is not shrunk to its box; this prints a ~9 mm dash, near the
  /// photo's ~7.
  static const double hyphenGlyph = 30;

  // JPJePlate.
  static const double evWidth = 520;
  static const double evHeight = 110;
  static const double evGreenEnd = 46.1;
  static const double evStripEnd = 56.5;

  /// The serial's span: the artwork's ink runs 68.7..490.3, and a shorter
  /// serial is centred in it.
  static const double evSerialLeft = 66;
  static const double evSerialRight = 493;
  static const double evSlotTop = 4;
  static const double evSlotHeight = 104;
  static const double evLetterPitch = 50.4;
  static const double evDigitPitch = 54.4;

  /// 32.7 of ink between WIKI and 1234, less each glyph's air in its cell.
  static const double evGap = 22;
}

/// Malaysia's plate geometries.
///
/// * [singleRow] — the standard plate. White on black for private cars and
///   the military, black on white for taxis: the theme, not the spec.
///   Malaysian plates are made to the registration, so the canvas width is
///   derived from the content, as on German plates.
/// * [twoRow] — the 247×173 rear/motorcycle plate, prefix over number.
/// * [diplomatic] — `NN-NN-DC`, condensed characters, one row 236 wide.
/// * [ev] — the 2024 JPJePlate: European 520×110, green strip with flag and
///   `MAL` at the left, a grey security strip beside it, black on white.
///
/// Every spec has the text groups `prefix`, `number` and, when present,
/// `suffix` (diplomatic: `country`, `serial`, `mission`).
abstract final class MalaysiaPlates {
  static const int maxPrefix = 3;
  static const int maxDigits = 4;

  static final Map<String, PlateSpec> _cache = <String, PlateSpec>{};

  /// The single-row plate, with or without a suffix letter. The canvas is
  /// sized for three letters and four digits; a shorter field centres in its
  /// box.
  static PlateSpec singleRow({bool suffix = false}) =>
      _cache['single$suffix'] ??= _singleRowSpec(suffix);

  /// The two-row plate.
  static PlateSpec twoRow({bool suffix = false}) =>
      _cache['two$suffix'] ??= _twoRowSpec(suffix);

  /// The JPJePlate.
  static PlateSpec ev({bool suffix = false}) =>
      _cache['ev$suffix'] ??= _evSpec(suffix);

  static List<PlateTextGroup> _groups(bool suffix) => <PlateTextGroup>[
    const PlateTextGroup(<int>[0], key: 'prefix'),
    const PlateTextGroup(<int>[1], key: 'number'),
    if (suffix) const PlateTextGroup(<int>[2], key: 'suffix'),
  ];

  /// One slot of up to [count] cells at [pitch] from [left], its glyphs
  /// spaced to the pitch.
  static PlateSlot _field(
    PlateAlphabet alphabet,
    int count,
    double pitch,
    double left,
    double top,
    double height, {
    int minLength = 1,
  }) => PlateSlot(
    alphabet: alphabet,
    box: PlateBox(left, top, count * pitch, height),
    length: count,
    minLength: minLength,
    spacing: max(0, pitch - 0.6 * 0.72 * height),
  );

  /// Prefix, number and an optional suffix in one row from [left].
  static List<PlateSlot> _row(
    bool suffix, {
    required double left,
    required double top,
    required double height,
    required double letterPitch,
    required double digitPitch,
    required double gap,
    required double suffixGap,
  }) {
    final double numberLeft = left + maxPrefix * letterPitch + gap;
    final double numberRight = numberLeft + maxDigits * digitPitch;
    return <PlateSlot>[
      _field(
        MalaysiaAlphabets.letters,
        maxPrefix,
        letterPitch,
        left,
        top,
        height,
      ),
      _field(
        MalaysiaAlphabets.digits,
        maxDigits,
        digitPitch,
        numberLeft,
        top,
        height,
      ),
      if (suffix)
        _field(
          MalaysiaAlphabets.letters,
          1,
          letterPitch,
          numberRight + suffixGap,
          top,
          height,
        ),
    ];
  }

  static double _rowWidth(
    bool suffix,
    double letterPitch,
    double digitPitch,
    double gap,
    double suffixGap,
  ) =>
      maxPrefix * letterPitch +
      gap +
      maxDigits * digitPitch +
      (suffix ? suffixGap + letterPitch : 0);

  static String _id(String form, bool suffix) =>
      'my.$form.${suffix ? 'suffix' : 'plain'}';

  static PlateSpec _singleRowSpec(bool suffix) {
    final double content = _rowWidth(
      suffix,
      _Layout.letterPitch,
      _Layout.digitPitch,
      _Layout.wordGap,
      _Layout.suffixGap,
    );
    return PlateSpec(
      id: _id('single', suffix),
      country: MalaysiaCountry.malaysia,
      canvasWidth: _Layout.leftMargin + content + _Layout.rightMargin,
      canvasHeight: _Layout.height,
      noPanel: true,
      panel: const PlatePanel(box: PlateBox(0, 0, 0, _Layout.height)),
      slots: _row(
        suffix,
        left: _Layout.leftMargin,
        top: _Layout.slotTop,
        height: _Layout.slotHeight,
        letterPitch: _Layout.letterPitch,
        digitPitch: _Layout.digitPitch,
        gap: _Layout.wordGap,
        suffixGap: _Layout.suffixGap,
      ),
      textGroups: _groups(suffix),
      resolveRegion: MalaysiaRegions.captionOf,
    );
  }

  /// Prefix centred on the top row; number and suffix centred on the bottom.
  static PlateSpec _twoRowSpec(bool suffix) {
    final double prefixWidth = maxPrefix * _Layout.letterPitch;
    final double lowerWidth =
        maxDigits * _Layout.digitPitch +
        (suffix ? _Layout.wordGap + _Layout.letterPitch : 0);
    final double lowerLeft = (_Layout.twoRowWidth - lowerWidth) / 2;
    final double numberRight = lowerLeft + maxDigits * _Layout.digitPitch;
    return PlateSpec(
      id: _id('twoRow', suffix),
      country: MalaysiaCountry.malaysia,
      canvasWidth: _Layout.twoRowWidth,
      canvasHeight: _Layout.twoRowHeight,
      noPanel: true,
      panel: const PlatePanel(box: PlateBox(0, 0, 0, _Layout.twoRowHeight)),
      slots: <PlateSlot>[
        _field(
          MalaysiaAlphabets.letters,
          maxPrefix,
          _Layout.letterPitch,
          (_Layout.twoRowWidth - prefixWidth) / 2,
          _Layout.row1Top,
          _Layout.rowHeight,
        ),
        _field(
          MalaysiaAlphabets.digits,
          maxDigits,
          _Layout.digitPitch,
          lowerLeft,
          _Layout.row2Top,
          _Layout.rowHeight,
        ),
        if (suffix)
          _field(
            MalaysiaAlphabets.letters,
            1,
            _Layout.letterPitch,
            numberRight + _Layout.wordGap,
            _Layout.row2Top,
            _Layout.rowHeight,
          ),
      ],
      textGroups: _groups(suffix),
      resolveRegion: MalaysiaRegions.captionOf,
    );
  }

  static PlateSpec _evSpec(bool suffix) {
    final double content = _rowWidth(
      suffix,
      _Layout.evLetterPitch,
      _Layout.evDigitPitch,
      _Layout.evGap,
      _Layout.evGap,
    );
    final double span = _Layout.evSerialRight - _Layout.evSerialLeft;
    return PlateSpec(
      id: _id('ev', suffix),
      country: MalaysiaCountry.malaysia,
      canvasWidth: _Layout.evWidth,
      canvasHeight: _Layout.evHeight,
      // Flag 4.6..41.4 × 13.1..33.6 in the artwork. The padding pins it to
      // the top of the strip; the panel would centre a caption in the space
      // left below, so MAL is a label at its measured place instead.
      panel: const PlatePanel(
        box: PlateBox(0, 0, _Layout.evGreenEnd, _Layout.evHeight),
        padding: EdgeInsets.fromLTRB(4.6, 13, 4.7, 76),
      ),
      labels: const <PlateLabel>[
        // MAL ink 6.7..39.4 × 82.1..93.4: 11.3 tall over the ~0.525 ink ratio.
        PlateLabel(
          text: 'MAL',
          box: PlateBox(4.6, 80, 36.8, 16),
          glyphHeight: 21.5,
          color: MalaysiaColors.darkInk,
        ),
      ],
      background: const PlateSection.columns(<PlatePart>[
        PlatePart(PlateSection.fill(PlateFill.panel), end: _Layout.evGreenEnd),
        PlatePart(
          PlateSection.fill(PlateFill.color(Color(0xFFF1F1F1))),
          end: _Layout.evStripEnd,
        ),
        PlatePart(PlateSection.plain),
      ]),
      slots: _row(
        suffix,
        left: _Layout.evSerialLeft + (span - content) / 2,
        top: _Layout.evSlotTop,
        height: _Layout.evSlotHeight,
        letterPitch: _Layout.evLetterPitch,
        digitPitch: _Layout.evDigitPitch,
        gap: _Layout.evGap,
        suffixGap: _Layout.evGap,
      ),
      textGroups: _groups(suffix),
      resolveRegion: MalaysiaRegions.captionOf,
    );
  }

  static PlateBox _hyphen(double left) =>
      PlateBox(left, _Layout.slotTop, _Layout.hyphenWidth, _Layout.slotHeight);

  /// `NN-NN-XX`: the mission's country number, its vehicle number, and the
  /// mission code. The code is one chosen slot two cells wide, since `DC` is
  /// one value to pick and two glyphs on the face.
  static final PlateSpec diplomatic = () {
    const double l = _Layout.dipLeft;
    const double p = _Layout.dipPitch;
    const double h = _Layout.hyphenWidth;
    const double serialLeft = l + 2 * p + h;
    const double missionLeft = serialLeft + 2 * p + h;
    return PlateSpec(
      id: 'my.diplomatic',
      country: MalaysiaCountry.malaysia,
      canvasWidth: _Layout.dipWidth,
      canvasHeight: _Layout.height,
      noPanel: true,
      panel: const PlatePanel(box: PlateBox(0, 0, 0, _Layout.height)),
      slots: <PlateSlot>[
        _field(
          MalaysiaAlphabets.digits,
          2,
          p,
          l,
          _Layout.slotTop,
          _Layout.slotHeight,
          minLength: 2,
        ),
        _field(
          MalaysiaAlphabets.digits,
          2,
          p,
          serialLeft,
          _Layout.slotTop,
          _Layout.slotHeight,
          minLength: 2,
        ),
        const PlateSlot(
          alphabet: MalaysiaAlphabets.missionCodes,
          box: PlateBox(
            missionLeft,
            _Layout.slotTop,
            2 * _Layout.dipPitch,
            _Layout.slotHeight,
          ),
        ),
      ],
      labels: <PlateLabel>[
        PlateLabel(
          text: '-',
          box: _hyphen(l + 2 * p),
          glyphHeight: _Layout.hyphenGlyph,
        ),
        PlateLabel(
          text: '-',
          box: _hyphen(serialLeft + 2 * p),
          glyphHeight: _Layout.hyphenGlyph,
        ),
      ],
      textGroups: const <PlateTextGroup>[
        PlateTextGroup(<int>[0], key: 'country'),
        PlateTextGroup(<int>[1], key: 'serial'),
        PlateTextGroup(<int>[2], key: 'mission'),
      ],
    );
  }();
}
