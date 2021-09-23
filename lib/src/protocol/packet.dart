import 'message.dart';
import 'schema.dart';

class Packet extends Message {
  int? schemaCode;
  int? schemaVersion;
  int? bitMask;

  Packet(Schema schema) : super(schema);

  @override
  String toString() {
    return 'Packet{~$schemaCode.$schemaVersion $namespace '
        'bit:$bitMask boolMask:$boolMask int:$intList string:$stringList ${payloadBytes ?? ''}}';
  }
}
