/// Client events
class Event {
  // (InternetAddress address)
  static const String open = 'open';

  // (String namespace, String socketId)
  //static const String connect = 'connect';

  // (String message)
  static const String connectError = 'connect_error';

  // (Packet packet)
  static const String handshake = 'handshake';

  // (String namespace, String reason)
  static const String disconnecting = 'disconnecting';

  // (String namespace, String reason)
  static const String disconnect = 'disconnect';

  // (Uint8List data)
  static const String data = 'data';

  // (String error)
  static const String error = 'error';

  // (Null)
  static const String closing = 'closing';

  // (Null)
  static const String close = 'close';

  // (Packet packet)
  static const String packet = 'packet';

  // (RoomPacket packet)
  static const String roomPacket = 'room-packet';

  // (Uint8List data)
  static const String raw = 'raw';

  // (Message message)
  static const String send = 'send';

  static const String ping = 'ping';

  // (int lastPing, int avgPing)
  static const String pong = 'pong';
}
