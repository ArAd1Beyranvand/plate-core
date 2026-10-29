import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

// TODO(ts): [H15] structural equality and a lerp(a, b, t) over every field for the cross-fade.
// TODO(kt): [H15] a data class is right here (equality is structural); add lerp.
// TODO(py): [H15] frozen dataclass (structural eq is right) + lerp; replace() is copyWith.
/// Chrome colours and ratios, sampled from real plates; never tint them with a
/// host accent. Only [activeColor] and [inactiveColor], used solely for
/// input-mode outlines, are chrome-free.
///
/// The `*Ratio` fields are fractions of the plate height.
@immutable
class PlateTheme {
  const PlateTheme({
    required this.plateBackground,
    required this.plateBorder,
    required this.ink,
    required this.dividerColor,
    required this.borderWidthRatio,
    required this.plateRadiusRatio,
    required this.activeColor,
    required this.inactiveColor,
    this.alertColor = const Color(0xFFF87171),
  });

  final Color plateBackground;
  final Color plateBorder;
  final Color ink;
  final Color dividerColor;
  final double borderWidthRatio;
  final double plateRadiusRatio;

  /// Outline of a completed input field.
  final Color activeColor;

  /// Outline of an empty or in-progress input field.
  final Color inactiveColor;

  /// Outline [PlateCanvas] paints when validating an invalid plate.
  final Color alertColor;

  /// White face, black frame.
  factory PlateTheme.standard() => const PlateTheme(
    plateBackground: Color(0xFFFFFFFF),
    plateBorder: Color(0xFF000000),
    ink: Color(0xFF0A0A0A),
    dividerColor: Color(0xFF000000),
    borderWidthRatio: 0.04,
    plateRadiusRatio: 0.12,
    activeColor: Color(0xFF0A0A0A),
    inactiveColor: Color(0x66666666),
  );

  /// A plate printed in one ink on one field: [ink] is the border, glyphs,
  /// rules and completed-field outline. [inactive] is input chrome only (the
  /// outline under an empty field) and so has no default.
  const PlateTheme.monochrome({
    required Color field,
    required Color ink,
    required Color inactive,
    required double borderWidthRatio,
    required double plateRadiusRatio,
    Color alertColor = const Color(0xFFF87171),
  }) : this(
         plateBackground: field,
         plateBorder: ink,
         ink: ink,
         dividerColor: ink,
         borderWidthRatio: borderWidthRatio,
         plateRadiusRatio: plateRadiusRatio,
         activeColor: ink,
         inactiveColor: inactive,
         alertColor: alertColor,
       );

  PlateTheme copyWith({
    Color? plateBackground,
    Color? plateBorder,
    Color? ink,
    Color? dividerColor,
    double? borderWidthRatio,
    double? plateRadiusRatio,
    Color? activeColor,
    Color? inactiveColor,
    Color? alertColor,
  }) => PlateTheme(
    plateBackground: plateBackground ?? this.plateBackground,
    plateBorder: plateBorder ?? this.plateBorder,
    ink: ink ?? this.ink,
    dividerColor: dividerColor ?? this.dividerColor,
    borderWidthRatio: borderWidthRatio ?? this.borderWidthRatio,
    plateRadiusRatio: plateRadiusRatio ?? this.plateRadiusRatio,
    activeColor: activeColor ?? this.activeColor,
    inactiveColor: inactiveColor ?? this.inactiveColor,
    alertColor: alertColor ?? this.alertColor,
  );

  // TODO(ts): [H12][D6-font] font-size slotHeight*0.72, line-height 1, weight 700, explicit family.
  // TODO(kt): [H12][D6-font] fontSize in px→sp via LocalDensity, lineHeight = 1.em, Bold.
  // TODO(py): [H12][D6-font] QFont pixel size h*0.72, bold; QFontMetricsF for the box, not point size.
  TextStyle glyphStyle(
    double slotHeight,
    Color color, {
    double letterSpacing = 0,
  }) => TextStyle(
    color: color,
    fontWeight: FontWeight.w700,
    fontSize: slotHeight * 0.72,
    height: 1.0,
    letterSpacing: letterSpacing,
  );

  // TODO(ts): [H14] drop — the theme is an explicit argument to render().
  // TODO(kt): [H14] CompositionLocal LocalPlateTheme, default standard().
  // TODO(py): [H14] drop — pass the theme to the widget.
  /// The enclosing [PlateThemeScope]'s theme, else [PlateTheme.standard].
  static PlateTheme of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PlateThemeScope>()?.theme ??
      PlateTheme.standard();

  List<Object?> get _props => [
    plateBackground,
    plateBorder,
    ink,
    dividerColor,
    borderWidthRatio,
    plateRadiusRatio,
    activeColor,
    inactiveColor,
    alertColor,
  ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlateTheme && listEquals(other._props, _props);

  @override
  int get hashCode => Object.hashAll(_props);
}

// TODO(ts): [H14] drop — no scope; see PlateTheme.of.
// TODO(kt): [H14] CompositionLocalProvider(LocalPlateTheme provides theme).
// TODO(py): [H14] drop.
class PlateThemeScope extends InheritedWidget {
  const PlateThemeScope({super.key, required this.theme, required super.child});

  final PlateTheme theme;

  @override
  bool updateShouldNotify(PlateThemeScope oldWidget) =>
      theme != oldWidget.theme;
}
