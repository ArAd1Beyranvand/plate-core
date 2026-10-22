import 'package:flutter_test/flutter_test.dart';
import 'package:plate_alphabet/plate_alphabet.dart';

void main() {
  test('Namibian town letters skip F, I and Q', () {
    expect(PlateAlphabetNamibia.region.characters.join(), 'ABCDEGHJKLMNOPRSTUVW');
  });

  test('Swedish last character is a digit or a letter but I, O, Q, V', () {
    expect(SwedenAlphabets.last.characters.join(), '0123456789ABCDEFGHJKLMNPRSTUWXYZ');
  });

  test('Latin picker keeps umlauts and MP after Z', () {
    final c = PlateAlphabetLetters.latinAll.characters;
    expect(c.length, 30);
    expect(c.sublist(26), ['Ä', 'Ö', 'Ü', 'MP']);
  });
}
