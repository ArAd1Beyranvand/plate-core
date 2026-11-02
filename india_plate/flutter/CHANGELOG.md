## Unreleased

- Each field (state, RTO, series, number, mission, ...) is one `PlateSlot` with
  a `length` and `spacing` instead of a `plateRegister` of single cells.
  Diplomatic mission and vehicle numbers are `minLength: 1`.
- The validator is quiet until every field reaches its minimum length.

## 0.1.0

- First release: eight formats in one layout, eleven colour-class themes, and
  the state-code, class and category validator.
