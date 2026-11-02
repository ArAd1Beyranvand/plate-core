import type { AlphabetInput } from '../alphabet/plate_alphabet';
import type { PlateInputSource } from './plate_input_source';

export type PlateMode = 'input' | 'display';

export type SlotBehavior = 'glyph' | 'imeField' | 'hardwareField' | 'externalField' | 'keypadFirstField' | 'sheet';

/** A chosen alphabet reaches `sheet` only under the system source. */
export function resolveSlotBehavior(o: { mode: PlateMode; input: AlphabetInput; source: PlateInputSource }): SlotBehavior {
  if (o.mode === 'display') return 'glyph';
  switch (o.source) {
    case 'system':
      return o.input === 'typed' ? 'imeField' : 'sheet';
    case 'hardwareKeyboard':
      return 'hardwareField';
    case 'packageKeypad':
    case 'host':
      return 'externalField';
    case 'keypadFirst':
      return 'keypadFirstField';
  }
}
