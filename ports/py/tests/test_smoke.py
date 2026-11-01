from tests.vectors import load_vectors


def test_alphabet_vectors_load():
    cases = load_vectors("core/alphabet.json")
    assert len(cases) > 0
    assert "expect" in cases[0]
