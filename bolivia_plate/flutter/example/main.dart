import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';
import 'package:bolivia_plate/bolivia_plate.dart';

void main() => runApp(
  PlateExampleApp(
    spec: BoliviaPlates.standard(),
    theme: BoliviaThemes.standard,
    validator: const BoliviaValidator(),
    autoValidate: true,
  ),
);
