import 'package:flutter/material.dart';
import 'package:yayvo/features/auth/presentation/pages/login_page.dart';
import 'package:yayvo/features/auth/presentation/pages/register_consumer_screen.dart';
import 'package:yayvo/features/auth/presentation/pages/register_retailer_screen.dart';
import 'package:yayvo/core/widgets/my_button.dart';
import 'package:yayvo/core/widgets/my_logo.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Access current theme

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              MyLogo(size: 150, radius: 40),
              const SizedBox(height: 30),

              // Headline text styled via theme
              Text(
                "Discover lifestyle through emotions.",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onBackground,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 15),

              // Subtitle text styled via theme
              Text(
                "Choose your role to get Started.",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 15,
                  color: theme.colorScheme.onBackground,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // Consumer button
              SizedBox(
                width: MediaQuery.of(context).size.width - 150,
                height: 45,
                child: MyButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ConsumerRegistrationScreen(),
                      ),
                    );
                  },
                  text: "I'm a Consumer",
                ),
              ),

              const SizedBox(height: 10),

              // Retailer button
              SizedBox(
                width: MediaQuery.of(context).size.width - 150,
                height: 45,
                child: MyButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RetailerRegistrationScreen(),
                      ),
                    );
                  },
                  text: "I'm a Retailer",
                ),
              ),

              const SizedBox(height: 20),

              // Login link styled via theme
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: RichText(
                  text: TextSpan(
                    text: "Already registered? ",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: theme.colorScheme.onBackground,
                    ),
                    children: [
                      TextSpan(
                        text: "Login",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}