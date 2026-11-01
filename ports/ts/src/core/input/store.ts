export type Unsubscribe = () => void;

/** A readable value with change callbacks; `subscribe`/`get` fit `useSyncExternalStore`. */
export interface ReadonlyStore<T> {
  readonly value: T;
  get(): T;
  subscribe(listener: () => void): Unsubscribe;
}

/** Notifies on every `notify()`; the controller's whole-plate grain. */
export class Notifier {
  private readonly listeners = new Set<() => void>();

  subscribe = (listener: () => void): Unsubscribe => {
    this.listeners.add(listener);
    return () => this.listeners.delete(listener);
  };

  protected notify(): void {
    for (const l of [...this.listeners]) l();
  }

  /** Drops every listener. */
  dispose(): void {
    this.listeners.clear();
  }
}

/** Notifies only when the value changes (`!==`), as a ValueNotifier does. */
export class Store<T> extends Notifier implements ReadonlyStore<T> {
  constructor(private current: T) {
    super();
  }

  get value(): T {
    return this.current;
  }

  set value(next: T) {
    if (next === this.current) return;
    this.current = next;
    this.notify();
  }

  get = (): T => this.current;
}

/** A store that is null forever. */
export const alwaysNull: ReadonlyStore<null> = Object.freeze({
  value: null,
  get: () => null,
  subscribe: () => () => {},
});
