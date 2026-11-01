
### Your previous attempt was rejected by the tests
```
{{previous}}
```
Test output:
```
{{error}}
```
Fix it. `Unresolved reference` / `Cannot infer type` / `Inapplicable candidate` (Kotlin) means you used a name that does not exist: delete invented helpers and use only the Dart's own members, the stub's imports and plain stdlib. Fix the first error first; the rest usually follow from it. `Cannot find name '_x'` (TS2662/TS2304) means write `ClassName._x` or `this._x`. It must be {{lang_name}}, not Dart. Output the whole corrected file again.
