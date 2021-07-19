import 'package:game_socket/client.dart';

void main() {
  var client = GameClientExample();
  client.connect('localhost', 3103);
}

class GameClientExample extends GameSocketClient {
  GameClientExample() {
    on(Event.handshake, (data) => _onHandshake(data));
    on(Event.roomPacket, (packet) => _onRoomPacket(packet));
  }

  void _onHandshake(Packet packet) {
    if (packet.namespace == '/') {
      sendMessage(ConnectRequest('/home'));
    } else if (packet.namespace == '/home') {
      sendMessage(JoinRoomRequest('lobby', namespace: '/home'));
    }
  }

  void _onRoomPacket(RoomPacket packet) {
    var roomName = packet.roomName;
    if (packet.joinRoom && roomName == 'lobby') {
      var msg = RoomEvent(roomName!, namespace: '/home', event: 'hello', message: 'hello all');
      sendMessage(msg);
    }
  }
}
