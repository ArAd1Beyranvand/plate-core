import type { PlateController } from '../core/input/plate_controller';
import type { Unsubscribe } from '../core/input/store';

/** [D1] Calls [onChange] only when [selector]'s result changes (`!==`, or [equals]). */
export function plateSelector<T>(
  controller: PlateController,
  selector: (c: PlateController) => T,
  onChange: (value: T) => void,
  equals: (a: T, b: T) => boolean = (a, b) => a === b,
): Unsubscribe {
  let value = selector(controller);
  return controller.subscribe(() => {
    const next = selector(controller);
    if (equals(next, value)) return;
    onChange((value = next));
  });
}
