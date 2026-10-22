import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

import '../common/yemen_alphabets.dart';
import '../common/yemen_country.dart';
import 'northern_regions.dart';

/// System B, the 1993 format: a top band (the usage word) over a governorate
/// code of 1–2 digits beside a serial of 4–6, each echoed in Latin digits below.
///
/// Usage is not a field of a spec. It picks the country block, which carries the
/// usage word, and the theme, which carries the field colour; both are render
/// inputs:
///
/// ```dart
/// PlateCanvas(
///   spec: YemenNorthernPlates.car,
///   country: YemenCountry.northernFor(usage),
///   theme: YemenThemes.forNorthernUsage(usage),
/// )
/// ```
///
/// Each spec's own `country` is the private one, so a caller that passes none
/// gets the ordinary plate.
abstract final class YemenNorthernPlates {
  // The car is 540 x 288, measured from an issued blue private plate; comments
  // give the measured fraction of the plate, code the units.
  static const double _carWidth = 540;
  static const double _height = 288;
  static const double _motoWidth = 289; // CALIBRATE: no photo available
  static const double _borderRatio = 0.035; // CALIBRATE: matches theme ratio

  //   top band     y 0.038 .. 0.219
  //   rule         y 0.289 .. 0.314   full width
  //   divider      x 0.246 .. 0.260   from the rule to the frame
  //   governorate  x 0.006 .. 0.246   y 0.331 .. 0.641
  //   serial       x 0.260 .. 0.983   y 0.331 .. 0.641

  /// The usage word as the caption of a transparent panel, so it prints on the
  /// field. A caption only scales down, so `captionScale` is set to make the fit
  /// bind.
  static const PlatePanel _carPanel = PlatePanel(
    box: PlateBox(0, 6, 540, 62),
    flagScale: 0,
    captionScale: 4.5,
    padding: EdgeInsets.fromLTRB(50, 3, 50, 0),
  );

  // The rule under the top band (83 .. 90), then the divider between governorate
  // and serial (133 .. 140).
  static const PlateSection _carBackground = PlateSection.rows(<PlatePart>[
    PlatePart(PlateSection.plain, end: 86.5, divider: 7),
    PlatePart(
      PlateSection.columns(<PlatePart>[
        PlatePart(PlateSection.plain, end: 136.5, divider: 7),
        PlatePart(PlateSection.plain),
      ]),
    ),
  ]);

  // Core sets a glyph at `0.72 * cellHeight` in Roboto (cap 0.711 em), not the
  // plate's own square Kufic; see the README's `## Fonts`.
  static const PlateSlot _carGovernorate = PlateSlot(
    alphabet: YemenAlphabets.iranshahrDigits,
    box: PlateBox(24, 95, 88, 89),
    length: 2,
    minLength: 1,
  );

  static const PlateSlot _carSerial = PlateSlot(
    alphabet: YemenAlphabets.iranshahrDigits,
    box: PlateBox(140, 95, 390, 89),
    length: 6,
    minLength: 4,
  );

  // The Latin echo row (y 0.697 .. 0.882, cap 53 units). Its box is deeper than
  // the cap to avoid clipping. Each mirror takes its source's x and width and is
  // editable, so the value reads in two scripts.
  static const double _echoTop = 175;
  static const double _echoHeight = 104;

  static const List<PlateMirror> _carMirrors = <PlateMirror>[
    PlateMirror(
      source: 0,
      box: PlateBox(24, _echoTop, 88, _echoHeight),
      glyphHeight: _echoHeight,
      alphabet: YemenAlphabets.digits,
      editable: true,
    ),
    PlateMirror(
      source: 1,
      box: PlateBox(140, _echoTop, 390, _echoHeight),
      glyphHeight: _echoHeight,
      alphabet: YemenAlphabets.digits,
      editable: true,
    ),
  ];

  // Motorcycle: the car's structure on a narrower canvas, x renormalised and y
  // unchanged. No photograph.

  static const PlatePanel _motoPanel = PlatePanel(
    box: PlateBox(0, 6, 289, 62),
    flagScale: 0,
    captionScale: 4.5,
    padding: EdgeInsets.fromLTRB(25, 3, 25, 0),
  );

  static const PlateSection _motoBackground = PlateSection.rows(<PlatePart>[
    PlatePart(PlateSection.plain, end: 86.5, divider: 7),
    PlatePart(
      PlateSection.columns(<PlatePart>[
        PlatePart(PlateSection.plain, end: 73, divider: 4),
        PlatePart(PlateSection.plain),
      ]),
    ),
  ]);

  static const PlateSlot _motoGovernorate = PlateSlot(
    alphabet: YemenAlphabets.iranshahrDigits,
    box: PlateBox(13, 95, 48, 89),
    length: 2,
    minLength: 1,
  );

  static const PlateSlot _motoSerial = PlateSlot(
    alphabet: YemenAlphabets.iranshahrDigits,
    box: PlateBox(75, 95, 209, 89),
    length: 6,
    minLength: 4,
  );

  // 56 rather than 104: the narrow governorate field would clip a larger glyph.
  static const double _motoEchoHeight = 56;

  static const List<PlateMirror> _motoMirrors = <PlateMirror>[
    PlateMirror(
      source: 0,
      box: PlateBox(13, _echoTop, 48, _echoHeight),
      glyphHeight: _motoEchoHeight,
      alphabet: YemenAlphabets.digits,
      editable: true,
    ),
    PlateMirror(
      source: 1,
      box: PlateBox(75, _echoTop, 209, _echoHeight),
      glyphHeight: _motoEchoHeight,
      alphabet: YemenAlphabets.digits,
      editable: true,
    ),
  ];

  static const List<PlateTextGroup> _groups = <PlateTextGroup>[
    PlateTextGroup(<int>[0], key: 'governorate'),
    PlateTextGroup(<int>[1], key: 'serial'),
  ];

  static final PlateSpec car = PlateSpec(
    id: 'ye.northern.car',
    country: YemenCountry.northernPrivate,
    canvasWidth: _carWidth,
    canvasHeight: _height,
    panel: _carPanel,
    slots: const <PlateSlot>[_carGovernorate, _carSerial],
    mirrors: _carMirrors,
    background: _carBackground,
    textGroups: _groups,
    resolveRegion: YemenRegions.captionOf,
    borderWidthRatioOverride: _borderRatio,
  );

  /// The motorcycle plate. No northern motorcycle design is published, so this
  /// is the car's content at half the width: a guess, deprecated so nothing
  /// trusts it silently and it shows in a grep.
  @Deprecated('unverified geometry — calibrate against photographs')
  static final PlateSpec moto = PlateSpec(
    id: 'ye.northern.moto',
    country: YemenCountry.northernPrivate,
    canvasWidth: _motoWidth,
    canvasHeight: _height,
    panel: _motoPanel,
    slots: const <PlateSlot>[_motoGovernorate, _motoSerial],
    mirrors: _motoMirrors,
    background: _motoBackground,
    textGroups: _groups,
    resolveRegion: YemenRegions.captionOf,
    borderWidthRatioOverride: _borderRatio,
  );
}
