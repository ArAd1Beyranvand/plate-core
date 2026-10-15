import 'package:flutter/widgets.dart';

import '../model/plate_alphabet.dart';
import '../model/plate_input_source.dart';
import '../model/plate_number.dart';
import '../model/plate_spec.dart';
import '../model/slot_behavior.dart';
import 'plate_input_controller.dart';

/// Focus nodes and text controllers for one plate. Reads values through
/// [readValues] and writes through [commit], so it is independent of host
/// state. Bound to its [spec]: a spec change builds a new machine.
class PlateInputMachine implements PlateInputTarget {
  PlateInputMachine({
    required this.spec,
    required this.readValues,
    required this.commit,
    required this.inputSource,
    this.onActiveIndexChanged,
    this.onSystemKeyboardChanged,
  }) {
    for (var i = 0; i < spec.slots.length; i++) {
      _focusNodes.add(FocusNode()..addListener(_handleFocusChange));
      _controllers.add(
        spec.slots[i].alphabet.input == AlphabetInput.typed
            ? TextEditingController()
            : null,
      );
    }
    // An editable mirror is a second field over one slot, not a slot: its focus
    // reports as its source's, so a keypad sees one alphabet for both rows.
    for (var i = 0; i < spec.mirrors.length; i++) {
      final mirror = spec.mirrors[i];
      final alphabet = mirror.alphabet ?? spec.slots[mirror.source].alphabet;
      if (mirror.editable && alphabet.input == AlphabetInput.typed) {
        _mirrorFocusNodes.add(FocusNode()..addListener(_handleFocusChange));
        _mirrorControllers.add(TextEditingController());
      } else {
        _mirrorFocusNodes.add(null);
        _mirrorControllers.add(null);
      }
    }
    // Seeded, unannounced, so a keypad driven by [activeIndex] starts on the
    // first slot's alphabet.
    _activeIndex = spec.slots.isNotEmpty ? 0 : null;
  }

  final PlateSpec spec;
  final List<String?> Function() readValues;

  /// Writes one slot's value back to the host; '' clears it. Returns whether it
  /// was stored; focus must not advance past a refusal.
  final bool Function(int index, String value) commit;

  /// Where characters come from; re-resolved per build.
  PlateInputSource inputSource;

  /// Fired when the focused slot changes or focus leaves the plate.
  final ValueChanged<int?>? onActiveIndexChanged;

  /// Fired when [systemKeyboard] flips.
  final VoidCallback? onSystemKeyboardChanged;

  /// Under [PlateInputSource.keypadFirst], whether typed slots use the platform
  /// keyboard rather than the keypad.
  final ValueNotifier<bool> systemKeyboard = ValueNotifier(false);

  @override
  bool get systemKeyboardActive => systemKeyboard.value;

  /// Typed slots take the platform keyboard until focus reaches a chosen slot
  /// or leaves the plate.
  void requestSystemKeyboard() => _setSystemKeyboard(true);

  void _setSystemKeyboard(bool value) {
    if (systemKeyboard.value == value) return;
    systemKeyboard.value = value;
    onSystemKeyboardChanged?.call();
  }

  /// Fired when a chosen slot under [SlotBehavior.sheet] is reached.
  ValueChanged<int>? onSheetRequested;

  // Dense list by slot position. Null controllers are chosen-alphabet slots.
  final List<FocusNode> _focusNodes = [];
  final List<TextEditingController?> _controllers = [];

  // Parallel to mirrors. Null entries are read-only or chosen-alphabet mirrors.
  final List<FocusNode?> _mirrorFocusNodes = [];
  final List<TextEditingController?> _mirrorControllers = [];

  int? _activeIndex;

  FocusNode focusNodeAt(int index) => _focusNodes[index];
  TextEditingController? controllerAt(int index) => _controllers[index];
  FocusNode? mirrorFocusNodeAt(int mirrorIndex) =>
      _mirrorFocusNodes[mirrorIndex];
  TextEditingController? mirrorControllerAt(int mirrorIndex) =>
      _mirrorControllers[mirrorIndex];

  @override
  int? get activeIndex => _activeIndex;

  void _handleFocusChange() {
    int? active;
    for (var i = 0; i < _focusNodes.length; i++) {
      if (_focusNodes[i].hasFocus) {
        active = i;
        break;
      }
    }
    if (active == null) {
      for (var i = 0; i < _mirrorFocusNodes.length; i++) {
        if (_mirrorFocusNodes[i]?.hasFocus ?? false) {
          active = spec.mirrors[i].source;
          break;
        }
      }
    }
    // Chosen slots and a plate without focus fall back to the keypad.
    if (active == null ||
        spec.slots[active].alphabet.input != AlphabetInput.typed) {
      _setSystemKeyboard(false);
    }
    if (active != _activeIndex) {
      _activeIndex = active;
      onActiveIndexChanged?.call(active);
    }
  }

  /// Moves focus past [index]: to the next slot, or its sheet if chosen. At the
  /// end of the plate focus stays so backspace still acts.
  void advanceFrom(int index) {
    final next = spec.nextIndex(index);
    if (next == null) return;
    final nextBehavior = resolveSlotBehavior(
      mode: PlateMode.input,
      input: spec.slots[next].alphabet.input,
      source: inputSource,
    );
    if (nextBehavior == SlotBehavior.sheet) {
      onSheetRequested?.call(next);
    } else {
      _focusNodes[next].requestFocus();
    }
  }

  /// Syncs one slot's field with the host's canonical value. The field shows
  /// the alphabet's display form (national numerals), so a slot types in its
  /// own script. Per slot, so a keystroke rebuilds one slot.
  void syncController(int index, String? value) =>
      _setText(_controllers[index], value, spec.slots[index].render);

  /// Syncs an editable mirror's field with its source slot's value, rendered
  /// through the mirror's [alphabet].
  void syncMirrorController(
    int mirrorIndex,
    PlateAlphabet alphabet,
    String? value,
  ) => _setText(_mirrorControllers[mirrorIndex], value, alphabet.renderAll);

  static void _setText(
    TextEditingController? field,
    String? stored,
    String Function(String) render,
  ) {
    if (field == null) return;
    final text = stored == null || stored.isEmpty ? '' : render(stored);
    if (field.text == text) return;
    field.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void dispose() {
    systemKeyboard.dispose();
    for (final c in _controllers) {
      c?.dispose();
    }
    for (final f in _focusNodes) {
      f.removeListener(_handleFocusChange);
      f.dispose();
    }
    for (final c in _mirrorControllers) {
      c?.dispose();
    }
    for (final f in _mirrorFocusNodes) {
      f?.removeListener(_handleFocusChange);
      f?.dispose();
    }
  }

  @override
  void submitCharacter(String c) {
    final index = _activeIndex;
    if (index == null) return;
    final slot = spec.slots[index];
    final held = readValues()[index] ?? '';
    final next = held + slot.alphabet.canonical(c);
    if (!slot.accepts(next)) return;
    if (!commit(index, next)) return;
    if (slot.isFull(next)) advanceFrom(index);
  }

  @override
  void backspaceCharacter() {
    final index = _activeIndex;
    if (index == null) return;
    final values = readValues();
    final current = values[index];
    final empty = current == null || current.isEmpty;
    final target = empty ? spec.previousIndex(index) : index;
    if (target == null) return;
    final held = empty ? (values[target] ?? '') : current;
    final kept = held.runes.take(held.runes.length - 1);
    commit(target, String.fromCharCodes(kept));
    _focusNodes[target].requestFocus();
  }

  @override
  void focusFirstEmptySlot() {
    final values = readValues();
    final i = spec.slots.indexed.where((e) => !e.$2.isFull(values[e.$1]));
    _focusNodes[i.firstOrNull?.$1 ?? 0].requestFocus();
  }

  @override
  void focusSlot(int index) {
    if (index < 0 || index >= _focusNodes.length) return;
    _focusNodes[index].requestFocus();
  }
}
