Socket library for creating real-time multiplayer games.

## Usage

Server:

```dart
import 'package:game_socket/server.dart';

void main() {
  var service = SocketServiceExample();
  service.listen();
}

class SocketServiceExample {
  late GameSocketServer server;
  late Namespace home;

  SocketServiceExample() {
    server = GameSocketServer(
        options: ServerOptions.byDefault()..supportRawData = true);
    home = server.of('/home');
    home.on(ServerEvent.connect, (data) => _onHomeConnect(data));
    home.on('hello', (packet) => _onHomeData(packet));
    //
    server.on(ServerEvent.connection, (socket) {
      print('/: connection $socket');
      socket.on(ServerEvent.connect, (data) => _onConnect(data[0], data[1]));
      socket.on(Event.disconnecting, (data) => _onDisconnecting(data));
      socket.on(Event.disconnect, (data) => _onDisconnect(data));
      socket.on(Event.error, (data) => _onError(data));
      socket.on(Event.data, (data) => _onData(data));
      socket.on(Event.close, (data) => {_onClose(data)});
    });
    server.on(ServerEvent.error, (data) => {print('/: eventError $data')});
    server.on(ServerEvent.close, (data) => {print('/: serverClose $data')});
    server.on(
        ServerEvent.createRoom, (data) => {print('/: createRoom: $data')});
    server.on(ServerEvent.joinRoom, (data) => {print('/: joinRoom $data')});
    server.on(ServerEvent.leaveRoom, (data) => {print('/: leaveRoom $data')});
    server.on(ServerEvent.deleteRoom, (data) => {print('/: deleteRoom $data')});
  }

  void listen() {
    server.listen();
  }

  void _onHomeConnect(dynamic data) {
    print('Home: connect $data');
  }

  void _onHomeData(dynamic data) {
    print('Home: $data');
    if (data is RoomPacket && data.roomName != null) {
      home.broadcast(data, rooms: {data.roomName!});
    }
  }

  void _onConnect(String namespace, String socketId) {
    print('/: connect $socketId ');
  }

  void _onDisconnecting(dynamic data) {
    print('/: disconnecting $data ');
  }

  void _onDisconnect(dynamic data) {
    print('/: disconnect $data ');
  }

  void _onError(dynamic data) {
    print('/: error $data');
  }

  void _onData(dynamic data) {
    print('/: $data');
  }

  void _onClose(dynamic data) {
    print('/: close $data');
  }
}
```

Client:

```dart
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
    on(Event.error, (error) => _onError(error));
    on(Event.closing, (_) => {print('$tag closing')});
    on(Event.close, (_) => _onClose());
    on(Event.roomPacket, (packet) => _onRoomPacket(packet));
    on(Event.packet, (packet) => _onPacket(packet));
    on(Event.disconnecting, (reason) => {print('$tag disconnecting $reason')});
    on(Event.disconnect, (reason) => {print('$tag disconnect $reason')});
    on(Event.send, (data) => {print('$tag >> $data')});
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
```

### Server log
```
listen null Options{ port:3103 raw:true closeOnError:false }
/: connection GameClient{ 15466abe2006464e99b6c8b36f7f4ed8 ReadyState.open [137545126]}
/: createRoom: 15466abe2006464e99b6c8b36f7f4ed8
/: joinRoom [15466abe2006464e99b6c8b36f7f4ed8, 15466abe2006464e99b6c8b36f7f4ed8]
Home: connect [/home, 15466abe2006464e99b6c8b36f7f4ed8]
```

### Client log
```
Example: open InternetAddress('127.0.0.1', IPv4) ReadyState.open
Example: handshake Packet{[0.0 /], bit:516, bool:16, int:[0, 0, 60, 0, 0, 0], string:{3: 15466abe2006464e99b6c8b36f7f4ed8}}
Example: >> Message{[/home] boolMask:4, int:[0, 0, 0, 0, 0, 0], string:{} null}
Example: handshake Packet{[0.0 /home], bit:516, bool:16, int:[0, 0, 60, 0, 0, 0], string:{3: 15466abe2006464e99b6c8b36f7f4ed8}}
Example: >> Message{[/home] boolMask:16, int:[0, 0, 0], string:{0: lobby} null}
Example: >> Message{[/home] boolMask:512, int:[0, 0, 0], string:{0: lobby, 5: hello, 1: hello all} null}
```


## History of creation

Sources that could have influenced the development of this work:

- https://jamesslocum.com/blog
- https://github.com/socketio/engine.io-server-java
- https://github.com/socketio/socket.io-server-java/
- https://github.com/Jerenaux/binary-protocol-example
- https://github.com/rikulo/socket.io-dart/