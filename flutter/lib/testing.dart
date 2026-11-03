/// Golden-test harness shared by every country package.
///
/// Import from a package's `test/` only: it pulls in `flutter_test`.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'plate_core.dart';

/// One golden: the spec, its theme, and a sample value with one
/// [plateGoldens] `separator`-separated token per slot (`'AB 1234'`, never
/// `'A B 1 2 3 4'`). An empty value leaves every slot blank.
typedef PlateGoldenCase = (PlateSpec, PlateTheme, String);

/// The bold face every golden is drawn with, so the ink can be measured
/// against the references (`platekit golden-check`).
const String plateGoldenFont =
    '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf';

/// Registers one golden test per entry of [cases], written to
/// `goldens/<prefix>_<key>.png` and drawn on a 680×300 stage under
/// [country]'s panel (each spec's own country when null).
///
/// [fonts] are extra faces loaded after [plateGoldenFont] (a script the
/// default face lacks). [decodeDelay] gives decals that decode off the fake
/// clock real time before the picture is taken.
///
/// Regenerate with `flutter test --update-goldens` after a deliberate change.
void plateGoldens(
  String prefix,
  PlateCountry? country,
  Map<String, PlateGoldenCase> cases, {
  List<String> fonts = const <String>[],
  String separator = ' ',
  Duration? decodeDelay,
}) {
  setUpAll(() async {
    final FontLoader loader = FontLoader('Roboto');
    for (final String path in <String>[plateGoldenFont, ...fonts]) {
      final File face = File(path);
      if (!face.existsSync()) continue;
      loader.addFont(face.readAsBytes().then((b) => ByteData.view(b.buffer)));
    }
    await loader.load();
  });

  for (final MapEntry<String, PlateGoldenCase> c in cases.entries) {
    testWidgets(c.key, (tester) async {
      final (PlateSpec spec, PlateTheme theme, String values) = c.value;
      await pumpPlateGolden(
        tester,
        PlateController.fromValues(
          spec,
          values.isEmpty ? const <String>[] : values.split(separator),
        ),
        'goldens/${prefix}_${c.key}.png',
        theme: theme,
        country: country ?? spec.country,
        decodeDelay: decodeDelay,
      );
    });
  }
}

/// Draws [controller]'s plate centred on a [stage]-sized box, compares it
/// with the golden file [golden], then unmounts and disposes [controller].
///
/// With a [theme] the plate sits under a [PlateThemeScope] of it, unless
/// [scoped] is false; without one it takes the default. [decodeDelay] gives decals that decode off the fake
/// clock real time before the picture is taken.
Future<void> pumpPlateGolden(
  WidgetTester tester,
  PlateController controller,
  String golden, {
  PlateTheme? theme,
  bool scoped = true,
  PlateCountry? country,
  Size stage = const Size(680, 300),
  Duration? decodeDelay,
}) async {
  final Widget view = PlateView(
    controller: controller,
    theme: theme,
    country: country,
  );
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox.fromSize(
            size: stage,
            child: theme == null || !scoped
                ? view
                : PlateThemeScope(theme: theme, child: view),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  if (decodeDelay != null) {
    await tester.runAsync(() => Future<void>.delayed(decodeDelay));
    await tester.pumpAndSettle();
  }
  await expectLater(find.byType(PlateView), matchesGoldenFile(golden));
  // Unmount before disposing: the canvas detaches from the controller on
  // dispose, which notifies listeners.
  await tester.pumpWidget(const SizedBox.shrink());
  controller.dispose();
}
