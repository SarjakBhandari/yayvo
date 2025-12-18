import 'package:flutter/material.dart';
import 'package:yayvo/screens/onboarding/welcome_screen.dart';
import '../../widgets/onboarding.widget.dart';
import '../../widgets/my_button.dart';

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

  void _skip() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Skip button at top-right
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 16, right: 16),
              child: TextButton(
                onPressed: _skip,
                child: Text(
                  "Skip",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: PageView.builder(
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
                );
              },
            ),
          ),

          // Page indicator
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                    (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 16 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),

          // Next / Get Started button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: SizedBox(
              width: double.infinity,
              height: 45,
              child: MyButton(
                onPressed: _nextPage,
                text: _currentPage == pages.length - 1 ? "Get Started" : "Next",
              ),
            ),
          ),
        ],
      ),
    );
  }
}