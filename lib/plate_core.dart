/// Data-driven vehicle licence plates for Flutter.
///
/// A plate is a `const` [PlateSpec]: canvas geometry, a country panel, slots
/// over alphabets, and optional chrome. The widget layer paints whatever a spec
/// describes, so adding a plate means adding a const, never a widget.
///
/// - **No country knowledge.** Nothing here names a country and no assets ship
///   with it; the EU star ring is drawn in code; plates, alphabets and flags live in each
///   country's own package. A country name in this package, even in a comment,
///   is a bug.
/// - **No input policing.** A [PlateValidator] judges a plate and never bars a
///   keystroke. The one exception is a [PlateRestriction] a spec declares.
/// - **No keyboard ownership.** [PlateInputSource] lets the host feed
///   characters from its own UI through a [PlateController].
/// - **No state-management opinion.** A plate's characters live in a
///   [PlateController], a [ChangeNotifier].
///
/// Anything under `src/` that is not exported is an implementation detail.
library;

export 'src/animation/plate_animation.dart';
export 'src/animation/plate_part_animator.dart'
    show PlatePartAnimator, PlatePartFrame, plateRevealRect;
export 'src/input/plate_controller.dart';
export 'src/input/plate_input_controller.dart';
export 'src/model/plate_alphabet.dart';
export 'src/model/plate_asset.dart';
export 'src/model/plate_box.dart';
export 'src/model/european_stars.dart';
export 'src/model/plate_country.dart';
export 'src/model/plate_input_source.dart';
export 'src/model/plate_layout.dart';
export 'src/model/plate_number.dart';
export 'src/model/plate_restriction.dart';
export 'src/model/plate_shape.dart';
export 'src/model/plate_spec.dart';
export 'src/model/slot_behavior.dart' show SlotBehavior;
export 'src/theme/plate_theme.dart';
export 'src/validators/plate_validator.dart';
export 'src/widgets/country_panel.dart';
export 'src/widgets/plate_canvas.dart';
export 'src/widgets/plate_divider.dart' show PlateDivider, DividerOrigin;
export 'src/widgets/plate_drawing_view.dart';
export 'src/widgets/plate_flag.dart';
export 'src/widgets/plate_selector.dart';
export 'src/widgets/plate_text_row.dart';
export 'src/widgets/plate_view.dart';
