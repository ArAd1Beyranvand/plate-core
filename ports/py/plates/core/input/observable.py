from __future__ import annotations

from typing import Callable, Generic, TypeVar

T = TypeVar("T")
Listener = Callable[[], None]


class Notifier:
    """A ChangeNotifier: notifies on every call (D7)."""

    def __init__(self):
        self._listeners: list[Listener] = []

    def subscribe(self, listener: Listener) -> Listener:
        self._listeners.append(listener)
        return listener

    def unsubscribe(self, listener: Listener) -> None:
        if listener in self._listeners:
            self._listeners.remove(listener)

    def notify(self) -> None:
        for listener in list(self._listeners):
            listener()


class Observable(Notifier, Generic[T]):
    """A ValueNotifier: notifies only when the value changes."""

    def __init__(self, value: T):
        super().__init__()
        self._value = value

    @property
    def value(self) -> T:
        return self._value

    @value.setter
    def value(self, value: T) -> None:
        if self._value == value:
            return
        self._value = value
        self.notify()


class _Frozen(Observable):
    def subscribe(self, listener: Listener) -> Listener:
        return listener

    @Observable.value.setter
    def value(self, value) -> None:
        pass


ALWAYS_NONE: Observable = _Frozen(None)
"""What `PlateController.slot` returns outside the plate: None forever."""
