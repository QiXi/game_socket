import '../packet.dart';
import 'game_socket_schema.dart';

typedef GSP = GameSocketPacket;

class GameSocketPacket extends Packet {
  GameSocketPacket() : super(GSS());

  bool get connect => isEnabled(GSS.connect);

  bool get disconnect => isEnabled(GSS.disconnect);

  bool get handshake => isEnabled(GSS.handshake);

  bool get ping => isEnabled(GSS.ping);

  bool get pong => isEnabled(GSS.pong);

  bool get error => isEnabled(GSS.error);

  String? get data => getString(GSS.data);

  String? get name => getString(GSS.name);

  int get value => getInt(GSS.value);

  int get pingInterval => getInt(GSS.pingInterval);

  int get time => getUInt(GSS.time);
}
