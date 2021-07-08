import 'package:game_socket/src/engine/emitter.dart';
import 'package:test/test.dart';

void main() {
  group('Emitter', () {
    test('Emitter hasListeners', () {
      var emitter = Emitter();
      emitter.on('test1', (data) => null);
      emitter.once('test1', (data) => null);
      expect(emitter.hasListeners('test1'), true);
      expect(emitter.listeners('test1').length, 2);
    });

    test('Emitter off', () {
      var emitter = Emitter();
      emitter.once('test1', (data) => {});
      emitter.off('test1');
      expect(emitter.listeners('test1').length, 0);
    });

    test('Emitter emit', () {
      var emitter = Emitter();
      emitter.on('test1', (data) => {});
      emitter.once('test1', (data) => {});
      emitter.once('test1', (data) => {});
      emitter.emit('event');
      expect(emitter.listeners('test1').length, 3);
      emitter.emit('test1');
      expect(emitter.listeners('test1').length, 1);
    });
  });
}
