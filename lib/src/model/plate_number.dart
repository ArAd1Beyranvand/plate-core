import 'package:flutter/foundation.dart';

@immutable
class PlateNumber {
  final List<String?> _values;

  PlateNumber({required List<String?> values})
    : _values = List.unmodifiable(values);

  List<String?> get values => _values;

  bool get isCompleted => !values.any((e) => e == null || e == '');

  bool get isEmpty => !values.any((e) => e != null);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlateNumber && listEquals(other.values, values);
  }

  @override
  int get hashCode => Object.hashAll(values);
}

/// [input] shows editable fields; [display] shows bare glyphs, as printed.
enum PlateMode { input, display }
