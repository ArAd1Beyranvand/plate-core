import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';
import 'package:tunisia_plate/tunisia_plate.dart';

void main() => runApp(
  PlateExampleApp(
    spec: TunisiaPlates.standard,
    theme: TunisiaThemes.standard,
    validator: const TunisiaValidator(),
    autoValidate: true,
  ),
);
