from __future__ import annotations

from dataclasses import dataclass, field
from enum import Enum
from functools import cached_property
from typing import Callable


class AlphabetInput(Enum):
    TYPED = "typed"
    """Typed into a text field."""

    CHOSEN = "chosen"
    """Picked from a chooser or fed in by the host, for characters absent from a normal keyboard."""


class TextDirection(Enum):
    LTR = "ltr"
    RTL = "rtl"


def split_runes(value: str) -> list[str]:
    """`value` one string per code point."""
    return list(value)


def _tokens(pattern: str) -> list[str]:
    out = []
    for token in pattern.split(" "):
        if not token:
            continue
        if len(token) == 3 and token[1] == "-":
            out.extend(chr(r) for r in range(ord(token[0]), ord(token[2]) + 1))
        else:
            out.append(token)
    return out


def _expand(include: str, exclude: str) -> tuple[str, ...]:
    drop = set(_tokens(exclude))
    return tuple(c for c in _tokens(include) if c not in drop)


@dataclass(frozen=True, eq=False)
class PlateAlphabet:
    """The characters a slot accepts and how they are rendered; equal iff ids match."""

    id: str
    input: AlphabetInput
    is_numeric: bool
    glyphs: dict[str, str] = field(default_factory=dict)
    direction: TextDirection = TextDirection.LTR
    placeholder: str = "?"
    listed: tuple[str, ...] | None = None
    include: str = ""
    exclude: str = ""

    @classmethod
    def of(cls, id: str, characters, input: AlphabetInput, is_numeric: bool, **kw) -> PlateAlphabet:
        return cls(id, input, is_numeric, listed=tuple(characters), **kw)

    @classmethod
    def pattern(cls, id: str, include: str, input: AlphabetInput, is_numeric: bool,
                exclude: str = "", **kw) -> PlateAlphabet:
        """`include`/`exclude` are space-separated tokens; `X-Y` is every character from X to Y."""
        return cls(id, input, is_numeric, include=include, exclude=exclude, **kw)

    @cached_property
    def characters(self) -> tuple[str, ...]:
        """Every legal character in canonical (storage) form, in picker order."""
        return self.listed if self.listed is not None else _expand(self.include, self.exclude)

    def accepts(self, value: str) -> bool:
        return self.canonical(value) in self.characters

    def canonical(self, value: str) -> str:
        if value in self.characters:
            return value
        for k, v in self.glyphs.items():
            if v == value:
                return k
        upper = value.upper()
        return upper if upper != value and upper in self.characters else value

    def render(self, value: str) -> str:
        return self.glyphs.get(value, value)

    def render_all(self, value: str) -> str:
        return self.glyphs[value] if value in self.glyphs else _each(value, self.render)

    def canonical_all(self, value: str) -> str:
        whole = self.canonical(value)
        return whole if whole in self.characters else _each(value, self.canonical)

    def __eq__(self, other: object) -> bool:
        return isinstance(other, PlateAlphabet) and other.id == self.id

    def __hash__(self) -> int:
        return hash(self.id)


def _each(value: str, f: Callable[[str], str]) -> str:
    return "".join(f(c) for c in split_runes(value))


LATIN_DIGITS = PlateAlphabet.pattern("latin.digits", "0-9", AlphabetInput.TYPED, True)
LATIN_UPPERCASE = PlateAlphabet.pattern("latin.upper", "A-Z", AlphabetInput.TYPED, False)
