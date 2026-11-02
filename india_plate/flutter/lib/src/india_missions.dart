import 'package:plate_core/plate_core.dart';

/// Mission number `109` is refused on the diplomatic spec's `mission` register.
abstract final class IndiaMissions {
  static const String notFound = 'COUNTRY NOT FOUND';

  static const List<String> refused = <String>['109'];

  static const PlateRestriction restriction = PlateRestriction(
    group: 'mission',
    values: refused,
    reason: notFound,
  );

  static bool isRefused(String code) => refused.contains(code);
}
