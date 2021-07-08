import 'message.dart';
import 'schema.dart';

class Packet extends Message {
  late int schemaCode;
  late int schemaVersion;
  int? bitMask;

  Packet(Schema schema) : super(schema);

  @override
  String toString() {
    return 'Packet{[$schemaCode.$schemaVersion $namespace], bit:$bitMask, bool:$boolMask, int:$intList, string:$stringList}';
  }
}
