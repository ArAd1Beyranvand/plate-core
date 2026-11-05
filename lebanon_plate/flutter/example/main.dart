import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';
import 'package:lebanon_plate/lebanon_plate.dart';

void main() => runApp(
  PlateExampleApp(spec: LebanonPlates.oneLine, theme: LebanonThemes.private),
);
