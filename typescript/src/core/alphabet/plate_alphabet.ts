export type TextDirection = 'ltr' | 'rtl';
export type AlphabetInput = 'typed' | 'chosen';

/** [value] one string per code point. */
export const splitRunes = (value: string): string[] => Array.from(value);

function* tokens(pattern: string): Generator<string> {
  for (const token of pattern.split(' ')) {
    if (token === '') continue;
    const runes = Array.from(token);
    if (runes.length === 3 && runes[1] === '-') {
      for (let r = runes[0].codePointAt(0)!; r <= runes[2].codePointAt(0)!; r++) yield String.fromCodePoint(r);
    } else yield token;
  }
}

export interface PlateAlphabetInit {
  readonly id: string;
  readonly input: AlphabetInput;
  readonly isNumeric: boolean;
  /** Storage form to display form; first key wins on a shared glyph. */
  readonly glyphs?: ReadonlyMap<string, string>;
  readonly direction?: TextDirection;
  readonly placeholder?: string;
}

/**
 * The characters a slot accepts and how they are rendered. Equal iff the ids
 * match; key Maps and Sets by `id`.
 */
export class PlateAlphabet {
  readonly id: string;
  readonly input: AlphabetInput;
  readonly isNumeric: boolean;
  readonly glyphs: ReadonlyMap<string, string>;
  readonly direction: TextDirection;
  readonly placeholder: string;
  private readonly source: readonly string[] | { include: string; exclude: string };
  private expanded?: ReadonlySet<string>;
  private list?: readonly string[];

  private constructor(init: PlateAlphabetInit, source: PlateAlphabet['source']) {
    this.id = init.id;
    this.input = init.input;
    this.isNumeric = init.isNumeric;
    this.glyphs = init.glyphs ?? new Map();
    this.direction = init.direction ?? 'ltr';
    this.placeholder = init.placeholder ?? '?';
    this.source = source;
  }

  static listed(init: PlateAlphabetInit & { characters: readonly string[] }): PlateAlphabet {
    return new PlateAlphabet(init, init.characters);
  }

  /** `X-Y` tokens are code point ranges; excluded tokens are removed from the included ones. */
  static pattern(init: PlateAlphabetInit & { include: string; exclude?: string }): PlateAlphabet {
    return new PlateAlphabet(init, { include: init.include, exclude: init.exclude ?? '' });
  }

  /** Every legal character in canonical (storage) form, in picker order. */
  get characters(): readonly string[] {
    if (!this.list) {
      const s = this.source;
      if (Array.isArray(s)) this.list = Object.freeze([...s]);
      else {
        const { include, exclude } = s as { include: string; exclude: string };
        const drop = new Set(tokens(exclude));
        this.list = Object.freeze([...tokens(include)].filter((c) => !drop.has(c)));
      }
    }
    return this.list;
  }

  private get set(): ReadonlySet<string> {
    return (this.expanded ??= new Set(this.characters));
  }

  accepts(value: string): boolean {
    return this.set.has(this.canonical(value));
  }

  /** [value] folded to storage form; anything unrecognised is returned unchanged. */
  canonical(value: string): string {
    if (this.set.has(value)) return value;
    for (const [key, glyph] of this.glyphs) if (glyph === value) return key;
    const upper = value.toUpperCase();
    return upper !== value && this.set.has(upper) ? upper : value;
  }

  render(value: string): string {
    return this.glyphs.get(value) ?? value;
  }

  renderAll(value: string): string {
    return this.glyphs.get(value) ?? splitRunes(value).map((c) => this.render(c)).join('');
  }

  canonicalAll(value: string): string {
    const whole = this.canonical(value);
    return this.set.has(whole) ? whole : splitRunes(value).map((c) => this.canonical(c)).join('');
  }

  equals(other: PlateAlphabet): boolean {
    return other.id === this.id;
  }
}

export const latinDigits = PlateAlphabet.pattern({ id: 'latin.digits', include: '0-9', input: 'typed', isNumeric: true });
export const latinUppercase = PlateAlphabet.pattern({ id: 'latin.upper', include: 'A-Z', input: 'typed', isNumeric: false });
