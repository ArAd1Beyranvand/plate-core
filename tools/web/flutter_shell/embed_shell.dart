import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plate_core/plate_core.dart';

import 'bridge_stub.dart' if (dart.library.js_interop) 'bridge_web.dart';
import 'catalogue.dart';
import 'newdesign/design/tokens.dart';
import 'newdesign/plate/live_plate.dart';

const String embedVersion = '1';

/// The Flutter component (W9): one country's [GallerySource] behind the
/// plate-embed protocol. Generated `main` passes the source and its slug.
void runEmbed(GallerySource source, String slug) => runApp(EmbedApp(source: source, slug: slug));

class EmbedApp extends StatefulWidget {
  const EmbedApp({super.key, required this.source, required this.slug});

  final GallerySource source;
  final String slug;

  @override
  State<EmbedApp> createState() => _EmbedAppState();
}

class _EmbedAppState extends State<EmbedApp> {
  late final List<GalleryEntry> _entries = widget.source.entries;
  late final EmbedBridge _bridge = EmbedBridge(_onMessage);
  final GlobalKey _body = GlobalKey();
  late GalleryEntry _entry = _entries.first;
  late PlateController _plate = _controllerFor(_entry);
  ThemeMode _mode = ThemeMode.light;
  bool _keypad = true;
  bool _ready = false;
  double _height = 0;

  @override
  void initState() {
    super.initState();
    _bridge.post('hello', <String, Object?>{
      'lang': 'flutter',
      'country': widget.slug,
      'version': embedVersion,
    });
  }

  PlateController _controllerFor(GalleryEntry e) =>
      PlateController(spec: e.spec)
        ..hints.value = e.sampleValues
        ..addListener(_changed);

  void _select(GalleryEntry e, [List<String?>? values]) {
    setState(() {
      _plate.removeListener(_changed);
      _entry = e;
      _plate = _controllerFor(e);
      if (values != null) _plate.setValues(values);
    });
    _changed();
  }

  void _onMessage(Map<String, Object?> p, String type) {
    switch (type) {
      case 'init':
        final GalleryEntry? e = _find(p['spec']);
        setState(() {
          _mode = p['theme'] == 'dark' ? ThemeMode.dark : ThemeMode.light;
          _keypad = p['keypad'] != false;
        });
        if (e != null) _select(e);
        if (p['values'] is List) _plate.setValues(_values(p['values']));
        if (_ready) return;
        _ready = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _bridge.removeSplash();
          _measure(force: true);
        });
      case 'action':
        final Object? args = p['args'];
        final Map<Object?, Object?> a = args is Map ? args : const <Object?, Object?>{};
        switch (p['name']) {
          case 'setSpec':
            final GalleryEntry? e = _find(a['spec']);
            if (e != null) _select(e, a['values'] is List ? _values(a['values']) : null);
          case 'setValues':
            if (a['values'] is List) _plate.setValues(_values(a['values']));
          case 'clear':
            _plate.clear();
          case 'setTheme':
            setState(() => _mode = a['theme'] == 'dark' ? ThemeMode.dark : ThemeMode.light);
          case 'focus':
            _plate.focusFirstEmpty();
        }
    }
  }

  GalleryEntry? _find(Object? id) {
    for (final GalleryEntry e in _entries) {
      if (e.id == id) return e;
    }
    return null;
  }

  List<String?> _values(Object? v) => <String?>[
    for (int i = 0; i < _plate.values.length; i++)
      if (v is List && i < v.length && v[i] is String && (v[i] as String).isNotEmpty) v[i] as String else null,
  ];

  void _changed() {
    if (!_ready) return;
    final List<String?> values = _plate.values;
    final bool complete = _plate.isCompleted;
    final bool valid = complete && verdictOf(_entry.spec, values, _entry.validator).isValid;
    _bridge.post('change', <String, Object?>{
      'spec': _entry.id,
      'values': values,
      'text': _plate.text(),
      'complete': complete,
      'valid': complete ? valid : null,
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  void _measure({bool force = false}) {
    if (!_ready) return;
    final double? h = _body.currentContext?.size?.height;
    if (h == null || (!force && h == _height)) return;
    _height = h;
    _bridge.post(force ? 'ready' : 'resize', <String, Object?>{
      if (force) 'specs': <Object?>[for (final e in _entries) <String, Object?>{'id': e.id, 'label': e.label}],
      if (force) 'spec': _entry.id,
      'height': h,
    });
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: pdTheme(Brightness.light),
    darkTheme: pdTheme(Brightness.dark),
    themeMode: _mode,
    home: Builder(
      builder: (BuildContext context) {
        final PdTokens t = context.tokens;
        WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Column(
              key: _body,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (_entries.length > 1)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        for (final GalleryEntry e in _entries)
                          ChoiceChip(
                            label: Text(e.label, style: TextStyle(color: t.text)),
                            selected: identical(e, _entry),
                            onSelected: (_) => _select(e),
                          ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: LivePlate(
                    key: ValueKey<GalleryEntry>(_entry),
                    controller: _plate,
                    validName: _entry.label,
                    theme: _entry.themeFor(_plate.values),
                    country: _entry.country,
                    validator: _entry.validator,
                    inputSource: PlateInputSource.keypadFirst,
                    showInvalidNote: true,
                    keypadBelow: _keypad ? SlotKeypad(controller: _plate) : null,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
