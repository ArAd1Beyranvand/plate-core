from __future__ import annotations

from ..model.plate_box import PlateBox, Rect
from ..model.plate_spec import Axis, Leaf, PlateSection, PlateSpec, StripesFill


def spec_problems(spec: PlateSpec) -> list[str]:
    """Everything wrong with `spec`, empty for a sound one."""
    problems: list[str] = []

    def check(ok: bool, problem: str) -> None:
        if not ok:
            problems.append(problem)

    def check_in_canvas(b: PlateBox, what: str) -> None:
        check(b.left >= 0 and b.top >= 0 and b.right <= spec.canvas_width and b.bottom <= spec.canvas_height,
              f'{what} in spec "{spec.id}" has a rect outside the '
              f"canvas ({_num(spec.canvas_width)}x{_num(spec.canvas_height)}).")

    for i, s in enumerate(spec.slots):
        check_in_canvas(s.box, f"PlateSlot {i}")

    for i, m in enumerate(spec.mirrors):
        check_in_canvas(m.box, f"PlateMirror {i}")
        check(0 <= m.source < len(spec.slots),
              f'PlateMirror {i} in spec "{spec.id}" echoes slot {m.source}, which is '
              f"not a slot index (0..{len(spec.slots) - 1}).")

    for i, b in enumerate(spec.bands):
        check_in_canvas(b.box, f"PlateBand {i}")

    def check_section(s: PlateSection, r: Rect, path: str) -> None:
        if isinstance(s, Leaf):
            if not isinstance(s.fill, StripesFill):
                return
            stripes, stops = s.fill.stripes, s.fill.stops
            check(len(stripes) == len(stops) + 1 and not any(isinstance(f, StripesFill) for f in stripes),
                  f'Background leaf {path} in spec "{spec.id}" has {len(stripes)} stripes '
                  f"and {len(stops)} stops; give one stop between each pair, and do not nest stripes.")
            for i in range(1, len(stops)):
                check(stops[i] > stops[i - 1],
                      f'Background leaf {path} in spec "{spec.id}" has stops out of order: '
                      f"{_num(stops[i])} after {_num(stops[i - 1])}.")
            return
        across = s.axis is Axis.HORIZONTAL
        previous = r.left if across else r.top
        end = r.right if across else r.bottom
        for i, part in enumerate(s.parts):
            last = i == len(s.parts) - 1
            check(part.end is None if last else part.end is not None and previous < part.end < end,
                  f'Background part {path}.{i} in spec "{spec.id}" ends at {_num(part.end)}; '
                  + ("the last part runs to its parent's end, so leave it null" if last
                     else f"expected a value in ({_num(previous)}, {_num(end)})") + ".")
            part_end = end if part.end is None else part.end
            child = (Rect(previous, r.top, part_end - previous, r.height) if across
                     else Rect(r.left, previous, r.width, part_end - previous))
            check_section(part.section, child, f"{path}.{i}")
            previous = part_end

    check_section(spec.background, Rect(0, 0, spec.canvas_width, spec.canvas_height), "background")

    # Only keyed groups of three or more cells on one row have a pitch.
    for g in spec.effective_text_groups:
        if g.key is None or len(g.indices) < 3:
            continue
        boxes = [spec.slots[i].box for i in g.indices if spec.slot_at(i) is not None]
        if len(boxes) != len(g.indices):
            continue
        if not all(b.top == boxes[0].top and b.height == boxes[0].height for b in boxes):
            continue
        pitch = boxes[1].left - boxes[0].left
        for n in range(1, len(boxes)):
            check(abs(boxes[n].left - boxes[0].left - n * pitch) < 0.01,
                  f'Register "{g.key}" in spec "{spec.id}" is unevenly pitched: cell {n} '
                  f"sits at {_num(boxes[n].left)}, but a pitch of {_num(pitch)} puts it at "
                  f"{_num(boxes[0].left + n * pitch)}. Build it with plateRegister/"
                  "plateRegisterAcross rather than cell by cell.")

    for r in spec.restrictions:
        check(any(g.key == r.group for g in spec.text_groups),
              f'Restriction "{r.reason}" in spec "{spec.id}" watches group '
              f'"{r.group}", which no text group carries — it would never fire.')

    # An alphabet id must map one-to-one onto rendered content.
    by_id: dict[str, str] = {}
    by_content: dict[str, str] = {}
    alphabets = [s.alphabet for s in spec.slots] + [m.alphabet for m in spec.mirrors if m.alphabet is not None]
    for a in alphabets:
        key = " ".join(f"{c}={a.render(c)}" for c in a.characters)
        seen = by_id.get(a.id)
        check(seen is None or seen == key,
              f'Alphabet id "{a.id}" in spec "{spec.id}" appears with two different character/glyph sets.')
        by_id[a.id] = key
        seen_id = by_content.get(key)
        check(seen_id is None or seen_id == a.id,
              f'Spec "{spec.id}" has two distinct alphabet ids ("{seen_id}", "{a.id}") '
              "sharing the same characters and glyphs.")
        by_content[key] = a.id
    return problems


def _num(v: float | None) -> str:
    """Dart's number formatting: whole doubles print with a trailing `.0`."""
    return "null" if v is None else str(float(v))
