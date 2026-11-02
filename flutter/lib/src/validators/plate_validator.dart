import 'package:flutter/foundation.dart';

import '../model/plate_spec.dart';

/// The verdict on a plate; [reason] explains an invalid one and is null when
/// valid.
@immutable
class PlateValidation {
  const PlateValidation.valid() : reason = null;
  const PlateValidation.invalid(String this.reason);

  final String? reason;

  bool get isValid => reason == null;

  @override
  bool operator ==(Object other) =>
      other is PlateValidation && other.reason == reason;

  @override
  int get hashCode => reason.hashCode;
}

/// A plate as it stands, for a validator to judge.
@immutable
class PlateEntry {
  const PlateEntry({
    required this.spec,
    required this.values,
    this.activeIndex,
  });

  final PlateSpec spec;
  final List<String?> values;

  /// The focused slot, so a validator can stay quiet about groups the user has
  /// not reached.
  final int? activeIndex;

  /// Canonical value of the group named [key]; '' if none.
  String group(String key) => spec.valueOfGroup(key, values);

  PlateTextGroup? get activeGroup =>
      activeIndex == null ? null : spec.groupAt(activeIndex!);
}

// TODO(ts): [H9] ASCII 0-9 only: /^[0-9]+$/, never \d with the u flag on other scripts.
// TODO(kt): [H9] all { it in '0'..'9' }; Char.isDigit() accepts every Unicode Nd.
// TODO(py): [H9] str.isdigit() accepts ۵ and ²: use re.fullmatch(r"[0-9]+", v) or an ASCII check.
bool isDigits(String value) =>
    value.isNotEmpty && value.codeUnits.every((u) => u >= 0x30 && u <= 0x39);

// TODO(ts): [H24] length is code units; safe only because isDigits passes ASCII alone.
// TODO(kt): [H24] same.
// TODO(py): [H24] same, len() agrees for ASCII.
bool isDigitsOfLength(String value, int length) =>
    value.length == length && isDigits(value);

// TODO(ts): [D4-code] interface {validate(entry): PlateValidation}; country validators hand-ported.
// TODO(kt): [D4-code] fun interface PlateValidator.
// TODO(py): [D4-code] Protocol with validate(); validation is a frozen dataclass (reason: str | None).
/// Judges a plate. It never prevents input; what to do with the verdict is the
/// host's decision.
abstract class PlateValidator {
  const PlateValidator();

  PlateValidation validate(PlateEntry entry);
}

/// The verdict a spec's restrictions give on [entry], or null when none is
/// broken. Asked before any validator: a restricted value is invalid
/// regardless.
PlateValidation? restrictionVerdict(PlateEntry entry) {
  final broken = entry.spec.restrictionViolatedBy(entry.values);
  return broken == null ? null : PlateValidation.invalid(broken.reason);
}

/// A [PlateValidator] that stays quiet until [gateGroup], the last register the
/// user reaches, has content, so only a whole plate is judged.
abstract class GatedPlateValidator extends PlateValidator {
  const GatedPlateValidator();

  String get gateGroup;

  PlateValidation judge(PlateEntry entry);

  @override
  PlateValidation validate(PlateEntry entry) =>
      restrictionVerdict(entry) ??
      (entry.group(gateGroup).isEmpty
          ? const PlateValidation.valid()
          : judge(entry));
}
