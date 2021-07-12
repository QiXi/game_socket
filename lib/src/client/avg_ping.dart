class AvgPing {
  static double speed = 0.35;

  int _lastPing = 0;
  double _measurement = 0;

  int get lastPing => _lastPing;

  int get time => _measurement.toInt();

  void update(int value) {
    _lastPing = value;
    if (_measurement == 0) {
      _measurement = value.toDouble();
    } else {
      _measurement -= speed * (_measurement - value);
    }
  }
}
