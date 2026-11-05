import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';
import 'package:algeria_plate/algeria_plate.dart';

void main() => runApp(
  PlateExampleApp(
    spec: AlgeriaPlates.singleLine,
    theme: AlgeriaThemes.front,
    validator: const AlgeriaValidator(),
    autoValidate: true,
  ),
);
