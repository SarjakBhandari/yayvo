import 'package:flutter/material.dart';
import 'package:yayvo/screens/consumer/dashboard_screen.dart';
import 'package:yayvo/screens/onboarding/welcome_screen.dart';
import 'package:yayvo/screens/splash_screen.dart';


class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: SplashScreen());
  }
}
