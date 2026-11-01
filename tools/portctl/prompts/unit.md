Translate one Dart file into {{lang_name}}. The output must be valid {{lang_name}} source, NOT Dart:
no `final`, `static const String`, `@override`, `RegExp(r'...')` or `String x = ...` declarations.
Output ONLY the complete {{lang_name}} file in one ```{{fence}} block, with no explanation.

Rules:
- Same classes, functions and behaviour as the Dart. Reason/error strings byte-identical.
- No comments or docstrings the Dart lacks; maps and lists keep one entry per line like the Dart.
- Same imports and style as the example port below. Names keep the casing the example uses.
- Names resolve differently than in Dart: inside a method a `static` member is `ClassName.x`, an instance
  member is `this.x`. A bare `x` is an error. Keep the Dart name, `_` included.
- {{lang_name}} idioms:
{{idioms}}
- Notes for {{lang_name}}:
{{todos}}

{{roadmap}}

### Example: Dart `{{ex_path}}`
```dart
{{ex_dart}}
```

### Its accepted {{lang_name}} port
```{{fence}}
{{ex_target}}
```

### Current stub of the target (keep its package, imports and signatures)
```{{fence}}
{{stub}}
```

### Now port Dart `{{dart_path}}` → `{{target_path}}`
```dart
{{dart}}
```

Now write the {{lang_name}} version, in the same style as the accepted {{lang_name}} port above. {{lang_name}} only, not Dart.
{{retry}}
