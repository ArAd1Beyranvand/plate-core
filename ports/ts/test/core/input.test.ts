import { describe, expect, test } from 'vitest';
import { PlateController, type PlateValuePreservation } from '../../src/core/input/plate_controller';
import { PlateInputMachine } from '../../src/core/input/plate_input_machine';
import type { PlateInputSource } from '../../src/core/input/plate_input_source';
import { PlateTextField } from '../../src/core/input/plate_input_machine';
import { alwaysNull } from '../../src/core/input/store';
import { PlateRestriction } from '../../src/core/values/plate_restriction';
import { valid, type PlateValidator } from '../../src/core/validators/plate_validator';
import { loadVectors } from '../vectors';
import { specOf } from './specs';

/** Stands in for the country validators, which later units port; its verdicts are not compared. */
const unported: PlateValidator = { validate: () => valid };

function state(c: PlateController, codeRegion: boolean, judged: boolean) {
  const v = c.validation;
  return {
    values: [...c.values],
    isCompleted: c.isCompleted,
    isEmpty: c.isEmpty,
    rejection: c.rejection.value?.reason ?? null,
    text: c.text(),
    textJoined: c.text(''),
    regionCaption: codeRegion ? undefined : c.regionCaption,
    active: c.activeIndex,
    systemKeyboard: c.systemKeyboardActive,
    validation: judged ? undefined : v && { valid: v.reason === null, reason: v.reason },
  };
}

function expected(s: any, codeRegion: boolean, judged: boolean) {
  return { ...s, regionCaption: codeRegion ? undefined : s.regionCaption, validation: judged ? undefined : s.validation };
}

describe('input sessions', () => {
  for (const c of loadVectors('core/input.json').filter((c) => c.input.package)) {
    test(c.name, () => {
      const { package: pkg, source, values, validator } = c.input;
      const home = specOf(pkg, c.input.spec);
      const controller = new PlateController({ spec: home.spec, values, validator: validator ? unported : null });
      let machine: PlateInputMachine | null = null;
      let sheet: number | null = null;
      let codeRegion = home.codeRegion;
      const mount = (id: string) => {
        if (machine) controller.detach(machine);
        const m = (machine = new PlateInputMachine({
          spec: controller.spec,
          readValues: () => controller.values,
          commit: (i, v) => controller.setAt(i, v),
          inputSource: source as PlateInputSource,
          onActiveIndexChanged: () => controller.notifyActiveSlotChanged(),
          onSheetRequested: (i) => (sheet = i),
        }));
        controller.attach(m);
        controller.validator = id === c.input.spec && validator ? unported : null;
        codeRegion = specOf(pkg, id).codeRegion;
      };
      mount(c.input.spec);
      // The validator's verdict is only compared where the core decides it.
      const judged = (s: any) => controller.validator !== null && s.rejection === null;
      expect(state(controller, codeRegion, judged(c.expect.initial))).toEqual(expected(c.expect.initial, codeRegion, judged(c.expect.initial)));

      for (const [n, step] of c.expect.steps.entries()) {
        const op = step.op;
        const fired: Record<string, number> = {};
        const on = (l: { subscribe(f: () => void): () => void }, k: string) => l.subscribe(() => (fired[k] = (fired[k] ?? 0) + 1));
        const subs = [on(controller, 'whole'), on(controller.completed, 'completed'), on(controller.rejection, 'rejection')];
        controller.spec.slots.forEach((_, i) => subs.push(on(controller.slot(i), `slot ${i}`)));
        sheet = null;
        let result: unknown;
        let threw: string | null = null;
        try {
          switch (op.op) {
            case 'submit': result = controller.submit(op.char); break;
            case 'backspace': result = controller.backspace(); break;
            case 'clear': result = controller.clear(); break;
            case 'focusSlot': result = controller.focusSlot(op.index); break;
            case 'focusFirstEmpty': result = controller.focusFirstEmpty(); break;
            case 'setAt': result = controller.setAt(op.index, op.value); break;
            case 'setGroup': result = controller.setGroup(op.key, op.value); break;
            case 'setValues': result = controller.setValues(op.values); break;
            case 'adoptSpec':
              controller.adoptSpec(specOf(pkg, op.spec).spec, op.preserve as PlateValuePreservation);
              mount(op.spec);
              break;
            default: throw new Error(`unknown op ${op.op}`);
          }
        } catch (e) {
          if (!(e instanceof RangeError)) throw e;
          threw = 'RangeError';
        }
        subs.forEach((u) => u());
        const at = `${c.name} step ${n} ${JSON.stringify(op)}`;
        const j = judged(step.state);
        expect({
          result: typeof result === 'boolean' ? result : null,
          throws: threw,
          sheet,
          notified: fired,
          state: state(controller, codeRegion, j),
        }, at).toEqual({ ...step, op: undefined, state: expected(step.state, codeRegion, j) });
      }
    });
  }
});

test('fromText vectors', () => {
  let seen = 0;
  for (const c of loadVectors('core/values.json').filter((c) => 'fromText' in c.input)) {
    const { spec, codeRegion } = specOf(c.input.package, c.input.spec);
    const p = PlateController.fromText(spec, c.input.fromText);
    const e = c.expect;
    expect({
      values: [...p.values],
      isCompleted: p.isCompleted,
      isEmpty: p.isEmpty,
      rejection: p.rejection.value?.reason ?? null,
      text: p.text(),
      textJoined: p.text(''),
      regionCaption: codeRegion ? undefined : p.regionCaption,
    }, c.name).toEqual({ ...e, regionCaption: codeRegion ? undefined : e.regionCaption });
    seen++;
  }
  expect(seen).toBeGreaterThan(0);
});

test('out of range slot is a frozen null store', () => {
  const { spec } = specOf('albania_plate', 'al.private');
  const c = new PlateController({ spec });
  expect(c.slot(-1)).toBe(alwaysNull);
  expect(c.slot(99).value).toBeNull();
});

test('rejection outranks the validator', () => {
  const { spec } = specOf('albania_plate', 'al.private');
  const c = new PlateController({ spec, validator: { validate: () => ({ reason: 'v' }) } });
  expect(c.validation?.reason).toBe('v');
  (c.rejection as any).value = new PlateRestriction('series', ['XX'], 'r');
  expect(c.validation?.reason).toBe('r');
});

test('hints never touch values or completion', () => {
  const { spec } = specOf('albania_plate', 'al.private');
  const c = new PlateController({ spec });
  c.hints.value = ['ab', null, null];
  expect(c.hintAt(0)).toBe('ab');
  expect(c.isEmpty).toBe(true);
});

test('setText writes only when the text differs', () => {
  let writes = 0;
  const field: PlateTextField = { value: '', setSelectionRange: () => writes++ };
  PlateInputMachine.setText(field, 'AB', (s) => s);
  PlateInputMachine.setText(field, 'AB', (s) => s);
  expect([field.value, writes]).toEqual(['AB', 1]);
});
