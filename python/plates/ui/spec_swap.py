"""[D1][D9] A spec change as the canvas plays it (ts/src/ui/spec_swap.ts): the old plate takes itself apart in
a ghost over the stage while the new one waits to come in after it, the face fading between their colours
and tweening between their sizes, the ghost drawn at that same size."""
from __future__ import annotations

from typing import Callable, NamedTuple

from ..core.input.plate_controller import PlateController
from ..core.timing.plate_animation import (
    PlateAnimationController, PlatePartId, PlatePartKind as K, PlateSpecTransition, all_of, plate_cue_length,
    stagger_sequence,
)
from ..render.plate_canvas import plate_theme
from .plate_canvas import PlateCanvas

SPEC_TRANSITION = PlateSpecTransition(keep_identical=True, morph_background=True)
_FACE = (K.BACKGROUND, K.CORNER, K.BORDER_WIDTH, K.BORDER_COLOR, K.BORDER)


class Outgoing(NamedTuple):
    """The plate that is leaving: what it showed, kept after its canvas is gone."""

    canvas: PlateCanvas
    values: list
    hints: list | None


class SwapPlan(NamedTuple):
    out_delays: dict
    in_delays: dict
    kept: set
    hidden: set
    morphed: set
    out_ms: int


def plan_spec_transition(t, style, frm, to, from_values, to_values) -> SwapPlan:
    """Which parts go out and in, and when; kept parts swap in place, a morphed face never leaves."""
    keeps = lambda id: t.keeps(id, frm, to, from_values, to_values)  # noqa: E731
    morphed = {PlatePartId(k) for k in _FACE} if t.morph_background else set()
    out = {id: d for id, d in stagger_sequence(frm, t.step, True).items() if not keeps(id) and id not in morphed}
    ms = plate_cue_length(style, out, out)
    return SwapPlan(out, {id: d + ms for id, d in stagger_sequence(to, t.step).items()},
                    {id for id in all_of(frm) if keeps(id)}, {id for id in all_of(to) if keeps(id)}, morphed, ms)


def outgoing(canvas: PlateCanvas) -> Outgoing:
    c = canvas.controller
    return Outgoing(canvas, list(c.values), c.hints.value)


def introduce(canvas: PlateCanvas, anim: PlateAnimationController) -> None:
    """A plate coming in with nothing before it: every part staggers in."""
    anim.come_in_all(stagger_sequence(canvas.spec, SPEC_TRANSITION.step))


def swap_spec(env, host, prev: Outgoing, nxt: PlateCanvas, anim: PlateAnimationController) -> Callable[[], None]:
    """Plays [prev] out over [host] and [nxt] in after it; returns what ends it early."""
    old, spec = prev.canvas, prev.canvas.spec
    plan = plan_spec_transition(SPEC_TRANSITION, anim.style, spec, nxt.spec, prev.values, nxt.controller.values)
    ms = plan.out_ms
    anim.come_in_all(plan.in_delays)
    for id in plan.hidden:
        anim.hide(id)
    for id in plan.morphed:
        anim.settle(id)
    # Same spec in a new livery (two entries sharing one spec): nothing goes out, but the face still tweens,
    # over what taking the whole plate apart would take (Flutter's _morphTheme).
    whole = stagger_sequence(nxt.spec, SPEC_TRANSITION.step, True)
    morph_ms = ms if spec.id != nxt.spec.id else plate_cue_length(anim.style, whole, whole)
    nxt.morph_from(plate_theme(spec, old.theme, prev.values), old.size(), morph_ms)

    ghost_anim = PlateAnimationController(anim.style)
    ghost_anim.go_out_all(plan.out_delays)
    for id in plan.kept:
        ghost_anim.settle(id)
    for id in plan.morphed:
        # The corner and width draw nothing; they only shape the clip the leaving parts are held in.
        (ghost_anim.settle if id.kind in (K.CORNER, K.BORDER_WIDTH) else ghost_anim.hide)(id)
    el = env.document.createElement("div")
    el.setAttribute("aria-hidden", "true")
    el.style.cssText = "position:absolute;left:0;top:0;width:100%;pointer-events:none"
    controller = PlateController(spec, prev.values)
    controller.hints.value = prev.hints
    ghost = PlateCanvas(controller, old.theme, old.country, old.mode, old.input_source,
                        on_render=lambda ops: paint(), animation=ghost_anim, clock=env.now, schedule=env.schedule, size_of=nxt.size)
    paint = lambda: setattr(el, "innerHTML", ghost.svg())  # noqa: E731
    host.appendChild(el)
    paint()

    timer = None

    def end() -> None:
        env.clear_timeout(timer)
        ghost.dispose()
        controller.dispose()
        el.remove()

    def done() -> None:
        end()
        for id in plan.kept:
            anim.settle(id)

    timer = env.set_timeout(done, ms)

    def cancel() -> None:
        end()
        anim.settle_all()
    return cancel
