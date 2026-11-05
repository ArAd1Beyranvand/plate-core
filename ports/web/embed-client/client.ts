// Component side of the plate-embed protocol (web/protocol.md). No framework; shells may copy this.
export type Json = null | boolean | number | string | Json[] | { [k: string]: Json };
export type Dir = "C2H" | "H2C";
export interface Msg { ns: "plate-embed"; v: 1; type: string; payload: Record<string, any> }

const C2H = ["hello", "ready", "resize", "change", "progress", "error"];
const H2C = ["init", "action"];
const LANGS = ["flutter", "typescript", "kotlin", "python"];
const ACTIONS = ["setSpec", "setValues", "clear", "focus", "setTheme", "leave"];

const obj = (x: unknown): x is Record<string, any> => typeof x === "object" && x !== null && !Array.isArray(x);
const str = (x: unknown) => typeof x === "string";
const bool = (x: unknown) => typeof x === "boolean";
const height = (x: unknown) => typeof x === "number" && Number.isFinite(x) && x >= 0;
const values = (x: unknown) => Array.isArray(x) && x.every((e) => e === null || str(e));

const payloads: Record<string, (p: Record<string, any>) => boolean> = {
  hello: (p) => LANGS.includes(p.lang) && str(p.country) && str(p.version),
  ready: (p) => Array.isArray(p.specs) && p.specs.every((s: any) => obj(s) && str(s.id) && str(s.label)) && str(p.spec) && height(p.height),
  resize: (p) => height(p.height),
  change: (p) => str(p.spec) && values(p.values) && str(p.text) && bool(p.complete) && (p.valid === null || bool(p.valid)),
  progress: (p) => str(p.stage) && (p.fraction === null || (typeof p.fraction === "number" && p.fraction >= 0 && p.fraction <= 1)),
  error: (p) => str(p.code) && str(p.message) && bool(p.fatal),
  init: (p) => (p.spec === undefined || str(p.spec)) && (p.values === undefined || values(p.values)) &&
    (p.theme === "light" || p.theme === "dark") && str(p.locale) && bool(p.keypad),
  action: (p) => ACTIONS.includes(p.name) && obj(p.args),
};

/** True iff `m` is a well-formed message travelling in direction `dir`. */
export function validate(dir: Dir, m: unknown): m is Msg {
  if (!obj(m) || m.ns !== "plate-embed" || m.v !== 1 || !str(m.type) || !obj(m.payload)) return false;
  return (dir === "C2H" ? C2H : H2C).includes(m.type) && payloads[m.type](m.payload);
}

export interface Handlers {
  init(p: Record<string, any>): void;
  action(name: string, args: Record<string, any>): void;
}

/** Wires a component to its host. Call `hello()` on boot, then `ready()` after first paint. */
export function connect(info: { lang: string; country: string; version: string }, h: Handlers,
    galleryOrigin = location.origin, win: Window = window) {
  let host: string | null = null;
  const send = (type: string, payload: object, origin?: string) => {
    const target = origin ?? host ?? galleryOrigin;
    win.parent.postMessage({ ns: "plate-embed", v: 1, type, payload }, target);
  };
  win.addEventListener("message", (e: MessageEvent) => {
    if (e.source !== win.parent || (host !== null && e.origin !== host) || !validate("H2C", e.data)) return;
    if (e.data.type === "init") {
      host ??= e.origin;
      h.init(e.data.payload);
    } else if (host !== null) h.action(e.data.payload.name, e.data.payload.args);
  });
  let last = -1;
  const report = () => {
    const height = Math.ceil(document.body.offsetHeight);
    if (height !== last && host !== null) { last = height; send("resize", { height }); }
  };
  new ResizeObserver(report).observe(document.body);
  return {
    hello: () => send("hello", info),
    ready: (specs: { id: string; label: string }[], spec: string) =>
      send("ready", { specs, spec, height: Math.ceil(document.body.offsetHeight) }),
    progress: (stage: string, fraction: number | null) => send("progress", { stage, fraction }),
    change: (p: { spec: string; values: (string | null)[]; text: string; complete: boolean; valid: boolean | null }) => send("change", p),
    error: (code: string, message: string, fatal = false) => send("error", { code, message, fatal }),
  };
}
