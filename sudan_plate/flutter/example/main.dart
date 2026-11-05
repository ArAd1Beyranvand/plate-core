import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';
import 'package:sudan_plate/sudan_plate.dart';

void main() => runApp(
  PlateExampleApp(
    spec: SudanPlates.standard,
    theme: SudanThemes.private,
    validator: const SudanValidator(),
    autoValidate: true,
  ),
);
