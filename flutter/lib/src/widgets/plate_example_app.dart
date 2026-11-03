import 'package:flutter/material.dart';

import '../model/plate_spec.dart';
import '../theme/plate_theme.dart';
import '../validators/plate_validator.dart';
import 'plate_canvas.dart';

/// The smallest app that shows one editable plate: tap a slot and type to
/// fill it in. Every country package's `example/` runs one.
class PlateExampleApp extends StatelessWidget {
  const PlateExampleApp({
    super.key,
    required this.spec,
    this.theme,
    this.validator,
    this.autoValidate = false,
  });

  final PlateSpec spec;
  final PlateTheme? theme;
  final PlateValidator? validator;
  final bool autoValidate;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: PlateCanvas(
              spec: spec,
              theme: theme,
              validator: validator,
              autoValidate: autoValidate,
              onChooseCharacter: (alphabet) async => null,
            ),
          ),
        ),
      ),
    );
  }
}
