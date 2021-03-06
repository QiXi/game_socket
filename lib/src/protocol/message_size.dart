import 'message.dart';
import 'protocol.dart';
import 'schema.dart';

int computeMessageSize(Message message, Schema schema) {
  var size = Protocol.bytesPerHeader;
  size += message.namespace.length;
  size += schema.bytesPerBoolMask + schema.bytesPerMask;
  var intCount = schema.intCount;
  if (intCount > 0) {
    for (var id = 0; id < intCount; id++) {
      if (message.containsInt(id)) {
        size += getSizeFromId(id, schema);
      }
    }
  }
  var stringsCount = schema.stringsCount;
  if (stringsCount > 0) {
    for (var id = 0; id < stringsCount; id++) {
      if (message.containsString(id)) {
        size += message.getString(id)!.length + 1;
      }
    }
  }
  if (schema.includedBytes && message.containsPayload()) {
    size += 2 + message.payloadBytes!.length;
  }
  return message.bytesPerMessage = size;
}

int getSizeFromId(int id, Schema schema) {
  return (id < schema.int8Count)
      ? 1
      : (id < schema.int8Count + schema.int16Count)
          ? 2
          : 4;
}
