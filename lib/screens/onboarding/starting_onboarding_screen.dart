import 'package:flutter/material.dart';
import 'package:yayvo/screens/onboarding/welcome_screen.dart';
import '../../widgets/onboarding.widget.dart';


class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _controller = PageController();

  int _currentPage = 0;

  final List<Map<String, String>> pages = [
    {
      "image": "assets/icons/house.png",
      "title": "Discover Lifestyle",
      "description": "Explore emotions through curated content and experiences."
    },
    {
      "image": "assets/icons/beauty.png",
      "title": "Personalized Feed",
      "description": "Get recommendations tailored to your mood and interests."
    },
    {
      "image": "assets/icons/joy.png",
      "title": "Connect & Share",
      "description": "Engage with communities and share your lifestyle stories."
    },
  ];

  void _nextPage() {
    if (_currentPage < pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _controller,
        itemCount: pages.length,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemBuilder: (context, index) {
          final page = pages[index];
          return OnboardingPage(
            imageAsset: page["image"]!,
            title: page["title"]!,
            description: page["description"]!,
            onNext: _nextPage,
          );
        },
      ),
    );
  }
}
