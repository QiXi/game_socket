import '../../protocol.dart';

abstract class PacketFactory {
  Packet createPacket(Schema schema);
}

class GamePacketFactory implements PacketFactory {
  @override
  Packet createPacket(Schema schema) {
    if (schema.code == GSS().code) {
      return GameSocketPacket();
    } else if (schema.code == RoomSchema().code) {
      return RoomPacket();
    } else {
      return Packet(schema);
    }
  }
}
