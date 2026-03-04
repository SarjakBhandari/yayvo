import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

final sensorServiceProvider = Provider<SensorService>((ref) {
  return SensorService();
});

/// Service exposing accelerometer, gyroscope, and magnetometer streams (3 sensors).
class SensorService {
  Stream<AccelerometerEvent> get accelerometer =>
      accelerometerEventStream();

  Stream<GyroscopeEvent> get gyroscope => gyroscopeEventStream();

  Stream<MagnetometerEvent> get magnetometer =>
      magnetometerEventStream();
}
