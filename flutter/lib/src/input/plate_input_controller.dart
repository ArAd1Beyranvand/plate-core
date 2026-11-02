import '../model/plate_input_source.dart';
import 'plate_controller.dart';

// TODO(ts): [D8] interface; the DOM adapter implements it over absolutely positioned inputs.
// TODO(kt): [D8] interface; the Compose adapter implements it with FocusRequesters.
// TODO(py): [D8] Protocol; the Qt adapter implements it over QLineEdits.
/// What a [PlateController] drives: a plate's focus and navigation.
/// [PlateCanvas] attaches its own; a host may attach another.
abstract class PlateInputTarget {
  int? get activeIndex;

  /// Whether the platform keyboard has been requested under
  /// [PlateInputSource.keypadFirst].
  bool get systemKeyboardActive;
  void submitCharacter(String character);
  void backspaceCharacter();
  void focusFirstEmptySlot();
  void focusSlot(int index);
}
