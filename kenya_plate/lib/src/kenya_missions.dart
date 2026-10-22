import 'package:plate_core/plate_core.dart';

/// The diplomatic mission numbers: the digits before `CD`/`UN`.
///
/// Code `24` (Israel in the article's August 2025 table) is deliberately
/// absent and refused: [restriction] carries it into the diplomatic spec so
/// `plate_core` refuses it everywhere.
abstract final class KenyaMissions {
  /// The error every layer shows for a refused code.
  static const String notFound = 'COUNTRY NOT FOUND';

  static const List<String> refused = <String>['24'];

  /// The restriction on the diplomatic spec's `mission` register.
  static const PlateRestriction restriction = PlateRestriction(
    group: 'mission',
    values: refused,
    reason: notFound,
  );

  static bool isRefused(String code) => refused.contains(code);
}
