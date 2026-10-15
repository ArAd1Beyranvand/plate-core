import 'package:flutter/material.dart';
import 'package:algeria_plate/algeria_plate.dart';
import 'package:plate_core/plate_core.dart';

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
              spec: AlgeriaPlates.singleLine,
              theme: AlgeriaThemes.front,
              validator: const AlgeriaValidator(),
              autoValidate: true,
              onChooseCharacter: (alphabet) async => null,
            ),
          ),
        ),
      ),
    );
  }
}
