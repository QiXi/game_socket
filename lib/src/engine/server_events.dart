class ServerEvent {
  // (GameClient socket)
  static const String connection = 'connection';

  // ([String namespace, String socketId])
  static const String connect = 'connect';
  static const String error = 'error';
  static const String close = 'close';
  static const String createRoom = 'create-room';
  static const String deleteRoom = 'delete-room';
  static const String joinRoom = 'join-room';
  static const String leaveRoom = 'leave-room';

  // (Uint8List data)
  static const String raw = 'raw';
}
