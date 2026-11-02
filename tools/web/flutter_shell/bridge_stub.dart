/// Non-web stand-in so the shell analyzes and tests off the browser.
class EmbedBridge {
  EmbedBridge(this.onMessage);

  final void Function(Map<String, Object?> payload, String type) onMessage;

  void post(String type, Map<String, Object?> payload) {}
  void removeSplash() {}
}
