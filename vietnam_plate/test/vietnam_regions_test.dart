import 'package:flutter_test/flutter_test.dart';
import 'package:vietnam_plate/vietnam_plate.dart';

void main() {
  test('province codes resolve, including multi-code provinces', () {
    expect(VietnamRegions.lookup('29'), 'Hà Nội');
    expect(VietnamRegions.lookup('33'), 'Hà Nội');
    expect(VietnamRegions.lookup('51'), 'Hồ Chí Minh City');
    expect(VietnamRegions.lookup('11'), 'Cao Bằng');
  });

  test('partial, national and unissued codes are null', () {
    expect(VietnamRegions.lookup(''), isNull);
    expect(VietnamRegions.lookup('2'), isNull);
    expect(VietnamRegions.lookup('80'), isNull);
    expect(VietnamRegions.lookup('00'), isNull);
  });
}
