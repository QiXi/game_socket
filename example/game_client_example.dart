import 'dart:io';
import 'dart:typed_data';

import 'package:game_socket/client.dart';

void main() {
  var client = GameClientExample()..getOptions().supportRawData = true;
  client.connect('localhost', 3103);
}

class GameClientExample extends GameSocketClient {
  static const String tag = 'Example:';

  GameClientExample() {
    on(Event.open, (address) => _onOpen(address));
    on(Event.handshake, (data) => _onHandshake(data));
    on(Event.data, (data) => _onData(data));
    on(Event.raw, (data) => _onRawData(data));
    on(Event.error, (error) => _onError(error));
    on(Event.closing, (_) => {print('$tag closing')});
    on(Event.close, (_) => _onClose());
    on(Event.roomPacket, (packet) => _onRoomPacket(packet));
    on(Event.packet, (packet) => _onPacket(packet));
    on(Event.disconnecting, (reason) => {print('$tag disconnecting $reason')});
    on(Event.disconnect, (reason) => {print('$tag disconnect $reason')});
    on(Event.send, (data) => {print('$tag >> $data')});
    on(Event.pong, (time) => {print('$tag ping:$time ms')});
  }

  void _onOpen(InternetAddress address) {
    print('$tag open $address $state');
  }

  void _onHandshake(Packet packet) {
    print('$tag handshake $packet');
    if (packet.namespace == '/') {
      sendMessage(ConnectRequest('/home'));
    } else if (packet.namespace == '/home') {
      sendMessage(JoinRoomRequest('lobby', namespace: '/home'));
    }
  }

  void _onData(Uint8List data) {
    print('$tag data[${data.length}] $data ');
  }

  void _onRawData(Uint8List data) {
    print('Raw: $data');
  }

  void _onRoomPacket(RoomPacket packet) {
    if (packet.joinRoom && packet.roomName == 'lobby') {
      var msg = RoomEvent(packet.roomName!,
          namespace: '/home', event: 'hello', message: 'hello all');
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
    print('$tag close $state');
  }
}
