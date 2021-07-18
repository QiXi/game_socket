Socket library for creating real-time multiplayer games.

## Game socket
The library was published in early access and is not stable, as it is being developed in parallel with other solutions. English is not a native language so there are no comments. At this stage, the library is for those who want to understand the source code and get a starting point for their solution or help me :)


## Features
* One library contains both Server and Client parts.
* The API communication library is similar to `Socket.io`, but not compatible with this solution.
* Contains a built-in binary protocol so you don't have to work at the byte level.
* The transport layer uses `TCP`. To send game messages, it is planned to implement parallel work with `UDP`.
* It implements such concepts as Multiplexing - interaction with several spaces through a single channel.

Support for `WebSocket` is not planned for the current day (but everything can change with the support of the community)


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
    server = GameSocketServer(options: ServerOptions.byDefault()..supportRawData = true);
    home = server.of('/home');
    home.on(ServerEvent.connect, (data) => _onHomeConnect(data));
    home.on('hello', (packet) => _onHomeData(packet));
    //
    server.on(ServerEvent.connection, (socket) {
      print('/: connection $socket');
      socket.on(ServerEvent.connect, (data) => _onConnect(data[0], data[1]));
      socket.on(Event.disconnecting, (data) => _onDisconnecting(data));
      socket.on(Event.disconnect, (data) => _onDisconnect(data[0], data[1]));
      socket.on(Event.error, (data) => _onError(data));
      socket.on(Event.data, (data) => _onData(data));
      socket.on(Event.close, (data) => {_onClose(data)});
    });
    server.on(ServerEvent.error, (data) => {print('/: eventError $data')});
    server.on(ServerEvent.close, (data) => {print('/: serverClose $data')});
    server.on(ServerEvent.raw, (data) => {print('/: raw $data')});
    server.on(ServerEvent.createRoom, (data) => {print('/: createRoom $data')});
    server.on(ServerEvent.joinRoom, (data) => {print('/: joinRoom $data')});
    server.on(ServerEvent.leaveRoom, (data) => {print('/: leaveRoom $data')});
    server.on(ServerEvent.deleteRoom, (data) => {print('/: deleteRoom $data')});
  }

  void listen() {
    server.listen();
  }

  void _onHomeConnect(dynamic data) {
    print('/home: connect $data');
  }

  void _onHomeData(dynamic data) {
    print('/home: $data');
    if (data is RoomPacket && data.roomName != null) {
      home.broadcast(data, rooms: {data.roomName!});
    }
  }

  void _onConnect(String namespace, String socketId) {
    print('/: connect $socketId');
  }

  void _onDisconnecting(dynamic data) {
    print('/: disconnecting $data');
  }

  void _onDisconnect(String namespace, String reason) {
    print('$namespace: disconnect reason:$reason');
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
      var msg =
          RoomEvent(packet.roomName!, namespace: '/home', event: 'hello', message: 'hello all');
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
```

###### Server log
```
listen null Options{ port:3103 raw:true closeOnError:false }
/: connection GameClient{ 15466abe2006464e99b6c8b36f7f4ed8 ReadyState.open [137545126]}
/: createRoom 15466abe2006464e99b6c8b36f7f4ed8
/: joinRoom [15466abe2006464e99b6c8b36f7f4ed8, 15466abe2006464e99b6c8b36f7f4ed8]
Home: connect [/home, 15466abe2006464e99b6c8b36f7f4ed8]
```

###### Client log
```
open InternetAddress('127.0.0.1', IPv4) ReadyState.open
handshake Packet{[0.0 /], bit:516, bool:16, int:[0, 0, 60, 0, 0, 0], string:{3: 15466abe2006464e99b6c8b36f7f4ed8}}
>> Message{[/home] boolMask:4, int:[0, 0, 0, 0, 0, 0], string:{} null}
handshake Packet{[0.0 /home], bit:516, bool:16, int:[0, 0, 60, 0, 0, 0], string:{3: 15466abe2006464e99b6c8b36f7f4ed8}}
>> Message{[/home] boolMask:16, int:[0, 0, 0], string:{0: lobby} null}
>> Message{[/home] boolMask:512, int:[0, 0, 0], string:{0: lobby, 5: hello, 1: hello all} null}
```


## Tips for Beginners
* If you are developing a browser game, then you need a `WebSocket` solution.
* When designing a game for real-time communication, `UDP` should be preferred, since` TCP` will cause a delay in the event of packet loss.


## Plans
* Initialization for sending `UPD` diagrams.
* Automatic connections and reconnections.
* Expanding the possibilities for working with rooms.
* Conducting stress tests.


## History of creation
Sources that could have influenced the development of this work:

* https://jamesslocum.com/blog
* https://github.com/socketio/engine.io-server-java
* https://github.com/socketio/socket.io-server-java/
* https://github.com/Jerenaux/binary-protocol-example
* https://github.com/rikulo/socket.io-dart/

___
If you can suggest a translation better than automatic ᕙ(☉̃ₒ☉‶)ว just do it