import pytest

from plates.embed.shell import start
from tests.embed.fakes import FakeEnv

HOST = "https://host.test"


def boot(country):
    env = FakeEnv()
    return env, start(country, env)


@pytest.mark.parametrize("country", ["germany", "india"])
def test_handshake_edit_and_actions(country):
    env, shell = boot(country)
    assert env.types() == ["hello", "ready"]
    hello, ready = env.last("hello"), env.last("ready")
    assert hello == {"lang": "python", "country": country, "version": "1.0.0"}
    assert [s["id"] for s in ready["specs"]] == [e["id"] for e in shell.entries] and ready["spec"] == ready["specs"][0]["id"]
    assert all(origin == env.gallery_origin for _, origin in env.sent) and env.document.byId["splash"].removed

    # init fixes the host origin; nothing is posted back for it, replies go there.
    env.deliver("init", {"theme": "dark", "locale": "en", "keypad": True}, HOST)
    assert env.theme == "dark" and env.types() == ["hello", "ready"]
    sample = shell.entries[0]["sampleValues"]
    env.deliver("action", {"name": "setValues", "args": {"values": sample}}, HOST)
    change = env.last("change")
    assert change["spec"] == shell.entries[0]["id"] and change["complete"] and isinstance(change["valid"], bool)
    assert change["values"] == sample and env.sent[-1][1] == HOST

    env.deliver("action", {"name": "clear", "args": {}}, HOST)
    assert env.last("change")["values"] == [None] * len(sample) and not env.last("change")["complete"]

    # typing into the first slot input reports a change
    first = shell._plate.inputs[min(shell._plate.inputs)]
    first.value = sample[min(shell._plate.inputs)][:1]
    first.fire("input")
    assert env.last("change")["text"].strip() != ""

    # another origin, a stranger, a wrong version and a bad action are all dropped or answered with an error
    n = len(env.sent)
    env.deliver("action", {"name": "clear", "args": {}}, "https://evil.test")
    env.deliver("action", {"name": "clear", "args": {}}, HOST, from_parent=False)
    env.deliver("action", {"name": "clear", "args": {}}, HOST, v=2)
    assert len(env.sent) == n
    env.deliver("action", {"name": "setValues", "args": {}}, HOST)
    assert env.last("error") == {"code": "bad_action", "message": "setValues needs values", "fatal": False}

    # a height change is reported once, to the host
    env.document.documentElement.scrollHeight = 240
    env._resize()
    env._resize()
    assert [m["payload"] for m, _ in env.sent if m["type"] == "resize"] == [{"height": 240}]


def test_init_before_the_shell_is_up_is_applied_at_boot():
    from plates.embed import shell as mod

    env = FakeEnv()
    on_message = env.on_message
    env.on_message = lambda fn: (on_message(fn), env.deliver("init", {"spec": "de.car.a", "theme": "light", "locale": "en", "keypad": False}, HOST))
    s = mod.start("germany", env)
    assert env.last("ready")["spec"] == "de.car.a" and s.select.value == "de.car.a" and not s.keypad_box.children
    assert env.types() == ["hello", "ready"]


def test_spec_switch_keeps_values_and_reports():
    env, shell = boot("germany")
    env.deliver("init", {"theme": "light", "locale": "en", "keypad": True}, HOST)
    env.deliver("action", {"name": "setValues", "args": {"values": ["M", "A", "1"]}}, HOST)
    env.deliver("action", {"name": "setSpec", "args": {"spec": "de.car.a"}}, HOST)
    assert env.last("change")["spec"] == "de.car.a"
