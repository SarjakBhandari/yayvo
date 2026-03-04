import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proximity_sensor/proximity_sensor.dart';
import 'package:yayvo/core/providers/theme_provider.dart';

final proximityThemeChangerProvider = Provider<ProximityThemeChanger>((ref) {
  return ProximityThemeChanger(ref: ref);
});

/// Changes the theme based on proximity sensor events.
class ProximityThemeChanger {
  ProximityThemeChanger({required this.ref});

  final Ref ref;
  StreamSubscription<int>? _sub;
  bool _listening = false;
  int? _lastState;

  void startListening() {
    if (_listening) return;
    _listening = true;
    _sub = ProximitySensor.events.listen((event) {
      // event is 0 for far, 1 for near
      if (_lastState != 1 && event == 1) { // if it wasn't near, but now it is
        ref.read(themeModeProvider.notifier).toggleTheme();
      }
      _lastState = event;
    });
  }

  void stopListening() {
    _sub?.cancel();
    _sub = null;
    _listening = false;
  }
}
