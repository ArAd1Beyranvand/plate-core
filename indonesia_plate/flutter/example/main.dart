import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';
import 'package:indonesia_plate/indonesia_plate.dart';

void main() => runApp(
  PlateExampleApp(
    spec: IndonesiaPlates.car,
    theme: IndonesiaThemes.private,
    validator: const IndonesiaValidator(),
    autoValidate: true,
  ),
);
