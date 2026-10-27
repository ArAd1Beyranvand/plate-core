import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plate_core/src/widgets/plate_glyph_run.dart';

Widget _run(String text) => Directionality(
  textDirection: TextDirection.ltr,
  child: Center(
    child: PlateGlyphRun(
      text: text,
      style: const TextStyle(fontSize: 20),
      textDirection: TextDirection.ltr,
      placeholder: '?',
    ),
  ),
);

Finder _glyph(String text) => find.byWidgetPredicate((w) => w is Text && w.data == text);

double _opacityOf(WidgetTester tester, String text) => tester
    .widget<Opacity>(find.ancestor(of: _glyph(text), matching: find.byType(Opacity)).first)
    .opacity;

void main() {
  testWidgets('characters present at mount show at once', (tester) async {
    await tester.pumpWidget(_run('12'));
    expect(_opacityOf(tester, '1'), 1);
    expect(_opacityOf(tester, '2'), 1);
  });

  testWidgets('an added character animates in', (tester) async {
    await tester.pumpWidget(_run('1'));
    await tester.pumpWidget(_run('12'));
    expect(_opacityOf(tester, '2'), 0);
    await tester.pump(PlateGlyphRun.enter ~/ 2);
    expect(_opacityOf(tester, '2'), inExclusiveRange(0, 1));
    await tester.pumpAndSettle();
    expect(_opacityOf(tester, '2'), 1);
    expect(_opacityOf(tester, '1'), 1);
  });

  testWidgets('a removed character animates out, then is gone', (tester) async {
    await tester.pumpWidget(_run('12'));
    await tester.pumpWidget(_run('1'));
    await tester.pump(PlateGlyphRun.leave ~/ 2);
    expect(_glyph('2'), findsOneWidget);
    expect(_opacityOf(tester, '2'), inExclusiveRange(0, 1));
    await tester.pumpAndSettle();
    expect(_glyph('2'), findsNothing);
    expect(_glyph('1'), findsOneWidget);
  });

  testWidgets('a replaced character leaves while its successor enters', (tester) async {
    await tester.pumpWidget(_run('12'));
    await tester.pumpWidget(_run('13'));
    await tester.pump(PlateGlyphRun.leave ~/ 2);
    expect(_glyph('2'), findsOneWidget);
    expect(_glyph('3'), findsOneWidget);
    expect(tester.getCenter(_glyph('2')).dx, lessThan(tester.getCenter(_glyph('3')).dx));
    await tester.pumpAndSettle();
    expect(_glyph('2'), findsNothing);
    expect(_opacityOf(tester, '3'), 1);
  });

  testWidgets('the placeholder fades out as the first character arrives', (tester) async {
    double placeholder() => tester
        .widget<AnimatedOpacity>(
          find.ancestor(of: _glyph('?'), matching: find.byType(AnimatedOpacity)),
        )
        .opacity;
    await tester.pumpWidget(_run(''));
    expect(placeholder(), 1);
    await tester.pumpWidget(_run('1'));
    expect(placeholder(), 0);
  });
}
