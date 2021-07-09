/// Engine events
class Engine {
  static const String open = 'open'; // (InternetAddress)
  static const String connection = 'connection'; // (EngineSocket)
  static const String data = 'data'; // (Uint8List)
  static const String error = 'error'; // (Object)
  static const String closing = 'closing'; // (Null)
  static const String close = 'close'; // (Null)
}
