export type PlateInputSource = 'system' | 'hardwareKeyboard' | 'packageKeypad' | 'host' | 'keypadFirst';

/** Hardware keyboard on a fine pointer, the system IME on a coarse one. */
export const defaultInputSource = (): PlateInputSource =>
  typeof matchMedia === 'function' && !matchMedia('(pointer: coarse)').matches ? 'hardwareKeyboard' : 'system';

/** DOM attributes that suppress the platform keyboard: every source but system. */
export const inputAttributes = (source: PlateInputSource): Record<string, string> =>
  source === 'system' ? {} : { inputmode: 'none', virtualkeyboardpolicy: 'manual' };
