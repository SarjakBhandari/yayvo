import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  final String imageAsset;
  final String title;
  final String description;

  const OnboardingPage({
    super.key,
    required this.imageAsset,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              imageAsset,
              height: 250,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 30),

            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 15),

            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}