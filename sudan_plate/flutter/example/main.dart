import 'package:flutter/material.dart';
import 'package:plate_core/plate_core.dart';
import 'package:sudan_plate/sudan_plate.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: PlateCanvas(
              spec: SudanPlates.standard,
              theme: SudanThemes.private,
              validator: const SudanValidator(),
              autoValidate: true,
              onChooseCharacter: (alphabet) async => null,
            ),
          ),
        ),
      ),
    );
  }
}
