typedef EventHandler<T> = dynamic Function(T? data);

class Emitter<T> {
  Emitter();

  final Map<String, List<EventHandler<T>>> _events = {};
  final List<Function> _off = [];

  void on(String event, EventHandler<T> handler) {
    _events.putIfAbsent(event, () => <EventHandler>[]);
    _events[event]!.add(handler);
  }

  void once(String event, EventHandler<T> handler) {
    _events.putIfAbsent(event, () => <EventHandler>[]);
    var onceHandler;
    onceHandler = (data) => {off(event, onceHandler), handler.call(data)};
    _events[event]!.add(onceHandler);
  }

  void off(String event, [EventHandler<T>? handler]) {
    if (handler != null) {
      var handlers = _events[event];
      if (handlers != null) {
        (handlers.length == 1) ? _events.remove(event) : _off.add(handler);
      }
    } else {
      _events.remove(event);
    }
  }

  void offAll() {
    _events.clear();
  }

  void emit(String event, [T? data]) {
    var handlers = _events[event];
    if (handlers != null) {
      for (var handler in handlers) {
        handler(data);
      }
      // remove once
      handlers.removeWhere((element) => _off.contains(element));
      _off.clear();
    }
  }

  List<EventHandler<T>> listeners(String event) {
    return _events[event] ?? <EventHandler>[];
  }

  bool hasListeners(String event) {
    return _events[event]?.isNotEmpty == true;
  }

  @override
  String toString() {
    return 'Emitter{${_events.keys} [$hashCode]}';
  }
}
