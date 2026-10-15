You are looking at one flattened photo of a vehicle licence plate.
Answer only about layout, with the categories offered. Do not guess
colours, sizes or the characters themselves. If you cannot tell, answer
"unknown".

- text_rows: how many separate rows of characters are on the plate?
- top_row: what the uppermost row holds — "caption" (a word or name in
  smaller letters), "serial" (the main registration characters), or "none".
- badge: is there a separate box, emblem, flag or coloured band at one end?
  "left", "right", "none".
- script: the writing of the serial — "latin", "arabic", "lao", "thai",
  "cyrillic", "chinese", "other".
- separator: between the serial's groups — "dash", "dot", "space", "none".
- fields: the serial's groups from left to right. A group is a run of
  characters printed together as one unit, set apart from the next run by a
  wider gap, a dash, a dot or a symbol. For each group say what it holds:
  "digits", "letters" or "mixed". `12 ب 345` is ["digits", "letters",
  "digits"]; `AB-123-CD` is ["letters", "digits", "letters"].
- field_lengths: how many characters each of those groups has, in the same
  order (`12 ب 345` is [2, 1, 3]). Count, do not read the characters.
- border: is there a printed border line inside the plate's edge?
- vertical_text: is any text rotated 90° or stacked letter over letter?

```json
{
  "type": "object",
  "properties": {
    "text_rows": {"type": "integer"},
    "top_row": {"type": "string", "enum": ["caption", "serial", "none", "unknown"]},
    "badge": {"type": "string", "enum": ["left", "right", "none", "unknown"]},
    "script": {"type": "string", "enum": ["latin", "arabic", "lao", "thai", "cyrillic", "chinese", "other", "unknown"]},
    "separator": {"type": "string", "enum": ["dash", "dot", "space", "none", "unknown"]},
    "fields": {"type": "array", "items": {"type": "string", "enum": ["digits", "letters", "mixed"]}},
    "field_lengths": {"type": "array", "items": {"type": "integer"}},
    "border": {"type": "boolean"},
    "vertical_text": {"type": "boolean"}
  },
  "required": ["text_rows", "top_row", "badge", "script", "separator", "fields", "field_lengths", "border", "vertical_text"]
}
```
