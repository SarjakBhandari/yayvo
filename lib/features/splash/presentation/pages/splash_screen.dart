import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yayvo/features/onboarding/presentation/pages/starting_onboarding_screen.dart';
import 'package:yayvo/core/widgets/my_logo.dart';
import 'package:yayvo/screens/consumer/dashboard_screen.dart';
import 'package:yayvo/screens/consumer/dashboard_screens/consumer_home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // wait for splash duration
    await Future.delayed(const Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeFeed()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingFlow()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyLogo(size: 150, radius: 40),
            const SizedBox(height: 20),
            Text(
              "YAYVO",
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 10),
            CircularProgressIndicator(color: theme.colorScheme.secondary),
          ],
        ),
      ),
    );
  }
}