import 'package:flutter/material.dart';
import 'package:yayvo/screens/onboarding/starting_onboarding_screen.dart';
import 'package:yayvo/core/widgets/my_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingFlow()),
      );
    });
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

            CircularProgressIndicator(
              color: theme.colorScheme.secondary,
            ),
          ],
        ),
      ),
    );
  }
}