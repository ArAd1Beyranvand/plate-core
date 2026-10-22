import 'package:plate_alphabet/plate_alphabet.dart';
import 'package:plate_core/plate_core.dart';

import 'sahrawi_arab_democratic_republic_country.dart';

/// Ink positions in plate units: 520×110 for the one-line plates (the yellow
/// flat's ratio), 520×170 for the army plate.
///
/// Private is measured off the yellow flat. Its ink would need a ~170-unit box,
/// but a slot cannot exceed the 110-unit canvas, so ink prints at ~60% of the
/// reference height. Government and army boxes are estimates read by eye off
/// small originals.
abstract final class _Layout {
  static const double width = 520, height = 110;

  static const double privatePrefixLeft = 20.8, privatePrefixWidth = 83.7;
  static const double codeLeft = 163, codeWidth = 91.5;
  static const double serialLeft = 305.8, serialWidth = 193.2;

  static const double governmentPrefixLeft = 15, governmentPrefixWidth = 126;
  static const double governmentCodeLeft = 179, governmentCodeWidth = 75;
  static const double governmentSerialLeft = 297, governmentSerialWidth = 171;

  static const double armyHeight = 170;
  static const double armyDigitsLeft = 135, armyDigitsWidth = 368;
  static const double armyDigitsTop = 20, armyDigitsHeight = 130;
  static const PlateBox armyBadge = PlateBox(10, 58.75, 105, 52.5);
}

/// [private] is `SH 30 13581`, [government] the same design with a
/// three-letter prefix (`GSH`), [army] nine digits beside a flag badge.
/// Liveries are themes.
///
/// Not implemented: the pre-1976 Spanish series and MINURSO plates. The army
/// badge is the flag, not the army's own emblem.
abstract final class SahrawiArabDemocraticRepublicPlates {
  static final PlateSpec private = _oneLine(
    'eh.private',
    prefixLength: 2,
    prefixLeft: _Layout.privatePrefixLeft,
    prefixWidth: _Layout.privatePrefixWidth,
    codeLeft: _Layout.codeLeft,
    codeWidth: _Layout.codeWidth,
    serialLeft: _Layout.serialLeft,
    serialWidth: _Layout.serialWidth,
  );

  static final PlateSpec government = _oneLine(
    'eh.government',
    prefixLength: 3,
    prefixLeft: _Layout.governmentPrefixLeft,
    prefixWidth: _Layout.governmentPrefixWidth,
    codeLeft: _Layout.governmentCodeLeft,
    codeWidth: _Layout.governmentCodeWidth,
    serialLeft: _Layout.governmentSerialLeft,
    serialWidth: _Layout.governmentSerialWidth,
  );

  static final PlateSpec army = PlateSpec(
    id: 'eh.army',
    country: SahrawiArabDemocraticRepublicCountry.sahrawi_arab_democratic_republic,
    canvasWidth: _Layout.width,
    canvasHeight: _Layout.armyHeight,
    noPanel: true,
    panel: const PlatePanel(box: PlateBox(0, 0, 0, _Layout.armyHeight)),
    slots: <PlateSlot>[
      PlateSlot(
        alphabet: SahrawiArabDemocraticRepublicAlphabets.digits,
        box: const PlateBox(
          _Layout.armyDigitsLeft,
          _Layout.armyDigitsTop,
          _Layout.armyDigitsWidth,
          _Layout.armyDigitsHeight,
        ),
        length: 9,
      ),
    ],
    decals: const <PlateDecal>[PlateDecal(drawing: sahrawiFlagDrawing, box: _Layout.armyBadge)],
    textGroups: const <PlateTextGroup>[
      PlateTextGroup(<int>[0], key: 'serial'),
    ],
  );

  static List<PlateSpec> get all => <PlateSpec>[private, government, army];

  static PlateSpec _oneLine(
    String id, {
    required int prefixLength,
    required double prefixLeft,
    required double prefixWidth,
    required double codeLeft,
    required double codeWidth,
    required double serialLeft,
    required double serialWidth,
  }) => PlateSpec(
    id: id,
    country: SahrawiArabDemocraticRepublicCountry.sahrawi_arab_democratic_republic,
    canvasWidth: _Layout.width,
    canvasHeight: _Layout.height,
    noPanel: true,
    panel: const PlatePanel(box: PlateBox(0, 0, 0, _Layout.height)),
    slots: <PlateSlot>[
      PlateSlot(
        alphabet: SahrawiArabDemocraticRepublicAlphabets.letters,
        box: PlateBox(prefixLeft, 0, prefixWidth, _Layout.height),
        length: prefixLength,
      ),
      PlateSlot(
        alphabet: SahrawiArabDemocraticRepublicAlphabets.digits,
        box: PlateBox(codeLeft, 0, codeWidth, _Layout.height),
        length: 2,
      ),
      PlateSlot(
        alphabet: SahrawiArabDemocraticRepublicAlphabets.digits,
        box: PlateBox(serialLeft, 0, serialWidth, _Layout.height),
        length: 5,
      ),
    ],
    textGroups: const <PlateTextGroup>[
      PlateTextGroup(<int>[0], key: 'prefix'),
      PlateTextGroup(<int>[1], key: 'code'),
      PlateTextGroup(<int>[2], key: 'serial'),
    ],
  );
}
