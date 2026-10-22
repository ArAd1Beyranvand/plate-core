import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

import 'riyadh_colors.dart';

/// Riyadh as a `PlateCountry`: the strip colour is the panel colour, so the
/// category is the country. The strip's wording is labels on the spec; the
/// emblem is the flag.
abstract final class RiyadhCountry {
  static final PlateCountry private = _strip(RiyadhColors.white);
  static final PlateCountry publicTransport = _strip(RiyadhColors.yellow);
  static final PlateCountry commercial = _strip(RiyadhColors.blue);
  static final PlateCountry temporary = _strip(RiyadhColors.silver);
  static final PlateCountry diplomatic = _strip(RiyadhColors.green);

  /// Category id (as in the goldens) -> country.
  static final Map<String, PlateCountry> byCategory = <String, PlateCountry>{
    'private': private,
    'public_transport': publicTransport,
    'commercial': commercial,
    'temporary': temporary,
    'diplomatic': diplomatic,
  };
}

PlateCountry _strip(Color color) => PlateCountry(
  code: 'ye',
  captionLines: const <String>[],
  panelColor: color,
  panelTextColor: RiyadhColors.ink,
  flag: const SvgPlateAsset('assets/riyadh/emblem.svg', package: 'yemen_plate'),
  flagAspectRatio: 610 / 662.42,
);
