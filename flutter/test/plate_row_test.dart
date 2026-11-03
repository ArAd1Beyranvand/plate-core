import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:plate_core/plate_core.dart';

void main() {
  const digits = PlateAlphabet.latinDigits;

  test('plateRun anchors by left or centre, length × pitch wide', () {
    final a = plateRun(digits, 4, pitch: 50, left: 10, top: 2, height: 100);
    expect(a.box.rect, const Rect.fromLTWH(10, 2, 200, 100));
    expect(a.length, 4);
    expect(a.spacing, plateRunSpacing(50, 100));
    final b = plateRun(digits, 2, pitch: 40, centre: 100, top: 0, height: 80);
    expect(b.box.left, 60);
    expect(b.box.width, 80);
  });

  test('plateRow places runs, text and gaps in order', () {
    final row = plateRow(
      const [
        PlateRowRun(digits, 3, group: 'a'),
        PlateRowText('-', 20),
        PlateRowRun(digits, 2, group: 'b', minLength: 1),
        PlateRowGap(30),
        PlateRowRun(digits, 1, pitch: 10),
      ],
      pitch: 40,
      top: 5,
      height: 90,
      left: 0,
      gap: 10,
    );
    expect(row.slots.map((s) => s.box.left), [0, 160, 290]);
    expect(row.slots.map((s) => s.box.width), [120, 80, 10]);
    expect(row.slots.map((s) => s.group), ['a', 'b', null]);
    expect(row.slots[1].minLength, 1);
    expect(row.labels.single.box.rect, const Rect.fromLTWH(130, 5, 20, 90));
    expect(row.labels.single.glyphHeight, 90);
  });

  test('a centred row is centred on its whole width', () {
    final row = plateRow(
      const [PlateRowRun(digits, 2), PlateRowRun(digits, 2)],
      pitch: 10,
      top: 0,
      height: 10,
      centre: 100,
      gap: 20,
    );
    expect(row.slots.first.box.left, 70);
    expect(row.slots.last.box.right, 130);
  });

  test('pinned items sit where measured; the row carries on after them', () {
    final row = plateRow(
      const [
        PlateRowRun(digits, 2, centre: 100),
        PlateRowRun(digits, 1),
        PlateRowText('H', null, 300),
      ],
      pitch: 10,
      top: 0,
      height: 10,
    );
    expect(row.slots.map((s) => s.box.left), [90, 110]);
    expect(row.labels.single.box.left, 300);
  });
}
