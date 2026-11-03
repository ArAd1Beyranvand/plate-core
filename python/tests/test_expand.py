"""The compact country data: tuples take their defaults, slot keys become text groups, tables answer from tries."""
from plates.countries.expand import expand_country
from plates.countries.tables import label_table


def country(specs, **extra):
    return expand_country({"package": "x_plate", "alphabets": {"d": ["d", [["0", "9"]], "typed", True]}, "countries": {},
                           "themes": {}, "resolvers": {}, "assets": [], "gallery": [], "specs": specs, **extra})


def test_a_spec_takes_the_defaults_of_everything_its_tuple_leaves_off():
    (s,) = country([["x.a", "C", 100, 50, [["d", [1, 2, 3, 4]], ["d", [5, 6, 7, 8], 3, 1]]]])["specs"]
    assert s["slots"][0] | {} == {"alphabet": "d", "box": [1, 2, 3, 4], "length": 1, "minLength": 1, "spacing": 0, "color": None}
    assert (s["slots"][1]["length"], s["slots"][1]["minLength"]) == (3, 1)
    assert (s["labels"], s["bands"], s["textDirection"], s["noPanel"], s["panel"]) == ([], [], "ltr", True, None)
    assert s["background"] == {"kind": "fill", "fill": {"kind": "field"}, "shape": None}


def test_slot_keys_are_the_text_groups_and_a_spec_with_none_has_none():
    keyed, bare = country([["k", "C", 1, 1, [["d", [0, 0, 1, 1], 1, 1, 0, None, "serial"], ["d", [1, 0, 1, 1], 1, 1, 0, None, "tail"]]],
                           ["b", "C", 1, 1, [["d", [0, 0, 1, 1]]]]])["specs"]
    assert keyed["textGroups"] == [{"indices": [0], "prefix": "", "key": "serial"}, {"indices": [1], "prefix": "", "key": "tail"}]
    assert all("group" not in x for x in keyed["slots"])
    assert bare["textGroups"] == []


def test_alphabets_expand_their_ranges_and_defaults():
    a = country([], alphabets={"l": ["l", [["A", "C"], "Ä", ["X", "Z"]]]})["alphabets"]["l"]
    assert a == {"id": "l", "characters": ["A", "B", "C", "Ä", "X", "Y", "Z"], "input": "typed", "isNumeric": False,
                 "glyphs": [], "direction": "ltr", "placeholder": "?"}


def test_a_theme_tuple_is_one_ink_on_one_field():
    t = country([], themes={"t": [0xFF112233, 0xFF000000, 0.02, 0.05]})["themes"]["t"]
    assert (t["plateBorder"], t["ink"], t["dividerColor"], t["activeColor"]) == (0xFF000000,) * 4
    assert (t["inactiveColor"], t["alertColor"]) == (0xFFB0B0B0, 0xFFF87171)


def test_a_trie_table_answers_as_the_rows_it_replaced_including_its_default():
    enc = {"trie": {"prefix": [["A", "north"], ["B", "south"]], "exact": [["AX", "special"], ["", None]]}}
    resolve = label_table(["k"], {}, "elsewhere", enc)
    assert [resolve(lambda _, k=k: k) for k in ("AB", "AX", "BZ", "C", "")] == ["north", "special", "south", "elsewhere", None]


def test_a_grouped_table_lists_each_value_once_beside_its_keys():
    resolve = label_table(["k"], {}, "none", {"groups": [["one", [["a"], ["b"]]], [None, [["c"]]]]})
    assert [resolve(lambda _, k=k: k) for k in "abcd"] == ["one", "one", None, "none"]
