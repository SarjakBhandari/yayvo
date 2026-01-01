import 'package:flutter/material.dart';
import 'package:yayvo/screens/onboarding/emotions_onboarding_screen.dart';
import 'package:yayvo/core/widgets/my_button.dart';

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  final List<Map<String, String>> interests = [
    {"name": "Fashion", "icon": "assets/icons/dress.png"},
    {"name": "Wellness", "icon": "assets/icons/meditation.png"},
    {"name": "Travel", "icon": "assets/icons/travel.png"},
    {"name": "Tech", "icon": "assets/icons/computer.png"},
    {"name": "Food", "icon": "assets/icons/salad.png"},
    {"name": "Fitness", "icon": "assets/icons/fitness.png"},
    {"name": "Home", "icon": "assets/icons/house.png"},
    {"name": "Beauty", "icon": "assets/icons/beauty.png"},
    {"name": "Art", "icon": "assets/icons/art.png"},
  ];

  final List<String> interestsSelected = [];

  void toggleInterest(String interest) {
    setState(() {
      if (interestsSelected.contains(interest)) {
        interestsSelected.remove(interest);
      } else {
        interestsSelected.add(interest);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "What are you into?",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Select your lifestyle interests",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                        itemCount: interests.length,
                        itemBuilder: (context, index) {
                          final interest = interests[index];
                          final isSelected =
                          interestsSelected.contains(interest["name"]);
                          return GestureDetector(
                            onTap: () => toggleInterest(interest["name"]!),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.dividerColor,
                                  width: 2,
                                ),
                                color: isSelected
                                    ? theme.colorScheme.primary.withOpacity(0.1)
                                    : theme.cardColor,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    interest["icon"]!,
                                    height: 40,
                                    width: 40,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    interest["name"]!,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 14,
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: MyButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const EmotionPreferencesScreen(),
                      ),
                    );
                  },
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