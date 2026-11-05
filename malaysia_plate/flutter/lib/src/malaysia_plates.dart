import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

import 'malaysia_alphabets.dart';
import 'malaysia_colors.dart';
import 'malaysia_country.dart';
import 'malaysia_regions.dart';

/// Plate geometry in millimetres. The characters are Arial Bold, 70 mm tall
/// and 40 mm wide (JPJ specification sheet); photographs were scaled by their
/// measured cap height and the rest read off.
///
/// **Under-height ink, accepted.** 70 mm of ink would need a 133 mm slot on a
/// 98 mm plate (`glyphStyle` sets 0.72 of the slot, and a bold cap is ~0.73 of
/// that). Slots are as tall as the plate allows and the glyph is then
/// width-limited by the 40 mm cell, because the fallback face is wider than
/// Arial Bold. The serial reads ~70% of reference height.
abstract final class _Layout {
  // Single row.
  static const double height = 98, slotTop = 2, slotHeight = 94;
  static const double leftMargin = 46, rightMargin = 42, letterPitch = 41;
  static const double digitPitch = 40;

  /// Cell-to-cell gap between prefix and number: the ink gap less the air
  /// either glyph has in its cell.
  static const double wordGap = 24;

  /// Number to suffix gap, chosen to match the measured plate width.
  static const double suffixGap = 35;

  // Two row.
  static const double twoRowWidth = 247, twoRowHeight = 173, row1Top = 4;
  static const double row2Top = 88, rowHeight = 82;

  // Diplomatic NN-NN-XX.
  static const double dipWidth = 236, dipLeft = 10, dipPitch = 31;
  static const double hyphenWidth = 14;

  /// A label is not shrunk to its box; this prints a ~9 mm dash.
  static const double hyphenGlyph = 30;

  // JPJePlate.
  static const double evWidth = 520, evHeight = 110, evGreenEnd = 46.1;
  static const double evStripEnd = 56.5;

  /// The serial's span; a shorter serial is centred in it.
  static const double evSerialLeft = 66, evSerialRight = 493, evSlotTop = 4;
  static const double evSlotHeight = 104, evLetterPitch = 50.4;
  static const double evDigitPitch = 54.4;

  /// The measured ink gap less each glyph's air in its cell.
  static const double evGap = 22;
}

/// * [singleRow]: the standard plate; colour is the theme's. The canvas width
///   is derived from the content, since plates are made to the registration.
/// * [twoRow]: the 247×173 rear/motorcycle plate, prefix over number.
/// * [diplomatic]: `NN-NN-DC`, condensed characters, one row 236 wide.
/// * [ev]: the 2024 JPJePlate, 520×110, green strip with flag and `MAL`, then
///   a grey security strip.
///
/// Text groups are `prefix`, `number` and, when present, `suffix` (diplomatic:
/// `country`, `serial`, `mission`).
abstract final class MalaysiaPlates {
  static const int maxPrefix = 3, maxDigits = 4;

  static final Map<String, PlateSpec> _cache = <String, PlateSpec>{};

  /// The canvas is sized for three letters and four digits; a shorter field
  /// centres in its box.
  static PlateSpec singleRow({bool suffix = false}) =>
      _cache['single$suffix'] ??= _singleRowSpec(suffix);

  static PlateSpec twoRow({bool suffix = false}) =>
      _cache['two$suffix'] ??= _twoRowSpec(suffix);

  static PlateSpec ev({bool suffix = false}) =>
      _cache['ev$suffix'] ??= _evSpec(suffix);

  /// Prefix, number and, with [suffix], the suffix letter, as one row.
  static List<PlateRowItem> _serial(
    bool suffix, {
    double letterPitch = _Layout.letterPitch,
    double digitPitch = _Layout.digitPitch,
    double gap = _Layout.wordGap,
    double suffixGap = _Layout.suffixGap,
  }) => <PlateRowItem>[
    ..._prefix(letterPitch),
    PlateRowGap(gap),
    ..._number(suffix, letterPitch, digitPitch, suffixGap),
  ];

  static List<PlateRowItem> _prefix(double letterPitch) => <PlateRowItem>[
    PlateRowRun(
      MalaysiaAlphabets.letters,
      maxPrefix,
      pitch: letterPitch,
      minLength: 1,
      group: 'prefix',
    ),
  ];

  static List<PlateRowItem> _number(
    bool suffix,
    double letterPitch,
    double digitPitch,
    double suffixGap,
  ) => <PlateRowItem>[
    PlateRowRun(
      MalaysiaAlphabets.digits,
      maxDigits,
      pitch: digitPitch,
      minLength: 1,
      group: 'number',
    ),
    if (suffix) ...<PlateRowItem>[
      PlateRowGap(suffixGap),
      PlateRowRun(
        MalaysiaAlphabets.letters,
        1,
        pitch: letterPitch,
        minLength: 1,
        group: 'suffix',
      ),
    ],
  ];

  static String _id(String form, bool suffix) =>
      'my.$form.${suffix ? 'suffix' : 'plain'}';

  static PlateSpec _singleRowSpec(bool suffix) {
    final List<PlateRowItem> items = _serial(suffix);
    return _plain(
      id: _id('single', suffix),
      width:
          _Layout.leftMargin +
          plateRowWidth(items, pitch: _Layout.letterPitch) +
          _Layout.rightMargin,
      height: _Layout.height,
      slots: plateRow(
        items,
        left: _Layout.leftMargin,
        top: _Layout.slotTop,
        height: _Layout.slotHeight,
        pitch: _Layout.letterPitch,
      ).slots,
      resolveRegion: MalaysiaRegions.captionOf,
    );
  }

  static PlateSpec _twoRowSpec(bool suffix) {
    List<PlateSlot> row(List<PlateRowItem> items, double top) => plateRow(
      items,
      centre: _Layout.twoRowWidth / 2,
      top: top,
      height: _Layout.rowHeight,
      pitch: _Layout.letterPitch,
    ).slots;
    return _plain(
      id: _id('twoRow', suffix),
      width: _Layout.twoRowWidth,
      height: _Layout.twoRowHeight,
      slots: <PlateSlot>[
        ...row(_prefix(_Layout.letterPitch), _Layout.row1Top),
        ...row(
          _number(
            suffix,
            _Layout.letterPitch,
            _Layout.digitPitch,
            _Layout.wordGap,
          ),
          _Layout.row2Top,
        ),
      ],
      resolveRegion: MalaysiaRegions.captionOf,
    );
  }

  static PlateSpec _evSpec(bool suffix) => PlateSpec(
    id: _id('ev', suffix),
    country: MalaysiaCountry.malaysia,
    canvasWidth: _Layout.evWidth,
    canvasHeight: _Layout.evHeight,
    // The padding pins the flag to the top of the strip; the panel would
    // centre a caption in the space below, so MAL is a label instead.
    panel: const PlatePanel(
      box: PlateBox(0, 0, _Layout.evGreenEnd, _Layout.evHeight),
      padding: EdgeInsets.fromLTRB(4.6, 13, 4.7, 76),
    ),
    labels: const <PlateLabel>[
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
        PlateSection.fill(PlateFill.color(MalaysiaColors.evSecureStrip)),
        end: _Layout.evStripEnd,
      ),
      PlatePart(PlateSection.plain),
    ]),
    slots: plateRow(
      _serial(
        suffix,
        letterPitch: _Layout.evLetterPitch,
        digitPitch: _Layout.evDigitPitch,
        gap: _Layout.evGap,
        suffixGap: _Layout.evGap,
      ),
      centre: (_Layout.evSerialLeft + _Layout.evSerialRight) / 2,
      top: _Layout.evSlotTop,
      height: _Layout.evSlotHeight,
      pitch: _Layout.evLetterPitch,
    ).slots,
    resolveRegion: MalaysiaRegions.captionOf,
  );

  static PlateSpec _plain({
    required String id,
    required double width,
    required double height,
    required List<PlateSlot> slots,
    List<PlateLabel> labels = const <PlateLabel>[],
    PlateLabelResolver? resolveRegion,
  }) => PlateSpec(
    id: id,
    country: MalaysiaCountry.malaysia,
    canvasWidth: width,
    canvasHeight: height,
    noPanel: true,
    panel: PlatePanel(box: PlateBox(0, 0, 0, height)),
    slots: slots,
    labels: labels,
    resolveRegion: resolveRegion,
  );

  static final PlateSpec diplomatic = () {
    const PlateRowText hyphen = PlateRowText.styled(
      '-',
      _Layout.hyphenWidth,
      glyphHeight: _Layout.hyphenGlyph,
    );
    final PlateRowLayout row = plateRow(
      const <PlateRowItem>[
        PlateRowRun(MalaysiaAlphabets.digits, 2, group: 'country'),
        hyphen,
        PlateRowRun(MalaysiaAlphabets.digits, 2, group: 'serial'),
        hyphen,
        PlateRowRun(
          MalaysiaAlphabets.missionCodes,
          1,
          pitch: 2 * _Layout.dipPitch,
          spacing: 0,
          group: 'mission',
        ),
      ],
      left: _Layout.dipLeft,
      top: _Layout.slotTop,
      height: _Layout.slotHeight,
      pitch: _Layout.dipPitch,
    );
    return _plain(
      id: 'my.diplomatic',
      width: _Layout.dipWidth,
      height: _Layout.height,
      slots: row.slots,
      labels: row.labels,
    );
  }();
}
