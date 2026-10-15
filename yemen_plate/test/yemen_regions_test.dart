import 'package:flutter_test/flutter_test.dart';
import 'package:yemen_plate/yemen_plate.dart';

void main() {
  test('unambiguous digits resolve at once', () {
    expect(YemenRegions.lookup('3'), 'Aden');
    expect(YemenRegions.lookup('9'), 'Dhamar');
  });

  test('prefixes of longer codes are null until pinned', () {
    expect(YemenRegions.lookup('1'), isNull);
    expect(YemenRegions.lookup('2'), isNull);
    expect(YemenRegions.lookup('12'), 'Lahij');
    expect(YemenRegions.lookup('22'), 'Socotra');
  });

  test('empty, zero and unissued are null', () {
    expect(YemenRegions.lookup(''), isNull);
    expect(YemenRegions.lookup('0'), isNull);
    expect(YemenRegions.lookup('23'), isNull);
  });
}
