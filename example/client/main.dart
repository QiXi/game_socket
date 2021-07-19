import 'dart:io' show InternetAddress;
import 'dart:typed_data';

import 'package:game_socket/client.dart';

void main() {
  var client = GameClientExample()..getOptions().supportRawData = true;
  client.connect('localhost', 3103);
}

class GameClientExample extends GameSocketClient {
  GameClientExample() {
    on(Event.open, (address) => _onOpen(address));
    on(Event.handshake, (data) => _onHandshake(data));
    on(Event.data, (data) => _onData(data));
    on(Event.raw, (data) => _onRawData(data));
    on(Event.error, (error) => _onError(error));
    on(Event.closing, (_) => {print('closing')});
    on(Event.close, (_) => _onClose());
    on(Event.roomPacket, (packet) => _onRoomPacket(packet));
    on(Event.packet, (packet) => _onPacket(packet));
    on(Event.disconnecting, (reason) => {print('disconnecting $reason')});
    on(Event.disconnect, (reason) => {print('disconnect $reason')});
    on(Event.send, (data) => {print('>> $data')});
    on(Event.pong, (time) => {print('ping:$time ms')});
  }

  void _onOpen(InternetAddress address) {
    print('open $address $state');
  }

  void _onHandshake(Packet packet) {
    print('handshake $packet');
    if (packet.namespace == '/') {
      sendMessage(ConnectRequest('/home'));
    } else if (packet.namespace == '/home') {
      sendMessage(JoinRoomRequest('lobby', namespace: '/home'));
    }
  }

  void _onData(Uint8List data) {
    print('data[${data.length}] $data ');
  }

  void _onRawData(Uint8List data) {
    print('Raw: $data');
  }

  void _onRoomPacket(RoomPacket packet) {
    var roomName = packet.roomName;
    if (packet.joinRoom && roomName == 'lobby') {
      var msg = RoomEvent(roomName!, namespace: '/home', event: 'hello', message: 'hello all');
      sendMessage(msg);
    }
  }

  void _onPacket(Packet packet) {
    print('Packet: $packet');
  }

  void _onError(String error) {
    print('Error: $error');
  }

  void _onClose() {
    print('$close $state');
  }
}
