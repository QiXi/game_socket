import 'dart:io';

import 'package:uuid/uuid.dart';

import 'typedef.dart';

const _uuid = Uuid();

class Session {
  final InternetAddress address;
  final int port;
  final SocketId socketId;
  int readBytes = 0;
  int writtenBytes = 0;
  int readPackets = 0;
  int writtenPackets = 0;
  DateTime lastActivityTime;

  Session(this.address, this.port)
      : lastActivityTime = DateTime.now(),
        socketId = _uuid.v4().replaceAll('-', '');

  void addReadPacket() => readPackets++;

  void addWrittenPacket() => writtenPackets++;

  @override
  String toString() {
    return 'Session{ readBytes:$readBytes writtenBytes:$writtenBytes '
        'readPackets:$readPackets writtenPackets:$writtenPackets}';
  }
}
