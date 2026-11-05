import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';
import 'package:malaysia_plate/malaysia_plate.dart';

void main() => runApp(
  PlateExampleApp(
    spec: MalaysiaPlates.singleRow(),
    theme: MalaysiaThemes.standard,
    validator: const MalaysiaValidator(),
    autoValidate: true,
  ),
);
