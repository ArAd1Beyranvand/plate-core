import 'package:plate_core/plate_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Under [PlateInputSource.keypadFirst] a keypad key must close the text input
/// connection, not just hide the keyboard: on the web an open connection, even
/// one asking for no keyboard, leaves the keyboard's space blank.

const _country = PlateCountry(
  code: 'zz',
  captionLines: ['ZZ'],
  panelColor: Color(0xFF003399),
  panelTextColor: Color(0xFFFFFFFF),
);

final PlateSpec _spec = PlateSpec(
  id: 'zz.keypadfirst',
  country: _country,
  canvasWidth: 400,
  canvasHeight: 100,
  panel: const PlatePanel(box: PlateBox(0, 0, 10, 40)),
  slots: <PlateSlot>[
    for (int i = 0; i < 2; i++)
      PlateSlot(alphabet: PlateAlphabet.latinDigits, box: PlateBox(20 + i * 25.0, 5, 20, 30)),
  ],
);

void main() {
  testWidgets('a tap opens the keyboard; a keypad key closes the connection', (tester) async {
    final PlateController controller = PlateController(spec: _spec);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlateCanvas(
            spec: _spec,
            controller: controller,
            inputSource: PlateInputSource.keypadFirst,
            onChooseCharacter: (PlateAlphabet a) async => null,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextField).first);
    await tester.pumpAndSettle();
    expect(controller.systemKeyboardActive, isTrue);
    expect(tester.testTextInput.hasAnyClients, isTrue);

    controller.submit('7');
    await tester.pumpAndSettle();
    expect(controller.systemKeyboardActive, isFalse);
    expect(tester.testTextInput.hasAnyClients, isFalse);
    expect(controller.activeIndex, 1, reason: 'the slot stays active for the keypad');

    controller.backspace();
    await tester.pumpAndSettle();
    expect(tester.testTextInput.hasAnyClients, isFalse);
    expect(controller.values, [null, null]);
    expect(controller.activeIndex, 0);
  });
}
