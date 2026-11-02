import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// postMessage side of `ports/web/protocol.md` (W8): the first valid `init`
/// fixes the host origin; before it only `hello` goes out, to our own origin.
class EmbedBridge {
  EmbedBridge(this.onMessage) {
    web.window.onMessage.listen((web.MessageEvent e) {
      if (e.source != web.window.parent) return;
      final Object? d = e.data.dartify();
      if (d is! Map || d['ns'] != 'plate-embed' || d['v'] != 1) return;
      final Object? type = d['type'], payload = d['payload'];
      if (type is! String || payload is! Map) return;
      if (_origin == null) {
        if (type != 'init') return;
        _origin = e.origin;
      } else if (e.origin != _origin) {
        return;
      }
      onMessage(<String, Object?>{for (final e in payload.entries) '${e.key}': e.value}, type);
    });
  }

  final void Function(Map<String, Object?> payload, String type) onMessage;
  String? _origin;

  void post(String type, Map<String, Object?> payload) {
    final Object message = <String, Object?>{'ns': 'plate-embed', 'v': 1, 'type': type, 'payload': payload};
    web.window.parent?.postMessage(message.jsify(), (_origin ?? web.window.location.origin).toJS);
  }

  void removeSplash() => web.document.getElementById('splash')?.remove();
}
