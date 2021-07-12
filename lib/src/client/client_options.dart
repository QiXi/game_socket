import '../../protocol.dart';

class ClientOptions {
  final List<Schema?> _schemas = List.filled(256, null);
  bool supportRawData;
  int reconnectInterval = 1;
  int maxReconnectAttempts = 3;
  Duration? connectTimeout = Duration(seconds: 20);
  bool disconnectOnHighPing = true;
  int limitHighPing = 500;

  ClientOptions() : supportRawData = false {
    addSchema(GameSocketSchema());
    addSchema(RoomSchema());
  }

  Schema? addSchema(Schema schema) {
    _schemas[schema.code] = schema;
  }

  Schema? getSchema(int code, int version) {
    return _schemas[code];
  }
}
