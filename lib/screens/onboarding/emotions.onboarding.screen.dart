import 'package:flutter/material.dart';
import 'package:yayvo/screens/onboarding/follower.onboarding.screen.dart';
import 'package:yayvo/widgets/my_button.dart';

class EmotionPreferencesScreen extends StatefulWidget {
  const EmotionPreferencesScreen({super.key});

  @override
  State<EmotionPreferencesScreen> createState() => _EmotionPreferencesScreenState();
}

class _EmotionPreferencesScreenState extends State<EmotionPreferencesScreen> {
  final List<Map<String, String>> emotions = [
    {"name": "Joy", "icon": "assets/icons/joy.png"},
    {"name": "Calm", "icon": "assets/icons/calm.png"},
    {"name": "Excitement", "icon": "assets/icons/excited.png"},
    {"name": "Nostalgia", "icon": "assets/icons/nostalgic.png"},
    {"name": "Minimalist", "icon": "assets/icons/minimalistic.png"},
  ];

  final List<String> emotionPreferences = [];

  void toggleEmotion(String emotion) {
    setState(() {
      if (emotionPreferences.contains(emotion)) {
        // remove if already selected
        emotionPreferences.remove(emotion);
      } else {
        // add to end of list (priority order)
        emotionPreferences.add(emotion);
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
                      "What speaks to you?",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Choose your emotional preferences in priority order",
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
                        itemCount: emotions.length,
                        itemBuilder: (context, index) {
                          final emotion = emotions[index];
                          final name = emotion["name"]!;
                          final iconPath = emotion["icon"]!;
                          final isSelected = emotionPreferences.contains(name);
                          final priorityIndex = emotionPreferences.indexOf(name);

                          return GestureDetector(
                            onTap: () => toggleEmotion(name),
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
                                    iconPath,
                                    height: 40,
                                    width: 40,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isSelected
                                          ? Theme.of(context).colorScheme.primary
                                          : Colors.grey.shade800,
                                    ),
                                  ),
                                  if (isSelected)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        "Priority ${priorityIndex + 1}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
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
                          builder: (context) => const FollowSuggestionsScreen(),
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
