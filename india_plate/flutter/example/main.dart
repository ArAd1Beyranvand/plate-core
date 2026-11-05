import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';
import 'package:india_plate/india_plate.dart';

void main() => runApp(
  PlateExampleApp(spec: IndiaPlates.private, theme: IndiaThemes.private),
);
