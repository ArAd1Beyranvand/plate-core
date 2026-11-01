import type { SlotInput } from './plate_canvas';

/**
 * [D8] A native <input> over one slot box: transparent text (the glyph run is painted under it),
 * caret from [activeColor]; keypad behaviours get inputmode=none. Boxes are spec units × [scale].
 */
export function slotInputElement(slot: SlotInput, o: { value: string; scale: number; activeColor: string }): HTMLInputElement {
  const el = document.createElement('input');
  const { left, top, right, bottom } = slot.box;
  el.value = o.value;
  el.dataset.slot = String(slot.index);
  el.autocomplete = 'off';
  el.spellcheck = false;
  if (slot.behavior === 'externalField' || slot.behavior === 'keypadFirstField') el.inputMode = 'none';
  if (slot.behavior === 'sheet') el.readOnly = true;
  Object.assign(el.style, {
    position: 'absolute',
    left: `${left * o.scale}px`,
    top: `${top * o.scale}px`,
    width: `${(right - left) * o.scale}px`,
    height: `${(bottom - top) * o.scale}px`,
    background: 'transparent',
    border: '0',
    padding: '0',
    outline: 'none',
    color: 'transparent',
    caretColor: o.activeColor,
    textAlign: 'center',
  });
  return el;
}

/** [H14] Focus without scrolling the page, as _HoldsPageStill did. */
export const focusSlot = (el: HTMLElement): void => el.focus({ preventScroll: true });
