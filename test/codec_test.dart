import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:game_socket/client.dart';
import 'package:game_socket/protocol.dart';
import 'package:test/test.dart';

void main() {
  group('MessageEncoder', () {
    test('computeMessageSize', () {
      var size = computeMessageSize(GameSocketMessage('/'), GameSocketSchema());
      expect(size, 9);
    });

    test('insertInt', () {
      var codec = MessageEncoder();
      var offset = 0;
      var buffer = Uint8List(10);
      offset = codec.insertInt(buffer, offset, 1, 255);
      expect(offset, 1);
      offset = codec.insertInt(buffer, offset, 2, 259);
      expect(offset, 3);
      offset = codec.insertInt(buffer, offset, 4, 2031363336);
      expect(offset, 7);
      print(buffer);
      expect(buffer, [255, 1, 3, 121, 20, 37, 8, 0, 0, 0]);
    });

    test('insertString', () {
      var codec = MessageEncoder();
      var buffer = Uint8List(15);
      var offset = codec.insertString(buffer, 1, 'test');
      expect(offset, 6);
      expect(String.fromCharCodes(buffer, 2, 6), 'test');
    });

    test('insertUtf8String', () {
      var codec = MessageEncoder();
      var buffer = Uint8List(15);
      var offset = codec.insertUtf8String(buffer, 1, 'тест');
      expect(offset, 10);
      expect(Utf8Decoder().convert(buffer, 2, 10), 'тест');
    });

    test('encode', () {
      var codec = MessageEncoder();
      Message message = GameSocketMessage('/')
        ..enable(GameSocketSchema.utf8)
        ..putInt(GameSocketSchema.value, -2);
      Schema schema = GameSocketSchema();
      var buffer = codec.encode(message, schema);
      print('$buffer');
      print('$message');
      expect(message.getInt(GameSocketSchema.value), -2);
      expect(message.getUInt(GameSocketSchema.value), 3);
      expect(buffer, [126, 0, 46, 0, 1, 47, 4, 0, 2, 3]);
    });

    test('encode binary', () {
      var codec = MessageEncoder();
      Message message = RoomMessage('/', 'main')..payloadBytes = Uint8List.fromList([1, 2, 3]);
      Schema schema = RoomSchema();
      var buffer = codec.encode(message, schema);
      print('$buffer');
      print('$message');
      expect(buffer, [126, 1, 46, 0, 1, 47, 0, 65, 0, 0, 4, 109, 97, 105, 110, 0, 3, 1, 2, 3]);
    });
  });

  group('MessageDecoder', () {
    test('extractInt', () {
      var codec = PacketDecoder();
      var buffer = Uint8List.fromList([255, 1, 3, 121, 20, 37, 8, 0, 0, 0]);
      expect(codec.extractInt(buffer, 0, 1), 255);
      expect(codec.extractInt(buffer, 1, 2), 259);
      expect(codec.extractInt(buffer, 3, 4), 2031363336);
    });

    test('extractString', () {
      var codec = PacketDecoder();
      var buffer = Uint8List.fromList([14, 64, 0, 3, 103, 115, 115, 1, 47, 0]);
      var schemaName = codec.extractString(buffer, 4, 3);
      expect(schemaName, 'gss');
    });

    test('decode', () {
      var codec = PacketDecoder();
      Schema schema = GameSocketSchema();
      var buffer = Uint8List.fromList([126, 0, 46, 0, 1, 47, 4, 0, 2, 3]);
      var packet = Packet(schema);
      codec.decode(packet, buffer, 0);
      print('$schema');
      print('$packet');
      expect(packet.schemaCode, 0);
      expect(packet.schemaVersion, 0);
      expect(packet.getInt(GameSocketSchema.value), -2);
      expect(packet.getBool(GameSocketSchema.utf8), true);
      expect(packet.namespace, '/');
      expect(packet.containsPayload(), false);
    });

    test('decode binary', () {
      var codec = PacketDecoder();
      Schema schema = RoomSchema();
      var buffer = Uint8List.fromList([126, 1, 46, 0, 1, 47, 0, 65, 0, 0, 4, 109, 97, 105, 110, 0, 3, 1, 2, 3]);
      var packet = Packet(schema);
      codec.decode(packet, buffer, 0);
      print('$schema');
      print('$packet');
      expect(packet.payloadBytes, [1, 2, 3]);
      expect(packet.namespace, '/');
      expect(packet.containsPayload(), true);
    });
  });

  group('ConnectMessage', () {
    test('encode', () {
      var codec = MessageEncoder();
      var message = ConnectRequest('/home');
      Schema schema = GameSocketSchema();
      var buffer = codec.encode(message, schema);
      print(message);
      print(buffer);
      expect(buffer, [126, 0, 46, 0, 5, 47, 104, 111, 109, 101, 0, 0, 4]);
    });

    test('decode', () {
      var codec = PacketDecoder();
      Schema schema = GameSocketSchema();
      var buffer = Uint8List.fromList([126, 0, 46, 0, 5, 47, 104, 111, 109, 101, 0, 0, 4]);
      var packet = Packet(schema);
      codec.decode(packet, buffer, 0);
      print('$schema');
      print('$packet');
      expect(packet.getBool(GameSocketSchema.connect), true);
      expect(packet.namespace, '/home');
    });
  });

  group('other', () {
    test('Message', () {
      Schema schema = GameSocketSchema();
      var message = Message(schema);
      message.enable(GameSocketSchema.connect);
      print('$schema');
      expect(message.boolMask, 4);
      message.enable(GameSocketSchema.utf8);
      expect(message.boolMask, 6);
      message.disable(GameSocketSchema.utf8);
      expect(message.boolMask, 4);
    });

    test('bytesPerBoolList', () {
      Schema schema = GameSocketSchema();
      expect(schema.bytesPerBoolMask, 1);
    });

    test('maxProperties', () {
      Schema schema = GameSocketSchema();
      expect(schema.maxProperties, 12);
    });

    test('zigzagEncode', () {
      var z = ZigZagTest();
      expect(z.zigzagEncode(-2), 3);
      expect(z.zigzagEncode(128), 256);
      expect(z.zigzagEncode(-256), 511);
    });

    test('zigzagDecode', () {
      var zigzag = ZigZagTest();
      expect(zigzag.zigzagDecode(3), -2);
      expect(zigzag.zigzagDecode(256), 128);
      expect(zigzag.zigzagDecode(511), -256);
    });

    test('radians', () {
      Schema schema = GameSocketSchema();
      var message = Message(schema)
        ..putRadians(0, pi * 2)
        ..putRadians(1, pi / 2)
        ..putRadians(2, -pi);
      print(message);
      message.enable(GameSocketSchema.connect);
      print([message.getRadians(0), message.getRadians(1), message.getRadians(2)]);
      expect(message.getRadians(0), pi * 2);
      expect(message.getRadians(1), pi / 2);
      expect(message.getRadians(2), -pi);
    });
  });
}

class ZigZagTest with ZigZag {}
