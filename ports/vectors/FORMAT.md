# ports/vectors

Golden vectors for the ports, written by
`plate_number_holder/test/port_vectors_test.dart`. Regenerate with
`flutter test --no-pub test/port_vectors_test.dart` from `plate_number_holder`.
The run deletes the old json first, so never edit these files by hand.

Every file has the same shape:

```json
{"cases": [{"name": "…", "input": {…}, "expect": …}]}
```

A port loads each file, rebuilds `input` with its own types, and compares the
result to `expect`. Strings must match byte for byte; that includes reasons,
captions and rendered text. Numbers must match exactly unless a section below
gives a tolerance.

## Conventions

- `package` + `spec` is a spec ref, the same as in `ports/data/countries/*.json`.
- `alphabet` is an alphabet ref from `ports/data/alphabets.json` (`id` or `id~n`).
- `values` is one entry per slot. `null` means unset; `""` means set but empty.
- Colors are ARGB32 ints.
- Rects are `[left, top, width, height]`.
- RRects are a rect followed by `tl.x, tl.y, tr.x, tr.y, br.x, br.y, bl.x, bl.y`.
- When the Dart call throws, `expect` is `{"throws": "<Dart error type>"}` and
  the port must fail the same way. In the input steps this goes in the
  `throws` field instead.
- A validator is written as `{"class": "<ClassName>", "args": {…}}`.
  `args` holds the public constructor fields and is left out when the class
  takes none.

## validators/<ClassName>.json

There is one file for every class that extends `PlateValidator` or
`GatedPlateValidator`. Abstract bases such as `_SlotsValidator` also get the
cases of all their subclasses.

- input: `{package, spec, validator, values}`
- expect: `{valid, reason}`

The case names are:

- `sample`, `empty`, `unset`
- per slot: `cleared`, `first`, `last`, `partial`, `too long`, `wrong script`
  and `lowercase`
- group literals and restriction values taken from the validator source
- seeded random fills

Values are passed to `validate` exactly as written. Do not canonicalize them
first.

## resolvers/<Owner>.<member>.json

There is one file for each `[D4-code]` resolver, meaning a spec whose
`resolver.kind` is `"code"` in `ports/data`.

- input: `{package, spec, at, groups, base?}`
  - `at` is the hook: `resolveTheme`, `regionCaption`, and so on.
  - `groups` holds the group values the resolver reads, by key.
  - `base` is the incoming theme, and appears only for theme resolvers.
- expect: the resolved theme json, or the caption string, or `null`.

Small keyed groups (4000 values or fewer) are listed exhaustively. Every
other resolver gets 600 seeded random fills.

## core/

### alphabet.json

| input | expect |
|---|---|
| `{alphabet, value}` | `{accepts, canonical, render, renderAll, canonicalAll}` |
| `{include, exclude}` (pattern expansion, H22) | `{characters}` in order |

### values.json

| case | input | expect |
|---|---|---|
| `… groups` | `{package, spec}` | `effectiveTextGroups`, `groupAt` for slots −1…n, `nextIndex` and `previousIndex` per slot |
| `… full/partial/empty/short/restricted` | `+values` | `valueOfGroup` (an unknown key `nope` gives `""`), `renderGroup`, `restrictionViolatedBy`, `checkRestrictions` |
| `… fromText "…"` | `+fromText` | controller state (see below) |
| `slot …` | `{slot: {alphabet, length, minLength}, value}` | `{accepts, canonical, render, isFull, isComplete}` |

The controller state is
`{values, isCompleted, isEmpty, rejection, text, textJoined, regionCaption}`.

### layout.json

- Spec cases. input: `{package, spec, bounds}`. expect: `{leaves, dividers}`,
  which are the section rects after layout.
- Builder cases. input: `{builder, count, left, top, width, height, pitch, …}`.
  `builder` is one of `plateRegister`, `plateEcho`, `plateStipple` or
  `plateRegisterAcross`. expect: the rects the builder returns. A count of −1
  throws.

### timing.json (H11, D7)

- `curve <name>`: input is `{curve, t[]}`. expect is `{cubic, value[]}`.
- `motion default` and `style <kind>`: `{effect, durationMs, curve, delayMs,
  origin, startPoint, clockwise, softEdge}`.
- `progress <kind> +<delay>`: input is `{kind, cueDelayMs, atMs[]}`. expect is
  `{totalMs, progress[]}`. The delay counts inside the interval.
- `<pkg> <spec> parts`:
  - `allOf` is the part ids in paint order.
  - `regionCount` and `dividerCount` are the region and divider counts.
  - The stagger tables give the cue offsets.
  - `cueLength` gives the cue lengths.
- `reveal …`: input is `{bounds, origin, phase, progress}`. expect is
  `{shown, hidden, span, rect}`.
- `<pkg> <from> -> <to>`: shows which parts a spec transition keeps. expect is
  `samePart`, `keepIdentical` and `keepPanelSlotBand`.

### input.json (H10, H17, H18, H21, D8)

- `behavior …` cases. input: `{mode, input, source}`. expect: the
  `resolveSlotBehavior` result.
- Session cases. input: `{package, spec, source, values, validator, other}`.
  - `values` is the initial value of the controller.
  - `other` is the spec that `adoptSpec` switches to.
- Session expect: `{initial, steps[]}`. Each step is
  `{op, result, throws, sheet, notified, state}`.
  - `op` is one of the following, with its arguments:
    - `submit` (`char`)
    - `clear`
    - `focusSlot` (`index`)
    - `backspace`
    - `focusFirstEmpty`
    - `setAt` (`index`, `value`)
    - `setGroup` (`key`, `value`)
    - `setValues` (`values`)
    - `adoptSpec` (`spec`, `preserve`). The plate is remounted afterwards.
  - `result` is the op's bool return, or `null`.
  - `sheet` is the slot whose picker sheet was requested, if any.
  - `notified` counts the listener calls the op caused, keyed by `whole`,
    `completed`, `rejection` or `slot <i>`.
  - `state` is the controller state plus `active`, `systemKeyboard` and
    `validation` (`{valid, reason}`).

The machine is wired the way `PlateCanvas` wires it: commits go through
`setAt`, and the probe is `restrictionVerdict ?? validator.validate`.

## render/<package>.json (D1)

input: `{package, gallery, spec, values, theme, country, size}`

- `theme` is `null` for the spec's own theme, and the full theme json
  otherwise.
- Every gallery entry is rendered with its sample values.
- The first entry of each package also gets `empty`, `partial` and `theme B`
  cases.

expect: the display list of `PlateView` (display mode) laid out at `size`.
Each op is `{op, m?, …geometry, paint?}`:

- `m = [a, b, c, d, tx, ty]` is the canvas transform, and maps the op's local
  geometry to plate units. It is left out when it is the identity.
- `paint` is `{color, stroke?, cap?, join?, shader?, blend?, maskFilter?,
  colorFilter?}`.
- The ops are:
  - `save`, `restore`
  - `layer` (`bounds`; opacity is the alpha of `paint.color`)
  - `clipRect` (`rect`, `difference?`), `clipRRect` (`rrect`),
    `clipPath` (`path`), `clipRSuperellipse` (`rect`)
  - `rect`, `rrect`, `drrect` (`outer`, `inner`), `path`, `circle`
    (`center`, `radius`), `oval`, `line`, `paint`
  - `text` (`text`, `box`, `align`, `direction`, `fontSize`, `height`,
    `color`, `fontFamily`, `fontWeight`, `letterSpacing`)
  - `asset` (`kind` is `svg` or `raster`; also `package`, `path`, `box`)
  - `colorFilter`, `shaderMask` (`rect`, `blend`)
- A clip lasts until the `restore` that closes its scope.
- `path` is `"<nonzero|evenodd>:<SVG d>"`. Each contour is sampled every
  0.25 units and thinned by RDP at 0.01, as in the `ports/data` clips.

Numbers are rounded to 4 decimal places. Compare geometry within 0.01. Text
boxes and glyph-fit scales come from the Flutter test font (H12), so compare
the text's `box`, and any `m` inside it, only loosely. The text string,
style and color must match exactly. Raster assets don't decode under the
test bundle, so only their box is recorded. Specs that fail
`debugValidateSpec` (`tt.private`, `sz.front`) are not rendered.
