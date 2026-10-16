import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plate_core/plate_core.dart';

void main() {
  const red = Color(0xFFFF0000);

  group('PlateShape.toPath', () {
    test('rect covers its bounds', () {
      final b = const PlateRectShape(1, 2, 3, 4, red).toPath().getBounds();
      expect(b, const Rect.fromLTWH(1, 2, 3, 4));
    });

    test('ring has a hole', () {
      final p = const PlateRingShape(10, 10, 5, 2, red).toPath();
      expect(p.contains(const Offset(10, 10)), isFalse);
      expect(p.contains(const Offset(15, 10)), isTrue);
    });

    test('crescent keeps the side away from the bite', () {
      final p = const PlateCrescentShape(10, 10, 5, 2, 4, red).toPath();
      expect(p.contains(const Offset(6, 10)), isTrue);
      expect(p.contains(const Offset(13, 10)), isFalse);
    });

    test('star ring puts the first star straight above the centre', () {
      final b = const PlateStarRingShape(50, 50, 20, 4, 12, red)
          .toPath()
          .getBounds();
      expect(b.top, closeTo(50 - 20 - 4, 1e-6));
    });
  });

  group('PlateDecal', () {
    test('needs exactly one of image and drawing', () {
      const drawing = PlateDrawing(1, 1, []);
      expect(
        () => PlateDecal(box: const PlateBox(0, 0, 1, 1)),
        throwsAssertionError,
      );
      expect(
        PlateDecal(drawing: drawing, box: const PlateBox(0, 0, 1, 1))
            .drawing,
        drawing,
      );
    });
  });

  testWidgets('PlateDrawingView paints a drawing', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          child: SizedBox(
            width: 90,
            height: 60,
            child: PlateDrawingView(drawing: EuropeanStars.flag),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(PlateDrawingView)), const Size(90, 60));
  });
}
