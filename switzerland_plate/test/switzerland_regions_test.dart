import 'package:flutter_test/flutter_test.dart';
import 'package:switzerland_plate/switzerland_plate.dart';

void main() {
  test('canton codes resolve', () {
    expect(SwitzerlandRegions.lookup('ZH'), 'Zürich');
    expect(SwitzerlandRegions.lookup('zh'), 'Zürich');
  });

  test('partial and unissued codes are null', () {
    expect(SwitzerlandRegions.lookup(''), isNull);
    expect(SwitzerlandRegions.lookup('Z'), isNull);
    expect(SwitzerlandRegions.lookup('XX'), isNull);
  });
}
