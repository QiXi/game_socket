class SocketStat {
  int readBytes = 0;
  int writtenBytes = 0;
  int _readPackets = 0;
  int _writtenPackets = 0;

  int get readPackets => _readPackets;

  int get writtenPackets => _writtenPackets;

  void addReadPacket() => _readPackets++;

  void addWrittenPacket() => _writtenPackets++;

  @override
  String toString() {
    return 'readBytes:$readBytes writtenBytes:$writtenBytes '
        'readPackets:$_readPackets writtenPackets:$_writtenPackets';
  }
}
