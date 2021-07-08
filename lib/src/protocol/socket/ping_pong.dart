import 'game_socket_message.dart';
import 'game_socket_schema.dart';

const int maxInt32 = 4294967295;

class Ping extends GameSocketMessage {
  Ping([int? value]) : super('/') {
    enable(GameSocketSchema.ping);
    var data = value ?? DateTime.now().millisecondsSinceEpoch % maxInt32;
    putUInt(GameSocketSchema.time, data);
  }
}

class Pong extends GameSocketMessage {
  Pong(int value) : super('/') {
    enable(GameSocketSchema.pong);
    putUInt(GameSocketSchema.time, value);
  }
}
