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
