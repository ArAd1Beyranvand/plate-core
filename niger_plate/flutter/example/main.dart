import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';
import 'package:niger_plate/niger_plate.dart';

void main() => runApp(
  PlateExampleApp(
    spec: NigerPlates.privateSpec,
    theme: NigerThemes.private,
    validator: const NigerValidator(),
    autoValidate: true,
  ),
);
