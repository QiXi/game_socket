import '../message.dart';
import 'game_socket_schema.dart';

typedef GSM = GameSocketMessage;

class GameSocketMessage extends Message {
  GameSocketMessage(String namespace) : super(GameSocketSchema()) {
    this.namespace = namespace;
  }
}

class ErrorMessage extends GameSocketMessage {
  ErrorMessage(int code, String message, {String namespace = '/', String? data})
      : super(namespace) {
    enable(GSS.error);
    putInt(GSS.errorCode, code);
    putString(GSS.errorMessage, message);
    if (data != null) {
      putString(GSS.data, data);
    }
  }

  @override
  String toString() {
    return 'Error{ ${getInt(GSS.errorCode)} ${getString(GSS.errorMessage)}}';
  }
}

class ClientDisconnectionReason {
  static const String unknown = 'unknown';
  static const String normal = 'normal';
  static const String idle = 'idle';
}
