import 'package:flutter/foundation.dart';

/// A value a named register may never hold, and the error shown when something
/// tries to store it.
///
/// The one place this package bars input, for values a country package must
/// guarantee no host can store; ordinary validity stays advisory. Every layer
/// that writes honours it: the controller drops the write and publishes it as
/// [PlateController.rejection], the input machine does not advance, validators
/// report [reason] first, and the canvas paints [reason] over the plate.
///
/// Matched against the whole register: a restriction on `'09'` lets `'0'`
/// through and refuses the `'9'` that completes it.
@immutable
class PlateRestriction {
  const PlateRestriction({
    required this.group,
    required this.values,
    required this.reason,
  });

  /// The [PlateTextGroup.key] of the register this restriction watches.
  final String group;

  /// Refused register values, in canonical (storage) form.
  final List<String> values;

  final String reason;

  bool matches(String groupValue) => values.contains(groupValue);
}

/// Thrown by [PlateSpec.checkRestrictions]. [toString] is the restriction's
/// reason.
class PlateRestrictionException implements Exception {
  const PlateRestrictionException(this.restriction);

  final PlateRestriction restriction;

  @override
  String toString() => restriction.reason;
}
