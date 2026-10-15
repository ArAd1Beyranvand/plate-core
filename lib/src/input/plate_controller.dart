import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import '../model/plate_alphabet.dart';
import '../model/plate_number.dart';
import '../model/plate_restriction.dart';
import '../model/plate_spec.dart';
import '../validators/plate_validator.dart';
import 'plate_input_controller.dart';

/// What happens to the characters on a plate when [PlateController.adoptSpec]
/// swaps its [PlateSpec].
enum PlateValuePreservation {
  /// Start the new plate empty.
  none,

  /// Copy slot by slot while both plates have a slot at that position.
  byIndex,

  /// Copy register by register, matching [PlateTextGroup.key] between the
  /// specs. The default, because corresponding registers rarely share
  /// positions.
  byGroupKey,
}

/// Owns a plate's characters and drives focus and navigation. Pass it to
/// [PlateCanvas] as `controller:` to read or write the value, track the active
/// slot, or feed characters from a keypad.
///
/// Listen at three grains: [slot] fires per position, [completed] on a
/// full/not-full flip, and the controller itself on every change.
class PlateController extends ChangeNotifier {
  PlateController({required PlateSpec spec, List<String?>? values})
    : _spec = spec {
    _values = [
      for (var i = 0; i < spec.slotCount; i++) _printedCharacter(spec, i),
    ];
    if (values != null) {
      for (var i = 0; i < spec.slotCount && i < values.length; i++) {
        final printed = _printedCharacter(spec, i);
        if (printed != null) continue;
        _values[i] = _sanitize(spec, i, values[i]);
      }
    }
    final refused = _clearRestricted(spec, _values);
    _foundSlots();
    _completed = ValueNotifier<bool>(_computeCompleted());
    _rejection = ValueNotifier<PlateRestriction?>(refused);
  }

  factory PlateController.fromValues(PlateSpec spec, List<String?> values) =>
      PlateController(spec: spec, values: values);

  /// Pours [text] into the slots in order, each taking up to its
  /// [PlateSlot.length]. Characters the current slot refuses, such as
  /// separators, are skipped without consuming it.
  factory PlateController.fromText(PlateSpec spec, String text) {
    final values = List<String?>.filled(spec.slotCount, null);
    var index = 0;
    for (final character in text.characters) {
      if (index >= spec.slotCount) break;
      final slot = spec.slots[index];
      if (!slot.accepts(character)) continue;
      values[index] = (values[index] ?? '') + slot.canonical(character);
      if (slot.isFull(values[index])) index++;
    }
    return PlateController(spec: spec, values: values);
  }

  PlateSpec _spec;
  late List<String?> _values;
  late List<ValueNotifier<String?>> _slots;
  late final ValueNotifier<bool> _completed;
  late final ValueNotifier<PlateRestriction?> _rejection;

  /// Changed only through [adoptSpec].
  PlateSpec get spec => _spec;

  /// A snapshot in slot order; write through [setAt], [setValues], [setGroup]
  /// or [clear].
  List<String?> get values => List<String?>.unmodifiable(_values);

  /// Null when [index] is outside the plate.
  String? valueAt(int index) =>
      index >= 0 && index < _values.length ? _values[index] : null;

  /// Stores [value] at [index]; '' or null clears the slot. A character the
  /// alphabet refuses, or a write to a printed slot, is a no-op rather than an
  /// exception. A write that would hit a [PlateSpec.restrictions] value is
  /// refused and published on [rejection]. Returns whether it was stored.
  bool setAt(int index, String? value) {
    if (index < 0 || index >= _values.length) return false;
    if (_printedCharacter(_spec, index) != null) return false;
    final next = _sanitize(_spec, index, value);
    if (next == null && value != null && value.isNotEmpty) return false;
    return _store({index: next});
  }

  /// Writes every slot in index order, notifying once. Printed slots keep their
  /// fixed character. A write that breaks a restriction is refused whole.
  bool setValues(List<String?> values) => _store({
    for (var i = 0; i < _values.length; i++)
      i:
          _printedCharacter(_spec, i) ??
          (i < values.length ? _sanitize(_spec, i, values[i]) : null),
  });

  void clear() => setValues(List<String?>.filled(_values.length, null));

  /// Every text group rendered through its alphabets, joined by [sep].
  String text({String sep = ' '}) => [
    for (final group in _spec.effectiveTextGroups)
      _spec.renderGroup(group, _values),
  ].join(sep);

  /// The group named [key] in canonical (storage) form; '' for an unknown key.
  String group(String key) => _spec.valueOfGroup(key, _values);

  /// [PlateSpec.resolveRegion] over what is typed; null when the spec has none
  /// or the region cannot be told yet.
  String? get regionCaption => _spec.resolveRegion?.call(group);

  /// Pours [value] across the slots of the group named [key] in group order,
  /// each taking up to its [PlateSlot.length] (a chosen symbol is taken whole).
  /// A slot whose alphabet refuses its share is cleared. No-op for an unknown
  /// key; refused whole when it breaks a restriction.
  bool setGroup(String key, String value) {
    final group = _spec.groupNamed(key);
    if (group == null) return false;
    final characters = value.characters;
    final writes = <int, String?>{};
    var offset = 0;
    for (final index in group.indices) {
      if (_printedCharacter(_spec, index) != null) continue;
      final slot = _spec.slots[index];
      final take = slot.alphabet.input == AlphabetInput.chosen
          ? characters.length - offset
          : slot.length;
      writes[index] = _sanitize(
        _spec,
        index,
        characters.skip(offset).take(take).join(),
      );
      offset += take;
    }
    return _store(writes);
  }

  bool get isCompleted => _completed.value;
  bool get isEmpty => !_values.any((v) => v != null && v.isNotEmpty);

  PlateNumber get plateNumber => PlateNumber(values: _values);

  /// The character at [index]. Out of range gives a listenable that stays null,
  /// so a widget outliving a shrinking spec paints an empty slot.
  ValueListenable<String?> slot(int index) =>
      index >= 0 && index < _slots.length
      ? _slots[index]
      : const _AlwaysNull<String?>();

  /// Fires only when [isCompleted] flips.
  ValueListenable<bool> get completed => _completed;

  /// The restriction the last refused write broke; null once a write is stored.
  /// The canvas paints its reason over the plate.
  ValueListenable<PlateRestriction?> get rejection => _rejection;

  /// Swaps the plate, carrying characters across as [preserve] directs, and
  /// notifies once.
  ///
  /// Slot listenables are recreated for the new spec, so one cached from the
  /// old spec stops updating: call [slot] per build rather than caching it.
  void adoptSpec(
    PlateSpec next, {
    PlateValuePreservation preserve = PlateValuePreservation.byGroupKey,
  }) {
    final migrated = _migrate(_spec, next, _values, preserve);
    final refused = _clearRestricted(next, migrated);
    _spec = next;
    _values = migrated;
    _rejection.value = refused;
    for (final slot in _slots) {
      slot.dispose();
    }
    _foundSlots();
    _completed.value = _computeCompleted();
    notifyListeners();
  }

  PlateInputTarget? _target;
  PlateValidation? Function()? _probe;
  PlateValidation? _lastVerdict;

  /// The verdict on the plate as it stands; null without an attached validator.
  /// Computed on demand, so it works with or without `autoValidate`.
  ///
  /// A refused write outranks everything: while [rejection] holds one, the
  /// verdict is its reason.
  PlateValidation? get validation {
    final refused = _rejection.value;
    if (refused != null) return PlateValidation.invalid(refused.reason);
    return _probe?.call();
  }

  /// For [PlateCanvas] only.
  void installValidation(PlateValidation? Function()? probe) {
    _probe = probe;
    _lastVerdict = null;
  }

  /// For [PlateCanvas] only. Notifies on a change of verdict, not per keystroke.
  void reportValidation(PlateValidation? value) {
    if (_lastVerdict == value) return;
    _lastVerdict = value;
    notifyListeners();
  }

  void attach(PlateInputTarget target) {
    _target = target;
    // Attached mid-build from the canvas's initState: listeners that setState
    // would assert, so they hear of it after the frame.
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (identical(_target, target)) notifyListeners();
      });
      return;
    }
    notifyListeners();
  }

  /// Guarded: an old canvas's detach runs after the new one has attached.
  void detach(PlateInputTarget target) {
    if (identical(_target, target)) {
      _target = null;
      notifyListeners();
    }
  }

  void notifyActiveSlotChanged() => notifyListeners();

  /// Null when unfocused.
  int? get activeIndex => _target?.activeIndex;

  PlateSlot? get activeSlot => _spec.slotAt(activeIndex ?? -1);

  /// True while the platform keyboard stands in for the host's keypad under
  /// [PlateInputSource.keypadFirst]; the host hides its keypad meanwhile.
  bool get systemKeyboardActive => _target?.systemKeyboardActive ?? false;

  bool get isAttached => _target != null;

  /// Commits [character] to the active slot and advances focus, as typing does.
  void submit(String character) => _target?.submitCharacter(character);

  /// Clears the active slot, or steps back and clears the previous one if it
  /// is already empty.
  void backspace() => _target?.backspaceCharacter();

  /// Focuses the first slot that is not full, or the first slot.
  void focusFirstEmpty() => _target?.focusFirstEmptySlot();

  void focusSlot(int index) => _target?.focusSlot(index);

  @override
  void dispose() {
    // Cleared first: a later detach from an outliving canvas must not notify a
    // disposed ChangeNotifier.
    _target = null;
    _probe = null;
    for (final slot in _slots) {
      slot.dispose();
    }
    _completed.dispose();
    _rejection.dispose();
    super.dispose();
  }

  void _foundSlots() {
    _slots = [
      for (var i = 0; i < _spec.slotCount; i++)
        ValueNotifier<String?>(_values[i]),
    ];
  }

  /// Writes [changes] (slot index to value) unless they break a restriction,
  /// then notifies once. Returns whether they were stored.
  bool _store(Map<int, String?> changes) {
    final candidate = List<String?>.of(_values);
    changes.forEach((i, v) => candidate[i] = v);
    if (_refuse(candidate)) return false;
    changes.forEach((i, v) {
      _values[i] = v;
      _slots[i].value = v;
    });
    _completed.value = _computeCompleted();
    _rejection.value = null;
    notifyListeners();
    return true;
  }

  /// Whether [candidate] breaks a restriction; if so, publishes it on
  /// [rejection] and notifies, so listeners show the error although no value
  /// changed.
  bool _refuse(List<String?> candidate) {
    final broken = _spec.restrictionViolatedBy(candidate);
    if (broken == null) return false;
    _rejection.value = broken;
    notifyListeners();
    return true;
  }

  /// Empties, in place, every register of [values] that breaks one of
  /// [spec]'s restrictions, for paths handed a whole value rather than asked
  /// to write one. Returns the last restriction broken.
  static PlateRestriction? _clearRestricted(
    PlateSpec spec,
    List<String?> values,
  ) {
    PlateRestriction? broken;
    for (final r in spec.restrictions) {
      if (!r.matches(spec.valueOfGroup(r.group, values))) continue;
      for (final i in spec.indicesOfGroup(r.group)) {
        if (i < values.length) values[i] = null;
      }
      broken = r;
    }
    return broken;
  }

  bool _computeCompleted() =>
      _values.isNotEmpty &&
      _spec.slots.indexed.every((e) => e.$2.isComplete(_values[e.$1]));

  /// [value] as the slot stores it: canonical, or null when cleared or refused.
  static String? _sanitize(PlateSpec spec, int index, String? value) {
    if (value == null || value.isEmpty) return null;
    final slot = spec.slotAt(index);
    if (slot == null || !slot.accepts(value)) return null;
    return slot.canonical(value);
  }

  /// The fixed character of a slot whose alphabet holds exactly one: printed,
  /// not typed. Null for an ordinary slot.
  static String? _printedCharacter(PlateSpec spec, int index) {
    final slot = spec.slots[index];
    final characters = slot.alphabet.characters;
    return slot.length == 1 && characters.length == 1
        ? characters.single
        : null;
  }

  static bool _hasKeyedGroups(PlateSpec spec) =>
      spec.effectiveTextGroups.any((g) => g.key != null);

  static List<String?> _migrate(
    PlateSpec from,
    PlateSpec to,
    List<String?> values,
    PlateValuePreservation preserve,
  ) {
    if (preserve == PlateValuePreservation.none) {
      return List<String?>.filled(to.slotCount, null);
    }

    final byKey =
        preserve == PlateValuePreservation.byGroupKey &&
        (_hasKeyedGroups(from) || _hasKeyedGroups(to));
    if (!byKey) {
      return [
        for (var i = 0; i < to.slotCount; i++)
          i < values.length ? _sanitize(to, i, values[i]) : null,
      ];
    }

    final result = List<String?>.filled(to.slotCount, null);

    // Printed slots first, so a matched group still wins.
    for (var i = 0; i < to.slotCount; i++) {
      result[i] = _printedCharacter(to, i);
    }

    for (final target in to.effectiveTextGroups) {
      final key = target.key;
      if (key == null) continue;
      final source = from.groupNamed(key);
      if (source == null) continue;

      // Gaps are skipped, so a half-typed register carries as far as it got;
      // the characters are poured by slot length, so a run of two fields can
      // become two cells.
      final characters = <String>[
        for (final i in source.indices)
          if (i < values.length) ...(values[i] ?? '').characters,
      ];

      var next = 0;
      for (final index in target.indices) {
        final length = to.slots[index].length;
        final take = characters.skip(next).take(length).join();
        next += length;
        result[index] = _sanitize(to, index, take);
      }
    }

    return result;
  }
}

@immutable
class _AlwaysNull<T> implements ValueListenable<T?> {
  const _AlwaysNull();

  @override
  T? get value => null;

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}
}

extension on String {
  /// By rune, not code unit, which would split scripts outside the BMP.
  List<String> get characters => [
    for (final rune in runes) String.fromCharCode(rune),
  ];
}
