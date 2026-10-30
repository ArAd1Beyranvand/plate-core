{{> _common}}

## Task {{task}}: fix the {{lang_name}} TODO audit

Local models checked every `TODO({{lang}})` note of the Dart files just ported against the
{{lang_name}} code. These did not pass. `no` = the code ignores the note, `missing` = no definition
was found under that name, `unclear` = the model could not decide:

{{items}}

For each item, read the Dart note and the port. Fix the port where it really falls short. Rename or add the
definition for `missing` items where the name genuinely differs, and ignore false alarms. Keep the
oracle green. End with a short table: item → fixed / false alarm (why).

Contract: {{contract}}
