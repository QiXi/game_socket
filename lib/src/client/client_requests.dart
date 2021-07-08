import '../protocol/socket/game_socket_message.dart';
import '../protocol/socket/game_socket_schema.dart';

class ConnectRequest extends GameSocketMessage {
  ConnectRequest(String namespace, {String? data}) : super(namespace) {
    enable(GSS.connect);
    if (data != null) {
      putString(GSS.data, data);
    }
  }
}

class DisconnectRequest extends GameSocketMessage {
  DisconnectRequest(String namespace, {String? message}) : super(namespace) {
    enable(GSS.disconnect);
    if (message != null) {
      putString(GSS.message, message);
    }
  }
}
