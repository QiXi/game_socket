import '../../protocol.dart';
import 'packet_factory.dart';

class ServerOptions {
  static final ServerOptions _default = ServerOptions()
    ..addSchema(GameSocketSchema())
    ..addSchema(RoomSchema());

  bool _locked = false;
  int port;
  bool supportRawData = false;
  int maxIncomingPacketSize = 2048;
  int maxSessionIdleTime = 60; // seconds
  bool closeSocketOnError = false;
  bool sendRoomEvents = true;
  int connectionTimeout; // ms

  final Schema mainSchema = GameSocketSchema();
  final List<Schema?> _schemas = List.filled(256, null);
  late PacketFactory _packetFactory;

  factory ServerOptions.byDefault() {
    return _default..packetFactory = GamePacketFactory();
  }

  ServerOptions({this.port = 3103, this.connectionTimeout = 45000});

  Schema? addSchema(Schema schema) {
    _schemas[schema.code] = schema;
  }

  Schema? getSchema(int code, int version) {
    return _schemas[code];
  }

  void lock() {
    _locked = true;
  }

  PacketFactory get packetFactory => _packetFactory;

  set packetFactory(PacketFactory factory) {
    if (_locked) {
      print('Packet factory cannot be set. Instance is locked.');
    } else {
      _packetFactory = factory;
    }
  }

  @override
  String toString() {
    return 'Options{ port:$port raw:$supportRawData closeOnError:$closeSocketOnError }';
  }
}
