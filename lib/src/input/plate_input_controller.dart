import '../model/plate_input_source.dart';
import 'plate_controller.dart';

/// What a [PlateController] drives: a plate's focus and navigation.
/// Implemented by [PlateInputMachine], which a [PlateCanvas] attaches on the
/// host's behalf — or a host can hold and attach itself.
abstract class PlateInputTarget {
  int? get activeIndex;

  /// Whether the platform keyboard has been asked for under
  /// [PlateInputSource.keypadFirst].
  bool get systemKeyboardActive;
  void submitCharacter(String character);
  void backspaceCharacter();
  void focusFirstEmptySlot();
  void focusSlot(int index);
}
