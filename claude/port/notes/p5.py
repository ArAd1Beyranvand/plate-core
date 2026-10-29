T = 'plate_core/test/'
NOTES = [
 (T + 'national_numerals_test.dart', 'testWidgets(', [
  'TODO(ts): ui test: typing a national numeral through the canvas; port as a DOM test.',
  'TODO(kt): ui test: compose UI test.',
  'TODO(py): ui test: pytest-qt.']),
 (T + 'plate_restriction_test.dart', "testWidgets('canvas refuses typing", [
  'TODO(ts): ui test: banner shown, focus kept; the refusal itself is in the controller vectors.',
  'TODO(kt): ui test: same.',
  'TODO(py): ui test: same.']),
 (T + 'plate_backspace_test.dart', 'void main()', [
  'TODO(ts): [D8] key-event routing through focused fields; keep the machine half as vectors, this as ui.',
  'TODO(kt): [D8] same; ui tests send KeyEvents.',
  'TODO(py): [D8] same; QTest.keyClick.']),
 (T + 'plate_external_focus_test.dart', 'void main()', [
  'TODO(ts): [D8] focus moving to a host field; DOM focus test.',
  'TODO(kt): [D8] FocusRequester test.',
  'TODO(py): [D8] QWidget focus test.']),
 (T + 'plate_drawing_test.dart', "testWidgets('PlateDrawingView", [
  'TODO(ts): [D6] paint smoke test; compare an SVG snapshot instead.',
  'TODO(kt): [D6] screenshot test.',
  'TODO(py): [D6] QImage render test.']),
 (T + 'plate_country_override_test.dart', "group('PlateCanvas.country'", [
  'TODO(ts): ui test: override reaches the panel and leaves the machine alone.',
  'TODO(kt): ui test: same; check the controller is not recreated.',
  'TODO(py): ui test: same.']),
 (T + 'plate_glyph_run_test.dart', 'void main()', [
  'TODO(ts): [H7] the old/new glyph diff is vectorable; the timing assertions stay ui tests.',
  'TODO(kt): [H7] same.',
  'TODO(py): [H7] same.']),
 (T + 'plate_keypad_first_test.dart', 'void main()', [
  'TODO(ts): [D8] IME connection open/closed is platform behaviour; manual test on mobile web.',
  'TODO(kt): [D8] check no InputConnection while the keypad shows.',
  'TODO(py): drop — Qt has no soft keyboard split.']),
 (T + 'plate_input_machine_test.dart', 'void main()', [
  'TODO(ts): [D8] testWidgets only for FocusNodes: the state half becomes vectors, focus half ui tests.',
  'TODO(kt): [D8] same split.',
  'TODO(py): [D8] same split.']),
 (T + 'plate_canvas_rebuild_test.dart', 'void main()', [
  'TODO(ts): [H14] drop — counts Flutter rebuilds; no equivalent.',
  'TODO(kt): [H14] drop — or a recomposition counter if worth it.',
  'TODO(py): [H14] drop.']),
 (T + 'plate_text_row_test.dart', 'void main()', [
  'TODO(ts): [D1] group order and prefix are vectorable; colour default is a ui test.',
  'TODO(kt): same.',
  'TODO(py): same.']),
]
