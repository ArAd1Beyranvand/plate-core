import 'package:flutter/widgets.dart';

import '../animation/plate_animation.dart';
import '../animation/plate_part_animator.dart';
import '../model/plate_country.dart';
import '../model/plate_spec.dart';
import '../theme/plate_theme.dart';
import 'plate_flag.dart';

/// The coloured block of a plate: flag and caption, laid out LTR whatever the
/// plate's direction. Everything country-specific comes from [PlateCountry].
class CountryPanel extends StatelessWidget {
  const CountryPanel({
    super.key,
    required this.panel,
    this.theme,
    required this.country,
    this.paintBlock = true,
  });

  final PlateTheme? theme;
  final PlateCountry country;
  final PlatePanel panel;

  /// False when the background already paints the block as a
  /// [PlateFill.panel] region, so the panel lays out only flag and wording.
  final bool paintBlock;

  @override
  Widget build(BuildContext context) {
    final block = _Block(panel: panel, theme: theme, country: country, paintBlock: paintBlock);
    // Outside the ColoredBox, so the shape cuts the block's own colour too.
    final shape = panel.shape;
    return shape == null ? block : ClipPath(clipper: shape, child: block);
  }
}

/// The block itself: the country's colour, and the flag and wording on it.
class _Block extends StatelessWidget {
  const _Block({
    required this.panel,
    required this.theme,
    required this.country,
    required this.paintBlock,
  });

  final bool paintBlock;
  final PlateTheme? theme;
  final PlateCountry country;
  final PlatePanel panel;

  @override
  Widget build(BuildContext context) {
    // The panel is always placed at its box, so the box is its size.
    final box = panel.box;
    final resolvedPadding = panel.padding ?? EdgeInsets.all(box.height * 0.10);
    final innerW = box.width - resolvedPadding.horizontal;
    final innerH = box.height - resolvedPadding.vertical;
    final flag = _flagSize(panel: panel, country: country, innerW: innerW, innerH: innerH);
    final horizontal = panel.direction == Axis.horizontal;
    // The room the flag leaves: a heading and a caption split it
    // evenly, either alone takes all of it.
    final hasHeading = country.headingLines.isNotEmpty;
    final slackW = horizontal ? (innerW - flag.width).clamp(0.0, innerW) : null;
    final slackH = horizontal ? null : (innerH - flag.height).clamp(0.0, innerH);
    final share = hasHeading ? 0.5 : 1.0;

    final flagBox = SizedBox(
      width: flag.width,
      height: flag.height,
      child: PlatePartAnimator(
        id: PlatePartId.flag,
        child: PlateFlag(country: country),
      ),
    );
    final children = <Widget>[
      if (hasHeading)
        PlatePartAnimator(
          id: PlatePartId.caption,
          child: _PanelWording(
            lines: country.headingLines,
            color: country.panelTextColor,
            scale: panel.captionScale,
            alignment: Alignment.centerLeft,
            width: slackW == null ? null : slackW * share,
            height: slackH == null ? null : slackH * share,
          ),
        ),
      horizontal ? flagBox : Center(child: flagBox),
      PlatePartAnimator(
        id: PlatePartId.caption,
        child: _PanelWording(
          lines: country.captionLines,
          color: country.panelTextColor,
          scale: panel.captionScale,
          alignment: horizontal ? Alignment.centerRight : Alignment.centerLeft,
          width: slackW == null ? null : slackW * share,
          height: slackH == null ? null : slackH * share,
        ),
      ),
    ];
    final content = Padding(
      padding: resolvedPadding,
      child: horizontal
          ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: children)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: children,
            ),
    );
    return Directionality(
      textDirection: TextDirection.ltr,
      child: PlatePartAnimator(
        id: PlatePartId.panel,
        selfPainted: true,
        child: _BlockFill(
          color: paintBlock ? country.panelColor : const Color(0x00000000),
          child: content,
        ),
      ),
    );
  }
}

/// The block's colour, revealed by the panel part; settled it paints what a
/// `ColoredBox` does.
class _BlockFill extends StatelessWidget {
  const _BlockFill({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _BlockPainter(frame: PlatePartAnimator.of(context), color: color),
    child: child,
  );
}

class _BlockPainter extends CustomPainter {
  _BlockPainter({required this.frame, required this.color}) : super(repaint: frame.progress);

  final PlatePartFrame frame;
  final Color color;
  final Paint _paint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    if (color.a == 0 || frame.hidden) return;
    final bounds = Offset.zero & size;
    _paint.color = color;
    switch (frame.motion.effect) {
      case PlatePartEffect.fade || PlatePartEffect.fadeScale || PlatePartEffect.fadeSlide:
        _paint.color = color.withValues(alpha: color.a * frame.shown);
        canvas.drawRect(bounds, _paint);
      case PlatePartEffect.wipe || PlatePartEffect.draw:
        canvas.drawRect(plateRevealRect(bounds, frame.motion.origin, frame), _paint);
    }
  }

  @override
  bool shouldRepaint(_BlockPainter old) => !identical(old.frame, frame) || old.color != color;
}

Size _flagSize({
  required PlatePanel panel,
  required PlateCountry country,
  required double innerW,
  required double innerH,
}) {
  if (panel.direction == Axis.horizontal) {
    var flagH = innerH * panel.flagScale;
    var flagW = flagH * country.flagAspectRatio;
    if (flagW > innerW) {
      flagW = innerW;
      flagH = flagW / country.flagAspectRatio;
    }
    return Size(flagW, flagH);
  }
  var flagW = innerW * panel.flagScale;
  var flagH = flagW / country.flagAspectRatio;
  if (flagH > innerH) {
    flagH = innerH;
    flagW = flagH * country.flagAspectRatio;
  }
  return Size(flagW, flagH);
}

/// One band of wording (heading or caption), scaled to available space.
class _PanelWording extends StatelessWidget {
  const _PanelWording({
    required this.lines,
    required this.color,
    required this.scale,
    required this.alignment,
    required this.width,
    required this.height,
  });

  final List<String> lines;
  final Color color;
  final double scale;
  final Alignment alignment;
  final double? width, height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: alignment,
        child: _Caption(lines: lines, color: color, scale: scale),
      ),
    );
  }
}

class _Caption extends StatelessWidget {
  const _Caption({required this.lines, required this.color, this.scale = 1.0});

  final List<String> lines;
  final Color color;
  final double scale;

  static const double _baseFontSize = 24.0;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: color,
      fontWeight: FontWeight.w800,
      height: 1.0,
      fontSize: _baseFontSize * scale,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [for (final line in lines) Text(line, style: style)],
    );
  }
}
