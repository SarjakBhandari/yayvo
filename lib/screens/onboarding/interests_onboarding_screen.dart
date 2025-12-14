import 'package:flutter/material.dart';
import 'package:yayvo/screens/onboarding/emotions_onboarding_screen.dart';
import 'package:yayvo/widgets/my_button.dart';

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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "What are you into?",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Select your lifestyle interests",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                        itemCount: interests.length,
                        itemBuilder: (context, index) {
                          final interest = interests[index];
                          final isSelected = interestsSelected.contains(interest["name"]);
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
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey.shade300,
                                  width: 2,
                                ),
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                                    : Theme.of(context).cardColor,
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
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isSelected
                                          ? Theme.of(context).colorScheme.primary
                                          : Colors.grey.shade800,
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
                  onPressed: (){
                    setState(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EmotionPreferencesScreen(),
                        ),
                      );
                    });
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
