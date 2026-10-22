import 'package:plate_core/plate_core.dart';

import 'sudan_alphabets.dart';
import 'sudan_colors.dart';
import 'sudan_country.dart';

/// Plate coordinates measured off the Wikipedia artwork, normalised to the
/// 320x160 mm the Arabic article gives (x stretched, as the artwork is drawn
/// at 1.88). Layout: a name band, an ink rule, then a row split by the
/// hologram strip, with the class digit and state code left and the serial
/// right, each in Arabic over a Latin echo.
///
/// Core sets a glyph at `0.72 * box height`, so ink is roughly half the number
/// written here. Heights are tuned for Vazirmatn and capped so no box reaches
/// into the row below.
abstract final class _Layout {
  static const double width = 320;
  static const double height = 160;

  static const double ruleY = 42.1;
  static const double ruleThickness = 3.0;
  static const double hologramLeft = 112.8;
  static const double hologramRight = 122.4;

  static const double nameTop = 6;
  static const double arabicNameTop = 3.2;
  static const double nameHeight = 33;
  static const double latinNameGlyph = 32.4;
  static const double arabicNameGlyph = 34;

  // Each input box is its own band: a field draws its outline along its
  // bottom edge, so a box reaching into the row below strikes through it.

  // Boxes sit 1.5 further out than the artwork's centres because wider
  // glyphs (٨, ب ح) would touch.
  static const double codeTop = 45;
  static const double codeHeight = 60;
  static const PlateBox classBox = PlateBox(5.5, codeTop, 36, codeHeight);
  static const PlateBox stateBox = PlateBox(44.5, codeTop, 61, codeHeight);

  // Latin state codes are wider than the Arabic letter, so the echo overhangs
  // its column.
  static const double codeEchoTop = 105;
  static const double codeEchoGlyph = 52;
  static const PlateBox classEchoBox = PlateBox(7, codeEchoTop, 32, codeEchoGlyph);
  static const PlateBox stateEchoBox = PlateBox(36, codeEchoTop, 75, codeEchoGlyph);

  static const double serialLeft = 132;
  static const double serialRight = 306;
  static const double serialTop = 45;
  static const double serialHeight = 72;

  static const double serialEchoTop = 118;
  static const double serialEchoGlyph = 34;
}

/// The 2009 bilingual plate; every livery is this design, themed by
/// [SudanThemes].
///
/// The value is `class · state · serial`, stored in Latin (`7 KH 10346`). Each
/// slot prints in Arabic above a Latin echo; both rows are editable.
///
/// Not built: the newer print with the hologram replaced by embossed text, and
/// the pre-2009 series.
abstract final class SudanPlates {
  static const PlateSection _background = PlateSection.rows(<PlatePart>[
    PlatePart(PlateSection.plain, end: _Layout.ruleY, divider: _Layout.ruleThickness),
    PlatePart(
      PlateSection.columns(<PlatePart>[
        PlatePart(PlateSection.plain, end: _Layout.hologramLeft),
        PlatePart(
          PlateSection.fill(PlateFill.color(SudanColors.hologram)),
          end: _Layout.hologramRight,
        ),
        PlatePart(PlateSection.plain),
      ]),
    ),
  ]);

  static const List<PlateLabel> _labels = <PlateLabel>[
    PlateLabel(
      text: 'SUDAN',
      box: PlateBox(16, _Layout.nameTop, 99, _Layout.nameHeight),
      glyphHeight: _Layout.latinNameGlyph,
    ),
    PlateLabel(
      text: 'السودان',
      box: PlateBox(186, _Layout.arabicNameTop, 121, _Layout.nameHeight),
      glyphHeight: _Layout.arabicNameGlyph,
    ),
  ];

  static final PlateSpec standard = PlateSpec(
    id: 'sd.2009',
    country: SudanCountry.sudan,
    canvasWidth: _Layout.width,
    canvasHeight: _Layout.height,
    panel: const PlatePanel(box: PlateBox(0, 0, _Layout.width, 40)),
    noPanel: true,
    background: _background,
    labels: _labels,
    slots: const <PlateSlot>[
      PlateSlot(alphabet: SudanAlphabets.iranshahrDigits, box: _Layout.classBox),
      PlateSlot(alphabet: SudanAlphabets.stateArabic, box: _Layout.stateBox),
      PlateSlot(
        alphabet: SudanAlphabets.iranshahrDigits,
        box: PlateBox(
          _Layout.serialLeft,
          _Layout.serialTop,
          _Layout.serialRight - _Layout.serialLeft,
          _Layout.serialHeight,
        ),
        length: 5,
        minLength: 4,
      ),
    ],
    mirrors: const <PlateMirror>[
      PlateMirror(
        source: 0,
        box: _Layout.classEchoBox,
        glyphHeight: _Layout.codeEchoGlyph,
        alphabet: SudanAlphabets.digits,
        editable: true,
      ),
      PlateMirror(
        source: 1,
        box: _Layout.stateEchoBox,
        glyphHeight: _Layout.codeEchoGlyph,
        alphabet: SudanAlphabets.stateLatin,
        editable: true,
      ),
      PlateMirror(
        source: 2,
        box: PlateBox(
          _Layout.serialLeft,
          _Layout.serialEchoTop,
          _Layout.serialRight - _Layout.serialLeft,
          _Layout.serialEchoGlyph,
        ),
        glyphHeight: _Layout.serialEchoGlyph,
        alphabet: SudanAlphabets.digits,
        editable: true,
      ),
    ],
    textGroups: const <PlateTextGroup>[
      PlateTextGroup(<int>[0], key: 'class'),
      PlateTextGroup(<int>[1], key: 'state'),
      PlateTextGroup(<int>[2], prefix: '-', key: 'serial'),
    ],
  );
}
