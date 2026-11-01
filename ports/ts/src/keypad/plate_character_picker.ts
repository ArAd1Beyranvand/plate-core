import type { PlateAlphabet } from '../core/alphabet/plate_alphabet';

const wheelchair =
  '<svg viewBox="0 0 24 24" width="36" height="36" fill="currentColor"><circle cx="12" cy="4" r="2"/><path d="M19 13v-2c-1.5 0-3.3-.9-4.1-2l-1-1.6a2 2 0 0 0-1.7-.9c-.3 0-.5.1-.8.2L6 8.3V13h2V9.6l1.8-.7L8.2 17a2 2 0 0 0 2 2h5.4l3.2 3 1.4-1.4-4-3.6h-4.1l.5-2.7c1 1 2.7 1.7 4.5 1.7v-2Z"/></svg>';

/** The rows of the picker: the canonical character and the glyph it shows. */
export const pickerItems = (alphabet: PlateAlphabet) => alphabet.characters.map((value) => ({ value, glyph: alphabet.render(value) }));

/**
 * [D8] A modal `<dialog>` with a scroll-snap list over [alphabet]'s characters. Resolves with the
 * chosen canonical character (not the rendered glyph), or null when dismissed. Pass it to `onChooseCharacter`.
 */
export function showPlateCharacterPicker(alphabet: PlateAlphabet, initial?: string, parent: HTMLElement = document.body): Promise<string | null> {
  return new Promise((resolve) => {
    const dialog = document.createElement('dialog');
    const list = document.createElement('div');
    list.style.cssText = 'height:280px;overflow-y:auto;scroll-snap-type:y mandatory;width:200px;margin:auto';
    const items = pickerItems(alphabet);
    let index = Math.max(0, items.findIndex((i) => i.value === initial));
    const rows = items.map(({ glyph }, i) => {
      const row = document.createElement('div');
      row.style.cssText = 'height:64px;display:flex;align-items:center;justify-content:center;font-size:32px;scroll-snap-align:center;cursor:pointer';
      if (glyph.includes('♿')) row.innerHTML = wheelchair;
      else row.textContent = glyph;
      row.addEventListener('click', () => row.scrollIntoView({ block: 'center', behavior: 'smooth' }));
      row.dataset.index = String(i);
      return row;
    });
    list.append(...rows);
    list.addEventListener('scroll', () => {
      index = Math.min(items.length - 1, Math.max(0, Math.round(list.scrollTop / 64)));
    });
    const ok = document.createElement('button');
    ok.textContent = 'OK';
    ok.style.cssText = 'display:block;margin:8px auto 0;font-size:18px';
    ok.addEventListener('click', () => dialog.close(items[index]?.value));
    dialog.append(list, ok);
    dialog.addEventListener('close', () => {
      dialog.remove();
      resolve(dialog.returnValue || null);
    });
    parent.append(dialog);
    dialog.showModal();
    list.scrollTop = index * 64;
  });
}
