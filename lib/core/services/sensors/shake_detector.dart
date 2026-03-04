import 'dart:async';

import 'package:sensors_plus/sensors_plus.dart';

/// Listens to accelerometer and invokes [onShake] when device is shaken.
class ShakeDetector {
  ShakeDetector({
    required this.onShake,
    this.thresholdGravity = 2.7,
    this.slopTimeMs = 500,
    this.minShakeCount = 1,
  });

  final void Function() onShake;
  final double thresholdGravity;
  final int slopTimeMs;
  final int minShakeCount;

  StreamSubscription<AccelerometerEvent>? _sub;
  int _shakeCount = 0;
  DateTime? _lastShakeTime;
  bool _listening = false;

  void startListening(Stream<AccelerometerEvent> accelerometerStream) {
    if (_listening) return;
    _listening = true;
    _sub = accelerometerStream.listen((event) {
      final magnitude = (event.x * event.x + event.y * event.y + event.z * event.z).abs();
      final force = magnitude / 10.0;
      if (force > thresholdGravity) {
        final now = DateTime.now();
        if (_lastShakeTime == null ||
            now.difference(_lastShakeTime!).inMilliseconds > slopTimeMs) {
          _shakeCount = 0;
        }
        _lastShakeTime = now;
        _shakeCount++;
        if (_shakeCount >= minShakeCount) {
          _shakeCount = 0;
          onShake();
        }
      }
    });
  }

  void stopListening() {
    _sub?.cancel();
    _sub = null;
    _listening = false;
  }
}
