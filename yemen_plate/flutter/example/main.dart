import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';
import 'package:yemen_plate/yemen_plate.dart';

void main() => runApp(
  PlateExampleApp(spec: YemenNorthernPlates.car, theme: YemenThemes.unified),
);
