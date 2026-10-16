import 'dart:async';
import 'package:flutter/scheduler.dart';

import 'package:flutter/material.dart';

import '../animation/plate_animation.dart';
import '../animation/plate_part_animator.dart';
import '../input/plate_controller.dart';
import '../input/plate_input_machine.dart';
import '../model/plate_alphabet.dart';
import '../model/plate_box.dart';
import '../model/plate_country.dart';
import '../model/plate_input_source.dart';
import '../model/plate_number.dart';
import '../model/plate_restriction.dart';
import '../model/plate_spec.dart';
import '../model/slot_behavior.dart';
import '../theme/plate_theme.dart';
import '../validators/plate_validator.dart';
import 'country_panel.dart';
import 'plate_divider.dart';
import 'plate_frame.dart';
import 'plate_selector.dart';
import 'plate_slot_item.dart';
import 'plate_text_row.dart';

/// The editable plate for a [PlateSpec], holding characters in a
/// [PlateController] (its own or passed via [controller]). Provides its own
/// [Material], needs no state management, and preserves characters when [spec]
/// changes per [onSpecChange].
class PlateCanvas extends StatefulWidget {
  const PlateCanvas({
    super.key,
    required this.spec,
    this.mode = PlateMode.input,
    this.theme,
    this.country,
    this.inputSource,
    required this.onChooseCharacter,
    this.onActiveIndexChanged,
    this.controller,
    this.validator,
    this.autoValidate = false,
    this.onSpecChange = PlateValuePreservation.byGroupKey,
    this.animation,
    this.specTransition,
  });

  final PlateSpec spec;
  final PlateMode mode;
  final PlateTheme? theme;

  /// Override [PlateSpec.country] at render time, like [theme]. Null keeps
  /// [PlateSpec.country].
  final PlateCountry? country;

  final PlateInputSource? inputSource;

  /// Shows a character chooser for a chosen slot; required.
  final Future<String?> Function(PlateAlphabet alphabet) onChooseCharacter;
  final ValueChanged<int?>? onActiveIndexChanged;

  /// Owns the plate's characters and focus. Omit to use a private controller.
  final PlateController? controller;

  /// Rule to judge the plate. Never prevents input.
  final PlateValidator? validator;

  /// When true, canvas validates after every commit. When false (default), read
  /// [PlateController.validation] and validate on your timing.
  final bool autoValidate;

  /// What becomes of entered characters when [spec] is swapped. Defaults to
  /// [PlateValuePreservation.byGroupKey] (keeps matching registers).
  final PlateValuePreservation onSpecChange;

  /// Drives each part's come-in / go-out. Null takes the nearest
  /// [PlateAnimationScope]'s; with neither, every part stays settled.
  final PlateAnimationController? animation;

  /// When set (and an [animation] controller is in reach), a [spec] change
  /// takes the old plate out part by part and brings the new one in, keeping
  /// the parts it names. Null swaps instantly.
  final PlateSpecTransition? specTransition;

  @override
  State<PlateCanvas> createState() => _PlateCanvasState();
}

class _PlateCanvasState extends State<PlateCanvas> {
  /// Focus and slot navigation; rebuilt when spec changes.
  late PlateInputMachine _machine;

  /// The canvas's writer of record; takes [BuildContext] out of long-lived
  /// closures the machine holds.
  late PlateController _controller;

  /// Whether [_controller] is ours to dispose.
  bool _ownsController = false;

  /// Cached selection theme, rebuilt only when verdict flips.
  ThemeData? _selectionTheme;
  Color? _selectionThemeColor;

  /// Cached face clip.
  _PlateFaceClipper? _faceClipper;

  /// The characters last shown for [PlateCanvas.spec] — what the outgoing
  /// plate keeps showing while it leaves, since the controller has already
  /// moved on to the next spec by the time the canvas hears of it.
  List<String?> _shownValues = const <String?>[];

  /// The outgoing plate, while it goes out.
  _Ghost? _ghost;
  int _ghostSerial = 0;

  /// How long the canvas takes to grow or shrink to the next spec's size:
  /// the outgoing plate's stagger, so the box settles before the next plate
  /// comes in. Zero when a spec change plays no transition.
  Duration _resizeDuration = Duration.zero;

  /// Whether the face colour tweens over [_resizeDuration] rather than
  /// snapping; see [PlateSpecTransition.morphBackground].
  bool _morphBackground = false;

  void _recordValues() {
    if (_controller.spec.id == widget.spec.id) {
      _shownValues = _controller.values;
    }
  }

  void _startTransition(PlateCanvas old, List<String?> shown) {
    final from = old.spec, to = widget.spec;
    final toValues = _controller.values;
    bool keeps(PlatePartId id) => widget.specTransition!.keeps(
      id,
      from,
      to,
      fromValues: shown,
      toValues: toValues,
    );
    final transition = widget.specTransition;
    final anim = widget.animation ?? PlateAnimationScope.maybeOf(context);
    if (transition == null || anim == null) return;
    final outDelays = PlateStagger.sequence(
      from,
      step: transition.step,
      reverse: true,
    )..removeWhere((id, _) => keeps(id));
    // A morphing face takes its border with it: the incoming plate draws
    // both from the start, so the outline never wipes out and redraws.
    final morph = transition.morphBackground;
    final morphed = {
      if (morph) ...[PlatePartId.background, PlatePartId.border],
    };
    outDelays.removeWhere((id, _) => morphed.contains(id));
    final outLength = plateCueLength(anim.style, outDelays.keys, outDelays);
    _resizeDuration = outLength;
    _morphBackground = morph;
    _ghost = _Ghost(
      serial: ++_ghostSerial,
      spec: from,
      theme: old.theme,
      country: old.country,
      mode: old.mode,
      inputSource: old.inputSource,
      values: shown,
      outDelays: outDelays,
      kept: {
        for (final id in PlatePartId.allOf(from))
          if (keeps(id)) id,
      },
      dropped: morphed,
      length: outLength,
      style: anim.style,
    );
    anim.comeInAll(
      delays: {
        for (final e in PlateStagger.sequence(
          to,
          step: transition.step,
        ).entries)
          e.key: e.value + outLength,
      },
    );
    // Kept parts show in the ghost, above its leaving background, and hand
    // over here when it goes.
    for (final id in PlatePartId.allOf(to)) {
      if (keeps(id)) anim.hide(id);
    }
    // The incoming face shows under the ghost from the start, its colour
    // tweening from the outgoing one's.
    for (final id in morphed) {
      anim.settle(id);
    }
  }

  void _ghostDone(int serial) {
    final ghost = _ghost;
    if (!mounted || ghost?.serial != serial) return;
    final anim = widget.animation ?? PlateAnimationScope.maybeOf(context);
    for (final id in ghost!.kept) {
      anim?.settle(id);
    }
    setState(() => _ghost = null);
  }

  ThemeData _selectionThemeFor(Color active) {
    final cached = _selectionTheme;
    if (cached != null && _selectionThemeColor == active) return cached;
    _selectionThemeColor = active;
    return _selectionTheme = ThemeData.light().copyWith(
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: active.withValues(alpha: 0.3),
        cursorColor: active,
        selectionHandleColor: active,
      ),
    );
  }

  _PlateFaceClipper _faceClipperFor(double border, double radius) {
    final cached = _faceClipper;
    if (cached != null && cached.border == border && cached.radius == radius) {
      return cached;
    }
    return _faceClipper = _PlateFaceClipper(border: border, radius: radius);
  }

  @override
  void initState() {
    super.initState();
    _adoptController();
    _installMachine();
  }

  @override
  void didUpdateWidget(PlateCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A host swapping `spec:` keeps this State, so the machine, bound to the
    // old spec's slots, must be rebuilt here.
    if (widget.spec.id != oldWidget.spec.id) {
      final shown = _shownValues;
      // The controller migrates its values per [PlateCanvas.onSpecChange].
      _controller.adoptSpec(widget.spec, preserve: widget.onSpecChange);
      _resizeDuration = Duration.zero;
      _morphBackground = false;
      _startTransition(oldWidget, shown);
      oldWidget.controller?.detach(_machine);
      widget.controller?.detach(_machine);
      _machine.dispose();
      _installMachine();
    } else if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.installValidation(null);
      oldWidget.controller?.detach(_machine);
      widget.controller?.attach(_machine);
      widget.controller?.installValidation(_probeValidation);
      _adoptController(replacing: true);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_recordValues);
    widget.controller?.installValidation(null);
    widget.controller?.detach(_machine);
    _machine.dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  /// Points [_controller] at the host's controller, else a private one.
  /// [replacing] marks a live canvas handed a different controller: a private
  /// one stood down is disposed, the host's never is.
  void _adoptController({bool replacing = false}) {
    if (replacing) _controller.removeListener(_recordValues);
    _adoptControllerOnly(replacing: replacing);
    _controller.addListener(_recordValues);
    _recordValues();
  }

  void _adoptControllerOnly({required bool replacing}) {
    final host = widget.controller;
    if (host == null) {
      if (replacing && _ownsController) return;
      _controller = PlateController(spec: widget.spec);
      _ownsController = true;
      return;
    }
    if (replacing && identical(_controller, host)) return;
    final stoodDown = replacing && _ownsController ? _controller : null;
    _controller = host;
    _ownsController = false;
    stoodDown?.dispose();
  }

  /// Builds the machine for the current spec and seeded active slot.
  void _installMachine() {
    assert(debugValidateSpec(widget.spec));
    final machine = PlateInputMachine(
      spec: widget.spec,
      inputSource: widget.inputSource ?? defaultInputSource(),
      readValues: () => _controller.values,
      commit: _commit,
      onActiveIndexChanged: _reportActiveIndex,
      onSystemKeyboardChanged: () =>
          widget.controller?.notifyActiveSlotChanged(),
    )..onSheetRequested = _openPicker;
    _machine = machine;
    widget.controller?.attach(machine);
    widget.controller?.installValidation(_probeValidation);
    if (machine.activeIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !identical(_machine, machine)) return;
        _reportActiveIndex(machine.activeIndex);
      });
    }
  }

  void _reportActiveIndex(int? index) {
    widget.onActiveIndexChanged?.call(index);
    widget.controller?.notifyActiveSlotChanged();
  }

  PlateEntry _entryFor(List<String?> values) => PlateEntry(
    spec: widget.spec,
    values: values,
    activeIndex: _machine.activeIndex,
  );

  PlateValidation? _probeValidation() {
    final entry = _entryFor(_controller.values);
    final restricted = restrictionVerdict(entry);
    if (restricted != null) return restricted;
    final validator = widget.validator;
    if (validator == null) return null;
    return validator.validate(entry);
  }

  /// Stores [value] at [index]; when the controller refuses it, puts the slot's
  /// field back to the stored value so the refused character does not linger
  /// on screen.
  bool _commit(int index, String value) {
    final stored = _controller.setAt(index, value);
    if (!stored) _machine.syncController(index, _controller.valueAt(index));
    return stored;
  }

  /// Publishes verdict after the frame (called from build).
  void _publishVerdict(PlateValidation verdict) {
    final controller = widget.controller;
    if (controller == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) controller.reportValidation(verdict);
    });
  }

  /// Presents the character picker for a chosen slot.
  Future<void> _openPicker(int index) async {
    final slot = widget.spec.slots[index];
    final chosen = await widget.onChooseCharacter(slot.alphabet);
    if (chosen == null) return;
    if (!_controller.setAt(index, chosen)) return;
    final next = widget.spec.nextIndex(index);
    if (next != null) _machine.focusSlot(next);
  }

  @override
  Widget build(BuildContext context) {
    final spec = widget.spec;
    final country = widget.country ?? spec.country;
    var theme = widget.theme ?? PlateTheme.of(context);
    if (spec.borderWidthRatioOverride != null) {
      theme = theme.copyWith(borderWidthRatio: spec.borderWidthRatioOverride!);
    }
    if (spec.inkOverride != null) {
      // The whole monochrome set, as [PlateSpec.inkOverride] documents: a plate
      // printed in green has a green rim and green rules, not black ones.
      final ink = spec.inkOverride!;
      theme = theme.copyWith(
        ink: ink,
        plateBorder: ink,
        dividerColor: ink,
        activeColor: ink,
      );
    }
    // Display mode renders inert slots whatever the configured source.
    _machine.inputSource = widget.mode == PlateMode.input
        ? widget.inputSource ?? defaultInputSource()
        : PlateInputSource.system;

    // Resolved once; everything downstream switches on it.
    final behaviors = <SlotBehavior>[
      for (final s in spec.slots)
        resolveSlotBehavior(
          mode: widget.mode,
          input: s.alphabet.input,
          source: _machine.inputSource,
        ),
    ];

    // The face is always white, so cursor and selection colours are pinned to
    // a light theme whatever the host's brightness.
    final selectionTheme = _selectionThemeFor(theme.activeColor);

    // This build deliberately does not watch the plate value. The frame, each
    // slot and each mirror subscribe only to the part they render
    // ([_FrameBinding], [_SlotBinding], [_MirrorBinding]), so a keystroke
    // rebuilds one slot and its mirrors while the static furniture is built
    // once. [_ValidationBinding] is the exception, under autoValidate only, and
    // rebuilds on a verdict flip rather than a keystroke.

    // The clip matches the frame's inner radius so the country panel does not
    // poke square corners into the rounded plate. It derives from the base
    // theme: the alert recolours underlines only, so geometry never shifts on
    // a verdict flip.
    final border = theme.borderWidthRatio * spec.canvasHeight;
    final outerRadius = theme.plateRadiusRatio * spec.canvasHeight;
    final innerRadius = (outerRadius - border).clamp(0.0, outerRadius);

    final clipper = _faceClipperFor(border, innerRadius);

    // The face is two layers. Every typed slot is a TextField, whose
    // EditableText creates composited layers; beneath a FittedBox those force
    // a TransformLayer, so the compositor scales a recorded face and the
    // engine raster-caches it. The plate then softens a beat after appearing
    // (the flag emblem first). The printed furniture therefore gets its own
    // FittedBox with no TextField under it: its scale stays vector at device
    // resolution and keystrokes never dirty it.
    //
    // [StackFit.passthrough] keeps the layers in register: both get this
    // canvas's constraints unchanged and derive the same size and alignment.
    final validator = widget.validator;
    final validate = widget.autoValidate && validator != null
        ? (List<String?> values) {
            final entry = _entryFor(values);
            return restrictionVerdict(entry) ?? validator.validate(entry);
          }
        : null;

    final face = _Livery(
      spec: spec,
      controller: _controller,
      base: theme,
      builder: (theme) => _Face(
        spec: spec,
        theme: theme,
        country: country,
        controller: _controller,
        machine: _machine,
        clipper: clipper,
        behaviors: behaviors,
        mode: widget.mode,
        morphDuration: _morphBackground ? _resizeDuration : Duration.zero,
        ghost: _ghost,
        validate: validate,
        onVerdict: _publishVerdict,
        onPick: _openPicker,
        commit: _commit,
        onGhostDone: _ghostDone,
      ),
    );

    // The Material gives the typed TextFields the ancestor they require, so a
    // host needs no Scaffold. Transparent: the plate paints its own face.
    // Always present, so adding or dropping a controller never remounts slots.
    return PlateAnimationScope(
      controller: widget.animation ?? PlateAnimationScope.maybeOf(context),
      child: Theme(
        data: selectionTheme,
        child: Material(
          type: MaterialType.transparency,
          // Sizes the face as the FittedBoxes inside it would, from a plate
          // size that tweens between specs, so a switch resizes the canvas
          // smoothly instead of snapping to the next plate's proportions.
          child: TweenAnimationBuilder<Size?>(
            tween: SizeTween(end: Size(spec.canvasWidth, spec.canvasHeight)),
            duration: _resizeDuration,
            curve: Curves.easeInOut,
            builder: (context, size, child) => _PlateSizeScope(
              size: size!,
              child: CustomSingleChildLayout(
                delegate: _PlateSizeDelegate(size),
                child: child,
              ),
            ),
            child: face,
          ),
        ),
      ),
    );
  }
}

/// The two-layer face: printed artwork under live inputs, plus the outgoing
/// plate's ghost while a spec change plays.
class _Face extends StatelessWidget {
  const _Face({
    required this.spec,
    required this.theme,
    required this.country,
    required this.controller,
    required this.machine,
    required this.clipper,
    required this.behaviors,
    required this.mode,
    required this.morphDuration,
    required this.ghost,
    required this.validate,
    required this.onVerdict,
    required this.onPick,
    required this.commit,
    required this.onGhostDone,
  });

  final PlateSpec spec;
  final PlateTheme theme;
  final PlateCountry country;
  final PlateController controller;
  final PlateInputMachine machine;
  final _PlateFaceClipper clipper;
  final List<SlotBehavior> behaviors;
  final PlateMode mode;

  /// Zero unless the face colour tweens to the next spec's.
  final Duration morphDuration;
  final _Ghost? ghost;

  /// Non-null under autoValidate: judges the plate and recolours the
  /// completed-field underline to the alert colour. Only the input layer sits
  /// inside the binding, so the artwork does not rebuild on a verdict flip.
  final PlateValidation Function(List<String?> values)? validate;
  final ValueChanged<PlateValidation> onVerdict;
  final ValueChanged<int> onPick;
  final bool Function(int index, String value) commit;
  final ValueChanged<int> onGhostDone;

  @override
  Widget build(BuildContext context) {
    final validate = this.validate;
    final ghost = this.ghost;
    return Stack(
      fit: StackFit.passthrough,
      children: [
        TweenAnimationBuilder<Color?>(
          tween: ColorTween(end: theme.plateBackground),
          duration: morphDuration,
          curve: Curves.easeInOut,
          builder: (context, face, _) => _PlateArtwork(
            spec: spec,
            theme: face == theme.plateBackground
                ? theme
                : theme.copyWith(plateBackground: face),
            country: country,
            controller: controller,
            clipper: clipper,
          ),
        ),
        _ValidationBinding(
          controller: controller,
          validate: validate,
          onVerdict: onVerdict,
          builder: (verdict) => _PlateInputs(
            spec: spec,
            theme: verdict.isValid
                ? theme
                : theme.copyWith(activeColor: theme.alertColor),
            behaviors: behaviors,
            machine: machine,
            controller: controller,
            mode: mode,
            onPick: onPick,
            commit: commit,
            clipper: clipper,
          ),
        ),
        if (ghost != null)
          Positioned.fill(
            child: _SpecGhost(
              key: ValueKey<int>(ghost.serial),
              ghost: ghost,
              onDone: onGhostDone,
            ),
          ),
      ],
    );
  }
}

/// Lays the face out at [plateSize] scaled to fit the incoming constraints,
/// exactly the size a `FittedBox(fit: BoxFit.contain)` around it would take.
class _PlateSizeDelegate extends SingleChildLayoutDelegate {
  const _PlateSizeDelegate(this.plateSize);

  final Size plateSize;

  @override
  Size getSize(BoxConstraints constraints) =>
      constraints.constrainSizeAndAttemptToPreserveAspectRatio(plateSize);

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints.tight(getSize(constraints));

  @override
  bool shouldRelayout(_PlateSizeDelegate old) => old.plateSize != plateSize;
}

/// Painted furniture (frame, country panel, rules, labels, decals).
///
/// **No TextField may ever appear in this subtree** — nothing here composites,
/// so the flag is drawn at device resolution, not rasterised and resampled.
/// Static between spec changes except the frame, which follows [_FrameBinding].
class _PlateArtwork extends StatelessWidget {
  const _PlateArtwork({
    required this.spec,
    required this.theme,
    required this.country,
    required this.controller,
    required this.clipper,
  });

  final PlateSpec spec;
  final PlateTheme theme;
  final PlateCountry country;
  final PlateController controller;

  /// Shared clip geometry with [_PlateInputs].
  final _PlateFaceClipper clipper;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        Positioned.fill(
          child: _MorphingFrame(
            textDirection: spec.textDirection,
            child: _FrameBinding(
              theme: theme,
              controller: controller,
              background: spec.background,
              panelColor: country.panelColor,
            ),
          ),
        ),
        _PlateContent(
          spec: spec,
          theme: theme,
          country: country,
          controller: controller,
          clipper: clipper,
        ),
      ],
    );
  }
}

/// The face and border, laid out at the canvas's current plate size rather
/// than the spec's, so they fill the box while it tweens between specs
/// instead of letterboxing inside it. At rest the two sizes are the same.
class _MorphingFrame extends StatelessWidget {
  const _MorphingFrame({required this.textDirection, required this.child});

  final TextDirection textDirection;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final size = _PlateSizeScope.of(context);
    return FittedBox(
      fit: BoxFit.fill,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: Directionality(textDirection: textDirection, child: child),
      ),
    );
  }
}

/// The plate size the canvas is laid out at this frame (see
/// [_PlateSizeDelegate]).
class _PlateSizeScope extends InheritedWidget {
  const _PlateSizeScope({required this.size, required super.child});

  final Size size;

  static Size of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_PlateSizeScope>()!.size;

  @override
  bool updateShouldNotify(_PlateSizeScope old) => old.size != size;
}

/// Everything printed on the face, in the spec's own coordinates.
class _PlateContent extends StatelessWidget {
  const _PlateContent({
    required this.spec,
    required this.theme,
    required this.country,
    required this.controller,
    required this.clipper,
  });

  final PlateSpec spec;
  final PlateTheme theme;
  final PlateCountry country;
  final PlateController controller;
  final _PlateFaceClipper clipper;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: spec.canvasWidth,
        height: spec.canvasHeight,
        child: Directionality(
          textDirection: spec.textDirection,
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  clipper: clipper,
                  child: Stack(
                    children: [
                      if (!spec.noPanel)
                        _Placed(
                          box: spec.panel.box,
                          child: CountryPanel(
                            country: country,
                            theme: theme,
                            panel: spec.panel,
                            paintBlock: !spec.background.paintsPanel,
                          ),
                        ),
                      // Under the rules, labels and decals: a band is the field
                      // the ink is printed on, not something printed over them.
                      for (var i = 0; i < spec.bands.length; i++)
                        _Placed(
                          box: spec.bands[i].box,
                          child: PlatePartAnimator(
                            id: PlatePartId.band(i),
                            child: _Band(band: spec.bands[i]),
                          ),
                        ),
                      for (var i = 0; i < spec.rules.length; i++)
                        _Placed(
                          box: spec.rules[i].box,
                          child: PlatePartAnimator(
                            id: PlatePartId.rule(i),
                            selfPainted: true,
                            child: PlateDivider(color: theme.dividerColor),
                          ),
                        ),
                      for (var i = 0; i < spec.labels.length; i++)
                        _Label(
                          index: i,
                          label: spec.labels[i],
                          theme: theme,
                          spec: spec,
                          controller: controller,
                        ),
                      for (var i = 0; i < spec.decals.length; i++)
                        _Placed(
                          box: spec.decals[i].box,
                          child: PlatePartAnimator(
                            id: PlatePartId.decal(i),
                            child: Image(
                              image: spec.decals[i].image,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Resolves [PlateSpec.resolveTheme] against the typed characters and
/// cross-fades between the results, rebuilding [builder] only when the
/// resolved theme changes. Passes [base] through when the spec has no resolver.
class _Livery extends StatefulWidget {
  const _Livery({
    required this.spec,
    required this.controller,
    required this.base,
    required this.builder,
  });

  final PlateSpec spec;
  final PlateController controller;
  final PlateTheme base;
  final Widget Function(PlateTheme theme) builder;

  @override
  State<_Livery> createState() => _LiveryState();
}

class _LiveryState extends State<_Livery> {
  late PlateTheme _theme;

  PlateTheme _resolve() {
    final resolve = widget.spec.resolveTheme;
    if (resolve == null) return widget.base;
    final values = widget.controller.values;
    return resolve(widget.base, (key) => widget.spec.valueOfGroup(key, values));
  }

  void _onChanged() {
    final next = _resolve();
    if (next == _theme) return;
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.persistentCallbacks) {
      // Notified mid-build (the canvas attaching its controller): settle next frame.
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) _onChanged();
      });
    } else {
      setState(() => _theme = next);
    }
  }

  @override
  void initState() {
    super.initState();
    _theme = _resolve();
    widget.controller.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(_Livery old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_onChanged);
      widget.controller.addListener(_onChanged);
    }
    _theme = _resolve();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.spec.resolveTheme == null
      ? widget.builder(widget.base)
      : TweenAnimationBuilder<PlateTheme>(
          tween: _ThemeTween(end: _theme),
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          builder: (context, theme, _) => widget.builder(theme),
        );
}

class _ThemeTween extends Tween<PlateTheme> {
  _ThemeTween({required PlateTheme super.end});

  @override
  PlateTheme lerp(double t) {
    final a = begin ?? end!, b = end!;
    return b.copyWith(
      plateBackground: Color.lerp(a.plateBackground, b.plateBackground, t),
      plateBorder: Color.lerp(a.plateBorder, b.plateBorder, t),
      ink: Color.lerp(a.ink, b.ink, t),
      dividerColor: Color.lerp(a.dividerColor, b.dividerColor, t),
      activeColor: Color.lerp(a.activeColor, b.activeColor, t),
      inactiveColor: Color.lerp(a.inactiveColor, b.inactiveColor, t),
    );
  }
}

/// One [PlateLabel], its own animated part.
class _Label extends StatelessWidget {
  const _Label({
    required this.index,
    required this.label,
    required this.theme,
    required this.spec,
    required this.controller,
  });

  final int index;
  final PlateLabel label;
  final PlateTheme theme;
  final PlateSpec spec;
  final PlateController controller;

  @override
  Widget build(BuildContext context) {
    final l = label;
    final resolve = l.resolve;
    final style = theme
        .glyphStyle(l.glyphHeight, l.color ?? theme.ink)
        .copyWith(
          height: l.lineHeight,
          fontFamily: l.fontFamily,
          package: l.fontPackage,
        );
    return _Placed(
      box: l.box,
      child: PlatePartAnimator(
        id: PlatePartId.label(index),
        child: Center(
          child: resolve == null
              ? _LabelText(value: l.text, style: style, rotated: l.rotated)
              : ListenableBuilder(
                  listenable: controller,
                  builder: (context, _) {
                    final values = controller.values;
                    final value =
                        resolve((key) => spec.valueOfGroup(key, values)) ??
                        l.text;
                    return FittedBox(
                      fit: BoxFit.scaleDown,
                      child: _StaggeredText(value: value, style: style),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

/// A caption whose characters leave one after another, and the next wording's
/// arrive the same way, when [value] changes. One [Text.rich], so the letters
/// keep joining across the per-character alpha spans.
class _StaggeredText extends StatefulWidget {
  const _StaggeredText({required this.value, required this.style});

  final String value;
  final TextStyle style;

  @override
  State<_StaggeredText> createState() => _StaggeredTextState();
}

class _StaggeredTextState extends State<_StaggeredText>
    with SingleTickerProviderStateMixin {
  static const _charMs = 220;
  static const _stepMs = 55;

  late final AnimationController _ticker = AnimationController(vsync: this);
  late String _shown = widget.value;
  bool _leaving = false;
  bool _settled = true;

  Duration _run(String text) => Duration(
    milliseconds: _charMs + _stepMs * (text.length - 1).clamp(0, 99),
  );

  @override
  void didUpdateWidget(_StaggeredText old) {
    super.didUpdateWidget(old);
    if (_leaving || widget.value == _shown) return;
    _leaving = true;
    _settled = false;
    _ticker.duration = _run(_shown);
    _ticker.forward(from: 0).whenComplete(_arrive);
  }

  void _arrive() {
    if (!mounted) return;
    setState(() {
      _shown = widget.value;
      _leaving = false;
    });
    _ticker.duration = _run(_shown);
    _ticker.forward(from: 0).whenComplete(() => _settled = true);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.style.color ?? const Color(0xFF000000);
    return AnimatedBuilder(
      animation: _ticker,
      builder: (context, _) {
        final elapsed = _ticker.value * _run(_shown).inMilliseconds;
        double alpha(int i) {
          if (_settled) return 1;
          final t = ((elapsed - i * _stepMs) / _charMs).clamp(0.0, 1.0);
          return _leaving ? 1 - t : t;
        }

        return Text.rich(
          TextSpan(
            children: [
              for (var i = 0; i < _shown.length; i++)
                TextSpan(
                  text: _shown[i],
                  style: TextStyle(color: color.withValues(alpha: alpha(i))),
                ),
            ],
          ),
          style: widget.style,
          textAlign: TextAlign.center,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.visible,
        );
      },
    );
  }
}

/// Live characters: typed slots and mirrors. TextFields composite here; a
/// keystroke repaints only this layer, not the flag above.
class _PlateInputs extends StatelessWidget {
  const _PlateInputs({
    required this.spec,
    required this.theme,
    required this.behaviors,
    required this.machine,
    required this.controller,
    required this.mode,
    required this.onPick,
    required this.commit,
    required this.clipper,
  });

  final PlateSpec spec;
  final PlateTheme theme;
  final List<SlotBehavior> behaviors;
  final PlateInputMachine machine;
  final PlateController controller;
  final PlateMode mode;
  final void Function(int index) onPick;

  /// A chosen slot opens the picker on tap even when a keypad drives input.
  static bool _opensPicker(SlotBehavior behavior, PlateSlot slot) =>
      behavior == SlotBehavior.sheet ||
      (slot.alphabet.input == AlphabetInput.chosen &&
          (behavior == SlotBehavior.externalField ||
              behavior == SlotBehavior.keypadFirstField));
  final bool Function(int index, String value) commit;
  final _PlateFaceClipper clipper;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: spec.canvasWidth,
        height: spec.canvasHeight,
        child: Directionality(
          textDirection: spec.textDirection,
          child: ClipRRect(
            clipper: clipper,
            child: Stack(
              children: [
                for (var mi = 0; mi < spec.mirrors.length; mi++)
                  _Placed(
                    box: spec.mirrors[mi].box,
                    child: PlatePartAnimator(
                      id: PlatePartId.mirror(mi),
                      child:
                          mode == PlateMode.input &&
                              spec.mirrors[mi].editable &&
                              machine.mirrorControllerAt(mi) != null
                          ? Center(
                              child: _EditableMirrorBinding(
                                mirrorIndex: mi,
                                mirror: spec.mirrors[mi],
                                alphabet:
                                    spec.mirrors[mi].alphabet ??
                                    spec
                                        .slots[spec.mirrors[mi].source]
                                        .alphabet,
                                behavior: behaviors[spec.mirrors[mi].source],
                                theme: theme,
                                machine: machine,
                                controller: controller,
                                onCompleted: mode == PlateMode.input
                                    ? () => machine.advanceFrom(
                                        spec.mirrors[mi].source,
                                      )
                                    : null,
                              ),
                            )
                          : _MirrorBinding(
                              mirror: spec.mirrors[mi],
                              alphabet:
                                  spec.mirrors[mi].alphabet ??
                                  spec.slots[spec.mirrors[mi].source].alphabet,
                              theme: theme,
                              controller: controller,
                            ),
                    ),
                  ),
                for (var i = 0; i < spec.slots.length; i++)
                  _Placed(
                    box: spec.slots[i].box,
                    child: PlatePartAnimator(
                      id: PlatePartId.slot(i),
                      child: Center(
                        child: _SlotBinding(
                          index: i,
                          slot: spec.slots[i],
                          behavior: behaviors[i],
                          theme: theme,
                          machine: machine,
                          controller: controller,
                          commit: commit,
                          onCompleted: mode == PlateMode.input
                              ? () => machine.advanceFrom(i)
                              : null,
                          onPressed: _opensPicker(behaviors[i], spec.slots[i])
                              ? () => onPick(i)
                              : null,
                        ),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: _RestrictionBanner(
                    controller: controller,
                    theme: theme,
                    canvasHeight: spec.canvasHeight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Subscribed to verdict, not value, so rebuilds only on valid/invalid flip.
class _ValidationBinding extends StatelessWidget {
  const _ValidationBinding({
    required this.controller,
    required this.validate,
    required this.onVerdict,
    required this.builder,
  });

  final PlateController controller;

  /// Null for no validation: the inputs build once, as valid.
  final PlateValidation Function(List<String?> values)? validate;
  final ValueChanged<PlateValidation> onVerdict;
  final Widget Function(PlateValidation verdict) builder;

  @override
  Widget build(BuildContext context) {
    final validate = this.validate;
    if (validate == null) return builder(const PlateValidation.valid());
    return PlateSelector<PlateValidation>(
      controller: controller,
      selector: (c) => validate(c.values),
      builder: (context, verdict) => _VerdictListener(
        verdict: verdict,
        onVerdict: onVerdict,
        child: builder(verdict),
      ),
    );
  }
}

/// Publishes verdict from lifecycle callbacks (not build).
class _VerdictListener extends StatefulWidget {
  const _VerdictListener({
    required this.verdict,
    required this.onVerdict,
    required this.child,
  });

  final PlateValidation verdict;
  final ValueChanged<PlateValidation> onVerdict;
  final Widget child;

  @override
  State<_VerdictListener> createState() => _VerdictListenerState();
}

class _VerdictListenerState extends State<_VerdictListener> {
  @override
  void initState() {
    super.initState();
    widget.onVerdict(widget.verdict);
  }

  @override
  void didUpdateWidget(_VerdictListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.verdict != oldWidget.verdict) {
      widget.onVerdict(widget.verdict);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// The error a refused write leaves, painted over the plate face: a band in
/// the theme's alert colour carrying the restriction's reason. Watches
/// [PlateController.rejection] alone, so it appears on the refusal and goes
/// with the next stored write without rebuilding anything else.
///
/// Also shown when the values themselves break a restriction — a value can
/// reach a controller only refused, but a spec swap clears rather than
/// refuses, and the band says why the register emptied.
class _RestrictionBanner extends StatelessWidget {
  const _RestrictionBanner({
    required this.controller,
    required this.theme,
    required this.canvasHeight,
  });

  final PlateController controller;
  final PlateTheme theme;
  final double canvasHeight;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PlateRestriction?>(
      valueListenable: controller.rejection,
      builder: (context, rejection, _) {
        if (rejection == null) return const SizedBox.shrink();
        return IgnorePointer(
          child: Center(
            child: Container(
              key: const ValueKey<String>('plate-restriction-banner'),
              width: double.infinity,
              height: canvasHeight * 0.42,
              color: theme.alertColor,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: canvasHeight * 0.1),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  rejection.reason,
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(
                    color: const Color(0xFFFFFFFF),
                    fontWeight: FontWeight.w800,
                    fontSize: canvasHeight * 0.26,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Positions a child from a [PlateBox].
class _Placed extends StatelessWidget {
  const _Placed({required this.box, required this.child});

  final PlateBox box;
  final Widget child;

  @override
  Widget build(BuildContext context) => Positioned(
    left: box.left,
    top: box.top,
    width: box.width,
    height: box.height,
    child: child,
  );
}

/// Border and face, subscribed to completion (repaints only when last slot fills).
class _FrameBinding extends StatelessWidget {
  const _FrameBinding({
    required this.theme,
    required this.controller,
    required this.background,
    required this.panelColor,
  });

  final PlateTheme theme;
  final PlateController controller;
  final PlateSection background;
  final Color panelColor;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: controller.completed,
      builder: (context, isCompleted, _) => PlateFrame(
        isCompleted: isCompleted,
        theme: theme,
        background: background,
        panelColor: panelColor,
      ),
    );
  }
}

/// One slot, subscribed only to its own character (keeps keystrokes local).
class _SlotBinding extends StatelessWidget {
  const _SlotBinding({
    required this.index,
    required this.slot,
    required this.behavior,
    required this.theme,
    required this.machine,
    required this.controller,
    required this.commit,
    required this.onCompleted,
    required this.onPressed,
  });

  final int index;
  final PlateSlot slot;
  final SlotBehavior behavior;
  final PlateTheme theme;
  final PlateInputMachine machine;
  final PlateController controller;

  /// The canvas's guarded write: refuses what the controller refuses and puts
  /// the field back.
  final bool Function(int index, String value) commit;
  final VoidCallback? onCompleted;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: controller.slot(index),
      builder: (context, value, _) {
        machine.syncController(index, value);
        return ValueListenableBuilder<bool>(
          valueListenable: machine.systemKeyboard,
          builder: (context, systemKeyboard, _) => PlateSlotItem(
            slot: slot,
            behavior: behavior,
            theme: theme,
            value: value,
            controller: machine.controllerAt(index),
            focusNode: machine.focusNodeAt(index),
            onChanged: (v) => commit(index, v),
            onCompleted: onCompleted,
            onBackspace: machine.backspaceCharacter,
            onPressed: onPressed,
            systemKeyboard: systemKeyboard,
            onRequestSystemKeyboard: machine.requestSystemKeyboard,
          ),
        );
      },
    );
  }
}

/// Read-only echo of a slot's character (no focus, no controller).
class _MirrorBinding extends StatelessWidget {
  const _MirrorBinding({
    required this.mirror,
    required this.alphabet,
    required this.theme,
    required this.controller,
  });

  final PlateMirror mirror;
  final PlateAlphabet alphabet;
  final PlateTheme theme;
  final PlateController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: controller.slot(mirror.source),
      builder: (context, value, _) => Center(
        child: Text(
          alphabet.renderAll(value ?? ''),
          textAlign: TextAlign.center,
          style: theme.glyphStyle(mirror.glyphHeight, theme.ink),
        ),
      ),
    );
  }
}

/// Editable mirror: a second input field bound to the source slot's value.
class _EditableMirrorBinding extends StatelessWidget {
  const _EditableMirrorBinding({
    required this.mirrorIndex,
    required this.mirror,
    required this.alphabet,
    required this.behavior,
    required this.theme,
    required this.machine,
    required this.controller,
    required this.onCompleted,
  });

  final int mirrorIndex;
  final PlateMirror mirror;
  final PlateAlphabet alphabet;
  final SlotBehavior behavior;
  final PlateTheme theme;
  final PlateInputMachine machine;
  final PlateController controller;
  final VoidCallback? onCompleted;

  @override
  Widget build(BuildContext context) {
    // The mirror takes the source field's run lengths, so a mirror over a
    // four-to-six digit serial accepts the whole run.
    final source = controller.spec.slots[mirror.source];
    return ValueListenableBuilder<String?>(
      valueListenable: controller.slot(mirror.source),
      builder: (context, value, _) {
        machine.syncMirrorController(mirrorIndex, alphabet, value);
        return PlateSlotItem(
          slot: PlateSlot(
            alphabet: alphabet,
            box: PlateBox(0, 0, mirror.box.width, mirror.glyphHeight),
            length: source.length,
            minLength: source.minLength,
            spacing: source.spacing,
          ),
          behavior: behavior,
          theme: theme,
          value: value,
          controller: machine.mirrorControllerAt(mirrorIndex),
          focusNode: machine.mirrorFocusNodeAt(mirrorIndex)!,
          onChanged: (v) => controller.setAt(mirror.source, v),
          onCompleted: onCompleted,
          onBackspace: machine.backspaceCharacter,
        );
      },
    );
  }
}

/// Clips to white face's rounded rect; geometry mirrors [PlateFrame].
class _PlateFaceClipper extends CustomClipper<RRect> {
  const _PlateFaceClipper({required this.border, required this.radius});

  final double border;
  final double radius;

  @override
  RRect getClip(Size size) {
    // Deflate slightly less than the border thickness: the content layer
    // (country panel, dividers, slots) is painted on top of PlateFrame's own
    // white face, which is deflated by the *full* border. Clipping content to
    // that exact same rect leaves a hairline white seam at the border/panel
    // boundary once the whole plate is scaled by the outer FittedBox — the
    // two independently-rasterised anti-aliased edges don't composite
    // pixel-for-pixel. Letting content bleed `_overlap` further out (under
    // the border paint, which stays on top of nothing — it's the same
    // layer's edge) removes the seam with no visible change to border width.
    final inner = (Offset.zero & size).deflate(border - _overlap);
    return RRect.fromRectAndRadius(inner, Radius.circular(radius));
  }

  static const _overlap = 0.75;

  @override
  bool shouldReclip(_PlateFaceClipper old) =>
      old.border != border || old.radius != radius;
}

/// A [PlateBand]'s fill, rounded per [PlateBand.topCornerRadius] and
/// [PlateBand.bottomCornerRadius]. A `BoxDecoration` border radius rather than
/// a `ClipPath` — the clip-based version left a seam where it met the plate's
/// own rounded corner.
class _Band extends StatelessWidget {
  const _Band({required this.band});

  final PlateBand band;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: band.color,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(band.topCornerRadius),
          bottom: Radius.circular(band.bottomCornerRadius),
        ),
      ),
    );
  }
}

/// An outgoing plate: what it showed, and how it leaves.
class _Ghost {
  const _Ghost({
    required this.serial,
    required this.spec,
    required this.theme,
    required this.country,
    required this.mode,
    required this.inputSource,
    required this.values,
    required this.outDelays,
    required this.kept,
    required this.dropped,
    required this.length,
    required this.style,
  });

  final int serial;
  final PlateSpec spec;

  /// The outgoing widget's look — the host has usually moved on already.
  final PlateTheme? theme;
  final PlateCountry? country;

  /// Rendered as the live plate was, so empty slots keep their underlines.
  final PlateMode mode;
  final PlateInputSource? inputSource;
  final List<String?> values;
  final Map<PlatePartId, Duration> outDelays;

  /// Parts both plates share: held in the ghost, then handed to the
  /// incoming plate when it goes.
  final Set<PlatePartId> kept;

  /// Parts the ghost never shows: the incoming plate already draws them.
  final Set<PlatePartId> dropped;
  final Duration length;
  final PlateAnimationStyle style;
}

/// The outgoing plate as an inert display canvas over the incoming one,
/// taking itself apart; reports [onDone] when the last part has gone.
class _SpecGhost extends StatefulWidget {
  const _SpecGhost({super.key, required this.ghost, required this.onDone});

  final _Ghost ghost;
  final void Function(int serial) onDone;

  @override
  State<_SpecGhost> createState() => _SpecGhostState();
}

class _SpecGhostState extends State<_SpecGhost> {
  late final PlateController _controller;
  late final PlateAnimationController _anim;
  Timer? _done;

  @override
  void initState() {
    super.initState();
    final g = widget.ghost;
    _controller = PlateController(spec: g.spec);
    if (g.values.length == g.spec.slotCount) _controller.setValues(g.values);
    _anim = PlateAnimationController(style: g.style)
      ..goOutAll(delays: g.outDelays);
    for (final id in g.kept) {
      _anim.settle(id);
    }
    for (final id in g.dropped) {
      _anim.hide(id);
    }
    _done = Timer(g.length, () => widget.onDone(g.serial));
  }

  @override
  void dispose() {
    _done?.cancel();
    _anim.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ExcludeFocus(
      child: PlateCanvas(
        spec: widget.ghost.spec,
        mode: widget.ghost.mode,
        inputSource: widget.ghost.inputSource,
        theme: widget.ghost.theme,
        country: widget.ghost.country,
        controller: _controller,
        animation: _anim,
        onChooseCharacter: noCharacterChooser,
      ),
    ),
  );
}

class _LabelText extends StatelessWidget {
  const _LabelText({
    required this.value,
    required this.style,
    required this.rotated,
  });

  final String value;
  final TextStyle style;
  final bool rotated;

  @override
  Widget build(BuildContext context) => RotatedBox(
    key: ValueKey<String>(value),
    quarterTurns: rotated ? 3 : 0,
    child: Text(
      value,
      textAlign: TextAlign.center,
      // A label is placed by its box, not laid out by it: a caption too long
      // for its box must overflow, never reflow onto a second line.
      maxLines: '\n'.allMatches(value).length + 1,
      softWrap: false,
      overflow: TextOverflow.visible,
      style: style,
    ),
  );
}
