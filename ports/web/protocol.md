# plate-embed protocol, v1

Every message is `{ "ns": "plate-embed", "v": 1, "type": <string>, "payload": <object> }`. A
receiver drops anything with another `ns`, a higher major `v`, or an unknown `type`, silently.

Origins: the host accepts a message only if `event.source === iframe.contentWindow` and
`event.origin` is the component's origin. The component records the origin of the first valid
`init` and from then on posts only to it (`targetOrigin`), ignoring every other origin. Before
`init` it posts `hello` with `targetOrigin` set to its own build-time `GALLERY_ORIGIN` (default: its
own origin).

| # | dir | type | payload | when |
|---|---|---|---|---|
| 1 | C→H | `hello` | `{lang, country, version}` | once on boot, before the runtime is ready |
| 2 | H→C | `init` | `{spec?: string, values?: (string\|null)[], theme: "light"\|"dark", locale: string, keypad: boolean}` | reply to hello |
| 3 | C→H | `ready` | `{specs: {id, label}[], spec: string, height: number}` | first paint done |
| 4 | C→H | `resize` | `{height: number}` | document height changed (CSS px) |
| 5 | C→H | `change` | `{spec, values, text, complete: boolean, valid: boolean\|null}` | any edit or spec switch |
| 6 | H→C | `action` | `{name: "setSpec"\|"setValues"\|"clear"\|"focus"\|"setTheme"\|"leave", args: object}` | user acts in the gallery; `leave`: the gallery is about to drop this component, so its plate staggers every part out |
| 7 | C→H | `progress` | `{stage: string, fraction: number\|null}` | optional, while the runtime boots (W11) |
| 8 | C→H | `error` | `{code: string, message: string, fatal: boolean}` | load failure, bad action, exception |

Loading (W11): the component's `index.html` paints its own splash at once and removes it at `ready`; the host shows a skeleton only until `hello`. Host states: `loading` → `booting` (iframe shown) → `ready`. `error` with `fatal` or 15 s without `hello` → `failed`
(retry button reloads the iframe). A non-fatal `error` is shown inline.

Iframe attributes: `sandbox="allow-scripts allow-same-origin allow-forms"`, `loading="lazy"`,
`allow="clipboard-write"`, `title="<Country> plate · <Language>"`, width 100%, height from `resize`.

## Validation (shared by every receiver)

`protocol_vectors.json` holds `{name, dir: "C2H"|"H2C", message, valid}` cases; `dir` names the
direction of travel, so the receiver is the host for `C2H` and the component for `H2C`. A receiver
accepts a case iff the envelope is right (`ns`, integer `v` == 1, string `type`, object `payload`),
the `type` belongs to that direction, and the payload has the listed fields with the listed types.
Extra payload fields are allowed. Invalid messages are dropped without an exception.
Direction sets: C2H = hello, ready, resize, change, progress, error; H2C = init, action.
Payload rules: `height` is a finite number >= 0; `fraction` is null or in [0, 1]; `values` is an array of
string|null; `theme` is `light`|`dark`; `lang` is `flutter|typescript|kotlin|python`; `action.args` is an object.
