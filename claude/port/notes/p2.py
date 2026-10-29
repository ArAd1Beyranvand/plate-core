I = 'plate_core/lib/src/input/'
NOTES = [
 (I+'plate_input_controller.dart', 'abstract class PlateInputTarget {', [
  'TODO(ts): [D8] interface; the DOM adapter implements it over absolutely positioned inputs.',
  'TODO(kt): [D8] interface; the Compose adapter implements it with FocusRequesters.',
  'TODO(py): [D8] Protocol; the Qt adapter implements it over QLineEdits.']),
 (I+'plate_controller.dart', 'enum PlateValuePreservation {', [
  'TODO(ts): [D9] _migrate under each mode is a vector (from spec, to spec, values -> values).',
  'TODO(kt): [D9] same vectors.',
  'TODO(py): [D9] same vectors.']),
 (I+'plate_controller.dart', 'class PlateController extends ChangeNotifier {', [
  'TODO(ts): [D7] plain class + tiny store: subscribe(cb) for whole, slot(i), completed, rejection.',
  'TODO(kt): [D7] StateFlow per grain: values, slot(i) via map+distinctUntilChanged, completed, rejection.',
  'TODO(py): [D7] minimal Observable per grain (subscribe/unsubscribe); no Qt signals in model.']),
 (I+'plate_controller.dart', 'factory PlateController.fromValues(', [
  'TODO(ts): drop — country golden tests use it; ports take the main constructor only.',
  'TODO(kt): drop — default args cover it.',
  'TODO(py): drop — keyword arguments cover it.']),
 (I+'plate_controller.dart', 'factory PlateController.fromText(', [
  'TODO(ts): [H7][D9] iterate Array.from(text); fromText(spec, text) -> values is a vector.',
  'TODO(kt): [H7][D9] iterate code points.',
  'TODO(py): [H7][D9] iterate the str.']),
 (I+'plate_controller.dart', 'final ValueNotifier<List<String?>?> hints', [
  'TODO(ts): [D7] a fourth store; hints never touch values or completion.',
  'TODO(kt): [D7] MutableStateFlow<List<String?>?>.',
  'TODO(py): [D7] Observable.']),
 (I+'plate_controller.dart', 'bool setGroup(String key, String value) {', [
  'TODO(ts): [H7][D9] split by code point; a chosen slot takes the rest whole. Vector it.',
  'TODO(kt): [H7][D9] code points.',
  'TODO(py): [D9] list(value).']),
 (I+'plate_controller.dart', 'ValueListenable<String?> slot(int index)', [
  'TODO(ts): [D7] out of range returns a store that is null forever, never throws.',
  'TODO(kt): [D7] out of range returns MutableStateFlow(null) that nobody writes.',
  'TODO(py): [D7] same: an Observable fixed at None.']),
 (I+'plate_controller.dart', 'void _notifyOutsideBuild(', [
  'TODO(ts): [H14] drop — notify synchronously; no build phase to dodge.',
  'TODO(kt): [H14] drop — StateFlow emission is safe during composition.',
  'TODO(py): [H14] drop — or QTimer.singleShot(0, …) if a slot re-enters painting.']),
 (I+'plate_controller.dart', 'PlateValidation? get validation {', [
  'TODO(ts): [D9] rejection outranks the validator; the probe is the render layer asking.',
  'TODO(kt): [D9] same precedence.',
  'TODO(py): [D9] same precedence.']),
 (I+'plate_controller.dart', 'void installValidation(', [
  'TODO(ts): drop the canvas-only probe/report pair; the controller takes a validator directly.',
  'TODO(kt): same: PlateController(validator = …).',
  'TODO(py): same.']),
 (I+'plate_controller.dart', 'static List<String?> _migrate(', [
  'TODO(ts): [H7] pour code points, not UTF-16 units.',
  'TODO(kt): [H7] code points.',
  'TODO(py): pure; port line for line.']),
 (I+'plate_controller.dart', 'class _AlwaysNull<T>', [
  'TODO(ts): drop — a shared frozen null store.',
  'TODO(kt): drop — MutableStateFlow(null).asStateFlow().',
  'TODO(py): drop — a shared Observable(None).']),
 (I+'plate_input_machine.dart', 'class PlateInputMachine implements PlateInputTarget {', [
  'TODO(ts): [D8] split: pure machine (active, submit, backspace, advance, firstEmpty) + DOM focus adapter.',
  'TODO(kt): [D8] pure machine in commonMain; FocusRequester list and TextFieldState in Compose.',
  'TODO(py): [D8] pure machine; QLineEdit focus + keyPressEvent adapter. No IME modes (PySide6).']),
 (I+'plate_input_machine.dart', 'final ValueNotifier<bool> systemKeyboard', [
  'TODO(ts): [D8] keypadFirst: set inputmode="text" on tap, back to "none" on a keypad key.',
  'TODO(kt): [D8] keypadFirst: LocalSoftwareKeyboardController.show()/hide().',
  'TODO(py): [D8] drop — no soft keyboard on desktop.']),
 (I+'plate_input_machine.dart', 'final List<FocusNode> _focusNodes', [
  'TODO(ts): [D8] the adapter owns HTMLInputElements; the machine only knows indices.',
  'TODO(kt): [D8] FocusRequester per slot lives in Compose, not in the machine.',
  'TODO(py): [D8] QLineEdit per slot lives in the widget.']),
 (I+'plate_input_machine.dart', 'static void _setText(', [
  'TODO(ts): [D8] set input.value and setSelectionRange(end) only when the text differs.',
  'TODO(kt): [D8] TextFieldValue(text, TextRange(text.length)).',
  'TODO(py): [D8] setText + end(False); blockSignals while syncing.']),
 (I+'plate_input_machine.dart', 'void backspaceCharacter() {', [
  'TODO(ts): [H7][D9] drop the last code point (Array.from(s).slice(0, -1)); vector the two-press rule.',
  'TODO(kt): [H7] drop the last code point, not the last Char.',
  'TODO(py): [D9] s[:-1].']),
 (I+'plate_input_machine.dart', 'void submitCharacter(String c) {', [
  'TODO(ts): [D9] pure: (values, active, char) -> (values, active); refusal never advances.',
  'TODO(kt): [D9] same.',
  'TODO(py): [D9] same.']),
]
