import 'package:flutter/widgets.dart';

/// A slot's characters, each animated in as it is added and out as it is
/// removed. The characters present when the run mounts show at once.
///
/// A left-to-right run animates character by character. A right-to-left run
/// moves as one unit: splitting it would break the joining of its letters.
class PlateGlyphRun extends StatefulWidget {
  const PlateGlyphRun({
    super.key,
    required this.text,
    required this.style,
    required this.textDirection,
    this.placeholder = '',
    this.placeholderStyle,
  });

  final String text;
  final TextStyle style;
  final TextDirection textDirection;

  /// Faded in while [text] is empty.
  final String placeholder;
  final TextStyle? placeholderStyle;

  static const Duration enter = Duration(milliseconds: 260);
  static const Duration leave = Duration(milliseconds: 180);

  @override
  State<PlateGlyphRun> createState() => _PlateGlyphRunState();
}

class _Glyph {
  _Glyph(this.text, this.motion);

  final String text;
  final AnimationController motion;
  bool leaving = false;
}

class _PlateGlyphRunState extends State<PlateGlyphRun>
    with TickerProviderStateMixin {
  final List<_Glyph> _glyphs = [];

  List<String> _unitsOf(String text) {
    if (text.isEmpty) return const [];
    return widget.textDirection == TextDirection.ltr
        ? text.characters.toList()
        : [text];
  }

  AnimationController _motion(double value) => AnimationController(
    vsync: this,
    duration: PlateGlyphRun.enter,
    reverseDuration: PlateGlyphRun.leave,
    value: value,
  );

  @override
  void initState() {
    super.initState();
    for (final unit in _unitsOf(widget.text)) {
      _glyphs.add(_Glyph(unit, _motion(1)));
    }
  }

  @override
  void didUpdateWidget(PlateGlyphRun old) {
    super.didUpdateWidget(old);
    if (old.text == widget.text && old.textDirection == widget.textDirection) {
      return;
    }
    final live = _glyphs.where((g) => !g.leaving).toList();
    final next = _unitsOf(widget.text);
    var kept = 0;
    while (kept < live.length &&
        kept < next.length &&
        live[kept].text == next[kept]) {
      kept++;
    }
    for (final glyph in live.skip(kept)) {
      glyph.leaving = true;
      glyph.motion.reverse().whenCompleteOrCancel(() {
        if (!mounted) return;
        setState(() => _glyphs.remove(glyph));
        glyph.motion.dispose();
      });
    }
    // New characters go after the kept ones and after anything still leaving
    // from that spot, so a replaced character leaves before its successor.
    var at = kept == 0 ? 0 : _glyphs.indexOf(live[kept - 1]) + 1;
    while (at < _glyphs.length && _glyphs[at].leaving) {
      at++;
    }
    _glyphs.insertAll(at, [
      for (final unit in next.skip(kept)) _Glyph(unit, _motion(0)..forward()),
    ]);
  }

  @override
  void dispose() {
    for (final glyph in _glyphs) {
      glyph.motion.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final run = Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: widget.textDirection,
      children: [
        for (final glyph in _glyphs)
          _GlyphCell(
            key: ObjectKey(glyph),
            text: glyph.text,
            style: widget.style,
            textDirection: widget.textDirection,
            motion: glyph.motion,
          ),
      ],
    );
    if (widget.placeholder.isEmpty) return run;
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedOpacity(
          opacity: widget.text.isEmpty ? 1 : 0,
          duration: PlateGlyphRun.leave,
          child: Text(
            widget.placeholder,
            maxLines: 1,
            softWrap: false,
            textDirection: widget.textDirection,
            style: widget.placeholderStyle ?? widget.style,
            strutStyle: _strutOf(widget.style),
          ),
        ),
        run,
      ],
    );
  }
}

/// One character: grows its width, rises from below and pops to size on the
/// way in; the same in reverse on the way out.
class _GlyphCell extends StatelessWidget {
  const _GlyphCell({
    super.key,
    required this.text,
    required this.style,
    required this.textDirection,
    required this.motion,
  });

  final String text;
  final TextStyle style;
  final TextDirection textDirection;
  final Animation<double> motion;

  @override
  Widget build(BuildContext context) {
    final glyph = Text(
      text,
      maxLines: 1,
      softWrap: false,
      textDirection: textDirection,
      style: style,
      strutStyle: _strutOf(style),
    );
    final rise = (style.fontSize ?? 14) * 0.3;
    return AnimatedBuilder(
      animation: motion,
      child: glyph,
      builder: (context, child) {
        final t = motion.value;
        final width = Curves.easeOutCubic.transform(t);
        final pop = Curves.easeOutBack.transform(t);
        return Align(
          widthFactor: width,
          heightFactor: 1,
          child: Opacity(
            opacity: Curves.easeOut.transform(t),
            child: Transform.translate(
              offset: Offset(0, (1 - width) * rise),
              child: Transform.scale(scale: 0.6 + 0.4 * pop, child: child),
            ),
          ),
        );
      },
    );
  }
}

/// The line box an editable field forces on its text, so every glyph and the
/// placeholder stand on the same baseline as the field they cover.
StrutStyle _strutOf(TextStyle style) =>
    StrutStyle.fromTextStyle(style, forceStrutHeight: true);
