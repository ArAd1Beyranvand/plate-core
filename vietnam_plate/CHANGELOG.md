## Unreleased

- A plate is one slot per printed field, not per character: the province, the series, the two halves of a number around the dot, and the foreign mission and status codes are each one slot. `values` is now `['30', 'F', '256', '58']`.
- The series is one field of one or two letters (`minLength: 1`, `length: 2`). Removed the `serial` and `digits` parameters of `long`, `short` and `motorcycle`; `long`, `short`, `motorcycle`, `temporary`, `militaryLong`, `militaryShort` and `militaryMotorcycle` are now static fields, not methods.
- Removed the old four-digit numbering (`2565`): every number is `256.58`. The validator now asks for five digits.
- A one-letter series sits centred in its two-letter field, so it is not flush against the dash.
