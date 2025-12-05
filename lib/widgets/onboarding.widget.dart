import 'package:flutter/material.dart';
import 'package:yayvo/widgets/my_button.dart';

class OnboardingPage extends StatelessWidget {
  final String imageAsset;
  final String title;
  final String description;
  final VoidCallback onNext;

  const OnboardingPage({
    super.key,
    required this.imageAsset,
    required this.title,
    required this.description,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
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
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Text(
                description,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: MediaQuery.of(context).size.width - 150,
                height: 45,
                child: MyButton(
                  onPressed: onNext,
                  text: "Next",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
