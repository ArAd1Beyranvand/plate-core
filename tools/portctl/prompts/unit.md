Port one Dart file to {{lang_name}}. Output ONLY the complete {{lang_name}} file in one ```{{fence}}
block, with no explanation.

Rules:
- Same classes, functions and behaviour as the Dart. Reason/error strings byte-identical.
- Same imports and style as the example port below. Names keep the casing the example uses.
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

### Now port Dart `{{dart_path}}` → `{{target_path}}`
```dart
{{dart}}
```
{{retry}}
