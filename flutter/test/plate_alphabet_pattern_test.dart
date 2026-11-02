import 'package:flutter_test/flutter_test.dart';
import 'package:plate_core/plate_core.dart';

void main() {
  test('pattern expands ranges, literals and exclusions', () {
    const a = PlateAlphabet.pattern(
      id: 't',
      include: 'A-E Ä MP 0-1',
      exclude: 'C 1',
      input: AlphabetInput.typed,
      isNumeric: false,
    );
    expect(a.characters, ['A', 'B', 'D', 'E', 'Ä', 'MP', '0']);
    expect(a.accepts('d'), isTrue);
    expect(a.accepts('C'), isFalse);
  });

  test('latin presets', () {
    expect(PlateAlphabet.latinDigits.characters.join(), '0123456789');
    expect(PlateAlphabet.latinUppercase.characters.length, 26);
  });
}
