import '../model/plate_input_source.dart';
import 'plate_controller.dart';

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
