import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plate_core/plate_core.dart';
import 'package:plate_core/src/input/plate_input_machine.dart';

const _country = PlateCountry(
  code: 'zz',
  captionLines: ['ZZ'],
  panelColor: Color(0xFF003399),
  panelTextColor: Color(0xFFFFFFFF),
);

/// A two-digit field, a letter, a three-digit field.
final _spec = PlateSpec(
  id: 'zz.run',
  country: _country,
  canvasWidth: 200,
  canvasHeight: 60,
  panel: const PlatePanel(box: PlateBox(0, 0, 10, 60)),
  slots: const [
    PlateSlot(alphabet: PlateAlphabet.latinDigits, box: PlateBox(20, 5, 40, 50), length: 2),
    PlateSlot(alphabet: PlateAlphabet.latinUppercase, box: PlateBox(70, 5, 20, 50)),
    PlateSlot(alphabet: PlateAlphabet.latinDigits, box: PlateBox(100, 5, 60, 50), length: 3),
  ],
);

void main() {
  test('a run slot holds up to its length and no more', () {
    final slot = _spec.slots[0];
    expect(slot.accepts('1'), isTrue);
    expect(slot.accepts('12'), isTrue);
    expect(slot.accepts('123'), isFalse);
    expect(slot.accepts('1A'), isFalse);
    expect(slot.isFull('1'), isFalse);
    expect(slot.isFull('12'), isTrue);
  });

  test('completion needs every run full', () {
    final c = PlateController(spec: _spec, values: ['12', 'A', '34']);
    expect(c.completed.value, isFalse);
    c.setAt(2, '345');
    expect(c.completed.value, isTrue);
    c.setAt(2, '3456');
    expect(c.valueAt(2), '345');
  });

  test('fromText pours characters into runs', () {
    final c = PlateController.fromText(_spec, '12 A 345');
    expect(c.values, ['12', 'A', '345']);
  });

  test('keypad characters fill a run before focus moves on', () {
    var values = <String?>[null, null, null];
    final machine = PlateInputMachine(
      spec: _spec,
      readValues: () => values,
      commit: (i, v) {
        values = List.of(values)..[i] = v;
        return true;
      },
      inputSource: PlateInputSource.host,
    );
    machine.focusSlot(0);
    machine.submitCharacter('1');
    expect(values[0], '1');
    machine.submitCharacter('2');
    expect(values[0], '12');
    machine.dispose();
  });

  test('a variable field completes at minLength and fills at length', () {
    const slot = PlateSlot(
      alphabet: PlateAlphabet.latinDigits,
      box: PlateBox(0, 0, 60, 50),
      length: 6,
      minLength: 4,
    );
    expect(slot.isComplete('123'), isFalse);
    expect(slot.isComplete('1234'), isTrue);
    expect(slot.isFull('1234'), isFalse);
    expect(slot.isFull('123456'), isTrue);
    expect(slot.accepts('1234567'), isFalse);

    final spec = PlateSpec(
      id: 'zz.var',
      country: _country,
      canvasWidth: 200,
      canvasHeight: 60,
      panel: const PlatePanel(box: PlateBox(0, 0, 10, 60)),
      slots: const [slot],
    );
    final controller = PlateController(spec: spec);
    controller.setAt(0, '123');
    expect(controller.isCompleted, isFalse);
    controller.setAt(0, '1234');
    expect(controller.isCompleted, isTrue);
    controller.dispose();
  });
}
