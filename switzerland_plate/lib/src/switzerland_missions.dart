import 'package:plate_core/plate_core.dart';

/// Diplomatic plates end in a code for the country or organisation. Code 7 is
/// refused, in the spec as well as the validator, so `plate_core` rejects it in
/// the controller, the input machine, the canvas and the validators.
abstract final class SwitzerlandMissions {
  /// The error every layer shows for a refused code.
  static const String notFound = 'COUNTRY NOT FOUND';

  /// Codes no layer may store; the field is 1–3 digits, so each spelling.
  static const List<String> refused = <String>['7', '07', '007'];

  static const PlateRestriction restriction = PlateRestriction(
    group: 'code',
    values: refused,
    reason: notFound,
  );

  static bool isRefused(String code) => refused.contains(code);
}
