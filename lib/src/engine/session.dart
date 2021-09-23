class Session {
  int readBytes = 0;
  int writtenBytes = 0;
  int readPackets = 0;
  int writtenPackets = 0;

  void addReadPacket() => readPackets++;

  void addWrittenPacket() => writtenPackets++;

  @override
  String toString() {
    return 'Session{ readBytes:$readBytes writtenBytes:$writtenBytes '
        'readPackets:$readPackets writtenPackets:$writtenPackets}';
  }
}
