from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
from typing import Any, Callable, NamedTuple, Union

from .plate_alphabet import AlphabetInput, PlateAlphabet, TextDirection, split_runes
from .plate_asset import PlateAsset, PlateDrawing
from .plate_box import PlateBox, Rect
from .plate_country import PlateCountry


class Axis(Enum):
    HORIZONTAL = "horizontal"
    VERTICAL = "vertical"


class Insets(NamedTuple):
    left: float
    top: float
    right: float
    bottom: float


@dataclass(frozen=True)
class PlateSlot:
    """One editable position on a plate. `box.height` doubles as the glyph height."""

    alphabet: PlateAlphabet
    box: PlateBox
    color: int | None = None
    length: int = 1
    min_length: int | None = None
    spacing: float = 0

    def __post_init__(self):
        assert self.length >= 1, "A slot holds at least one character."
        if self.min_length is None:
            object.__setattr__(self, "min_length", self.length)
        assert 1 <= self.min_length <= self.length, "min_length is 1..length."

    def accepts(self, value: str) -> bool:
        if self.alphabet.input is AlphabetInput.CHOSEN:
            return self.alphabet.accepts(value)
        chars = split_runes(value)
        return 0 < len(chars) <= self.length and all(self.alphabet.accepts(c) for c in chars)

    def canonical(self, value: str) -> str:
        return self.alphabet.canonical_all(value)

    def render(self, value: str) -> str:
        return self.alphabet.render_all(value)

    def is_full(self, value: str | None) -> bool:
        return value is not None and len(value) >= self.length

    def is_complete(self, value: str | None) -> bool:
        return value is not None and len(value) >= self.min_length


@dataclass(frozen=True)
class PlateMirror:
    """An echo of a slot's value painted elsewhere; `source` indexes `PlateSpec.slots`."""

    source: int
    box: PlateBox
    glyph_height: float
    alphabet: PlateAlphabet | None = None
    editable: bool = False


@dataclass(frozen=True)
class PlateRule:
    box: PlateBox


class Role(Enum):
    """Fills resolved at render time: theme field, country panel, theme divider."""

    FIELD = "field"
    PANEL = "panel"
    DIVIDER = "divider"


class PlateFog(NamedTuple):
    """The field colour airbrushed over a stripes leaf: an ellipse fading out from `plateau`."""

    center: tuple[float, float]
    radii: tuple[float, float]
    opacity: float = 1
    plateau: float = 0.5


@dataclass(frozen=True)
class ColorFill:
    color: int


@dataclass(frozen=True)
class StripesFill:
    """Parallel bands tilted by `angle`; `stops` has one fewer entry than `stripes`."""

    stripes: tuple[PlateFill, ...]
    stops: tuple[float, ...]
    angle: float = 0
    fog: PlateFog | None = None


PlateFill = Union[ColorFill, StripesFill, Role]


def paints_panel(fill: PlateFill) -> bool:
    if isinstance(fill, StripesFill):
        return any(s is Role.PANEL for s in fill.stripes)
    return fill is Role.PANEL


def resolve_fill(fill: PlateFill, field: int, panel: int, divider: int) -> int:
    """The paint colour; not meaningful for stripes, paint each stripe."""
    if fill is Role.FIELD:
        return field
    if fill is Role.PANEL:
        return panel
    if fill is Role.DIVIDER:
        return divider
    return fill.color


@dataclass(frozen=True)
class PlatePart:
    """One region of a split section; `end` is its far edge, None on the last part."""

    section: PlateSection
    end: float | None = None
    divider: float = 0


class SectionLayout(NamedTuple):
    leaves: list[tuple[Any, Rect]]
    dividers: list[Rect]


@dataclass(frozen=True)
class Leaf:
    fill: PlateFill
    shape: str | None = None
    """SVG path data in leaf-local units."""

    def paints_panel(self) -> bool:
        return paints_panel(self.fill)

    def layout(self, bounds: Rect) -> SectionLayout:
        return layout(self, bounds)


@dataclass(frozen=True)
class Split:
    axis: Axis
    parts: tuple[PlatePart, ...]

    def paints_panel(self) -> bool:
        return any(p.section.paints_panel() for p in self.parts)

    def layout(self, bounds: Rect) -> SectionLayout:
        return layout(self, bounds)


PlateSection = Union[Leaf, Split]


def columns(parts) -> Split:
    return Split(Axis.HORIZONTAL, tuple(parts))


def rows(parts) -> Split:
    return Split(Axis.VERTICAL, tuple(parts))


PLAIN = Leaf(Role.FIELD)


def _ltrb(l: float, t: float, r: float, b: float) -> Rect:
    return Rect(l, t, r - l, b - t)


def layout(section: PlateSection, bounds: Rect) -> SectionLayout:
    """The leaves and dividers of the tree laid over `bounds`, depth-first."""
    leaves: list = []
    dividers: list = []

    def walk(s: PlateSection, r: Rect):
        if isinstance(s, Leaf):
            leaves.append((s, r))
            return
        across = s.axis is Axis.HORIZONTAL
        start = r.left if across else r.top
        last = len(s.parts) - 1
        for i, part in enumerate(s.parts):
            end = (r.right if across else r.bottom) if i == last else part.end
            walk(part.section, _ltrb(start, r.top, end, r.bottom) if across
                 else _ltrb(r.left, start, r.right, end))
            if part.divider > 0 and i != last:
                half = part.divider / 2
                dividers.append(_ltrb(end - half, r.top, end + half, r.bottom) if across
                                else _ltrb(r.left, end - half, r.right, end + half))
            start = end

    walk(section, bounds)
    return SectionLayout(leaves, dividers)



@dataclass(frozen=True)
class PlateBand:
    """A solid block of colour floating on the background."""

    box: PlateBox
    color: int
    top_corner_radius: float = 0
    bottom_corner_radius: float = 0


@dataclass(frozen=True)
class PlateDecal:
    """A fixed image or drawing; assets are loaded by the ui layer."""

    box: PlateBox
    image: PlateAsset | None = None
    drawing: PlateDrawing | None = None

    def __post_init__(self):
        assert (self.image is None) != (self.drawing is None), "A decal is an image or a drawing."


PlateLabelResolver = Callable[[Callable[[str], str]], "str | None"]
PlateThemeResolver = Callable[[Any, Callable[[str], str]], Any]


@dataclass(frozen=True)
class PlateLabel:
    text: str
    box: PlateBox
    glyph_height: float
    color: int | None = None
    rotated: bool = False
    line_height: float | None = None
    font_family: str | None = None
    font_package: str | None = None
    resolve: PlateLabelResolver | None = None


@dataclass(frozen=True)
class PlatePanel:
    """The country block. `padding` None means 10% of the panel height; `shape` is path data."""

    box: PlateBox
    flag_scale: float = 1.0
    caption_scale: float = 1.0
    padding: Insets | None = None
    direction: Axis = Axis.VERTICAL
    shape: str | None = None


@dataclass(frozen=True)
class PlateTextGroup:
    indices: tuple[int, ...]
    prefix: str = ""
    key: str | None = None


@dataclass(frozen=True, eq=False)
class PlateSpec:
    """A complete plate design; equal iff ids match."""

    id: str
    country: PlateCountry
    canvas_width: float
    canvas_height: float
    panel: PlatePanel | None
    slots: tuple[PlateSlot, ...]
    background: PlateSection = PLAIN
    bands: tuple[PlateBand, ...] = ()
    rules: tuple[PlateRule, ...] = ()
    labels: tuple[PlateLabel, ...] = ()
    decals: tuple[PlateDecal, ...] = ()
    mirrors: tuple[PlateMirror, ...] = ()
    text_direction: TextDirection = TextDirection.LTR
    border_width_ratio_override: float | None = None
    ink_override: int | None = None
    text_groups: tuple[PlateTextGroup, ...] = ()
    restrictions: tuple[Any, ...] = ()
    """Objects with `group` and `matches(value)`."""
    resolve_theme: PlateThemeResolver | None = None
    resolve_region: PlateLabelResolver | None = None

    @property
    def slot_count(self) -> int:
        return len(self.slots)

    def slot_at(self, index: int) -> PlateSlot | None:
        return self.slots[index] if 0 <= index < len(self.slots) else None

    @property
    def effective_text_groups(self) -> tuple[PlateTextGroup, ...]:
        return self.text_groups or tuple(PlateTextGroup((i,)) for i in range(len(self.slots)))

    def group_at(self, index: int) -> PlateTextGroup | None:
        return next((g for g in self.effective_text_groups if index in g.indices), None)

    def group_named(self, key: str) -> PlateTextGroup | None:
        return next((g for g in self.effective_text_groups if g.key == key), None)

    def render_group(self, group: PlateTextGroup, values: list[str | None]) -> str:
        out = [group.prefix]
        for i in group.indices:
            value = (values[i] or "") if i < len(values) else ""
            slot = self.slot_at(i)
            out.append(slot.render(value) if slot else "")
        return "".join(out)

    def next_index(self, index: int) -> int | None:
        return index + 1 if 0 <= index and index + 1 < len(self.slots) else None

    def previous_index(self, index: int) -> int | None:
        return index - 1 if 0 < index < len(self.slots) else None

    def value_of_group(self, key: str, values: list[str | None]) -> str:
        return "".join((values[i] or "") for i in self.indices_of_group(key) if i < len(values))

    def restriction_violated_by(self, values: list[str | None]):
        return next((r for r in self.restrictions if r.matches(self.value_of_group(r.group, values))), None)

    def check_restrictions(self, values: list[str | None]) -> None:
        from .plate_restriction import PlateRestrictionError
        r = self.restriction_violated_by(values)
        if r is not None:
            raise PlateRestrictionError(r)

    def indices_of_group(self, key: str) -> tuple[int, ...]:
        g = self.group_named(key)
        return g.indices if g else ()

    def __eq__(self, other: object) -> bool:
        return isinstance(other, PlateSpec) and other.id == self.id

    def __hash__(self) -> int:
        return hash(self.id)
