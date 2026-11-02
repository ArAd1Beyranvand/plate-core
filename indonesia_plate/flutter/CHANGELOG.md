## Unreleased

- One spec per form: `IndonesiaPlates.car`, `carEv`, `motorcycle`, `motorcycleEv`, `diplomatic`, `police` and `military(service)`. Each field (area letters, number, suffix, expiry month and year, mission and vehicle numbers) is one `PlateSlot` with a `minLength`..`length` range.
- Removed the per-length constructors `car({prefix, digits, suffix, band})`, `motorcycle(...)`, `diplomatic({countryDigits, serialDigits})`, `military(service, {digits})` and `police({digits})`, the `IndonesiaFormat` record, and `prefixLengths`, `digitLengths`, `suffixLengths` and `serviceDigitLengths`.
- A plate with no suffix is no longer a separate spec: the suffix field needs at least one letter.
- `IndonesiaSerialGenerator` draws a random length per field.

## 0.2.0

- Armed-forces plates: `IndonesiaPlates.military` for the Army, Navy, Air Force and TNI headquarters (`IndonesiaService`), with the TNI crest and service marks.
- Police plate: `IndonesiaPlates.police`, with the Polri crest and the region numeral (`IndonesiaAlphabets.policeRegions`).
- `IndonesiaServiceValidator` and the army, navy, airForce, armedForces and police themes.

## 0.1.0

First pub.dev release.
