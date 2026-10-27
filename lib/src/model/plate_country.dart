import 'package:flutter/widgets.dart';

import 'plate_asset.dart';

/// The country chrome of a plate: flag, caption and panel colours. Concrete
/// constants live in each country's own package.
///
/// [PlateSpec.country] is only the default; `PlateCanvas.country` overrides it
/// at render time, so a panel that varies along an axis the spec does not
/// encode (a vehicle's usage class) needs no second spec.
@immutable
class PlateCountry {
  const PlateCountry({
    required this.code,
    required this.captionLines,
    required this.panelColor,
    required this.panelTextColor,
    this.headingLines = const <String>[],
    this.flagAspectRatio = 7 / 4,
    this.flag,
    this.flagBorderColor,
  });

  /// ISO 3166-1 alpha-2, lower-case. The sole basis of [operator ==].
  final String code;

  /// Printed beside the flag, top to bottom. Always laid out LTR.
  final List<String> captionLines;

  /// Wording on the far side of the flag from [captionLines] (above it in a
  /// vertical panel), for a panel that sandwiches the flag between two runs of
  /// text. [CountryPanel] splits the room the flag leaves between the two.
  final List<String> headingLines;

  final Color panelColor;

  /// Null prints the wording in the theme's ink, for a block printed straight
  /// on the field whose livery a resolver may change.
  final Color? panelTextColor;

  /// Width over height; sizes the flag without distortion.
  final double flagAspectRatio;

  /// Null for a country with no flag.
  final PlateGraphic? flag;

  /// A fine outline printed around the flag, for flags whose edge would
  /// otherwise vanish into the panel.
  final Color? flagBorderColor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is PlateCountry && other.code == code);

  @override
  int get hashCode => code.hashCode;
}
