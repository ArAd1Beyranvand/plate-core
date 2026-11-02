import 'package:plate_core/plate_core.dart';

import 'venezuela_alphabets.dart';

/// One vehicle category's serial: the six cells before the state letter.
/// `L` is a letter, `D` a digit, and any other character is printed as is.
class VenezuelaCategory {
  const VenezuelaCategory(this.name, this.pattern);

  final String name;
  final String pattern;

  bool matches(String serial) {
    if (serial.length != pattern.length) return false;
    return pattern.split('').indexed.every((e) {
      final c = serial[e.$1];
      return switch (e.$2) {
        'L' => isLetter(c),
        'D' => isDigits(c),
        final p => c == p,
      };
    });
  }

  static bool isLetter(String c) =>
      c.length == 1 && c.codeUnitAt(0) >= 0x41 && c.codeUnitAt(0) <= 0x5A;
}

// TODO(py): [D4-code] hand-port; reason strings are the contract, keep them byte-identical.
// TODO(ts): [D4-code] hand-port; reason strings are the contract, keep them byte-identical.
// TODO(kt): [D4-code] hand-port; reason strings are the contract, keep them byte-identical.
/// Reports, never throws, never bars a keystroke. Quiet until the state
/// letter is in; then the six serial cells must match one of [categories]
/// and the last letter must name a state.
class VenezuelaValidator extends GatedPlateValidator {
  const VenezuelaValidator();

  @override
  String get gateGroup => 'state';

  /// The seven-character categories in the article's table, in its order.
  /// Animal traction (`x1xx2`) and vehicles for the disabled (`x12x3`) have
  /// six characters and so do not fit this plate; the provisional and Free
  /// Port series are other designs.
  static const List<VenezuelaCategory> categories = <VenezuelaCategory>[
    VenezuelaCategory('Private car', 'LLDDDL'),
    VenezuelaCategory('Motorcycle', 'LLDLDD'),
    VenezuelaCategory('Freight', 'LDDLLD'),
    VenezuelaCategory('Crane', 'LDDLDD'),
    VenezuelaCategory('School transport', 'LDDDLD'),
    VenezuelaCategory('Private transport', 'LDDDDL'),
    VenezuelaCategory('Tourist transport, rustic', 'LDLLDD'),
    VenezuelaCategory('Tourist transport, minibus', 'LDDLDL'),
    VenezuelaCategory('Tourist transport, bus', 'LDLDLD'),
    VenezuelaCategory('Urban public transport', '0DLLDL'),
    VenezuelaCategory('Suburban public transport, car', '1DLDLD'),
    VenezuelaCategory('Suburban public transport, minibus', '2DLDDL'),
    VenezuelaCategory('Suburban public transport, bus', '3DLLDD'),
    VenezuelaCategory('Intercity public transport, car', '4DDLDL'),
    VenezuelaCategory('Intercity public transport, minibus', '5DDLLD'),
    VenezuelaCategory('Intercity public transport, bus', '6DDDLD'),
    VenezuelaCategory('Taxi', '7LDLDL'),
    VenezuelaCategory('Peripheral public transport, rustic', '8LDLDD'),
    VenezuelaCategory('Peripheral public transport, minibus', '9LDDDL'),
  ];

  /// The category [serial] is written in, or null if it fits none.
  static VenezuelaCategory? categoryOf(String serial) =>
      categories.where((c) => c.matches(serial)).firstOrNull;

  static const String reasonSerialLength = 'The serial fills every cell.';
  static const String reasonNoCategory =
      'The letters and digits are in no category\'s order.';
  static const String reasonState = 'The last letter names no state.';

  @override
  PlateValidation judge(PlateEntry entry) {
    final String serial = entry.group('serial');
    if (serial.length != 6) {
      return const PlateValidation.invalid(reasonSerialLength);
    }
    if (!VenezuelaAlphabets.stateNames.containsKey(entry.group('state'))) {
      return const PlateValidation.invalid(reasonState);
    }
    if (categoryOf(serial) == null) {
      return const PlateValidation.invalid(reasonNoCategory);
    }
    return const PlateValidation.valid();
  }
}
