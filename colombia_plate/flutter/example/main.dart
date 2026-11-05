import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';
import 'package:colombia_plate/colombia_plate.dart';

void main() => runApp(
  PlateExampleApp(
    spec: ColombiaPlates.standard(),
    theme: ColombiaThemes.private,
    validator: const ColombiaValidator(),
    autoValidate: true,
  ),
);
