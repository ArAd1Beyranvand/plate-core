import 'package:plate_core/plate_core.dart';

/// Country code `HL` is refused on every diplomatic spec's `code` register.
abstract final class ItalyMissions {
  static const String notFound = 'COUNTRY NOT FOUND';

  static const List<String> refused = <String>['HL'];

  static const PlateRestriction restriction = PlateRestriction(
    group: 'code',
    values: refused,
    reason: notFound,
  );

  static bool isRefused(String code) => refused.contains(code);
}
