import 'package:flutter/material.dart';
import 'package:yayvo/screens/onboarding/ready_onboarding_screen.dart';
import 'package:yayvo/widgets/my_button.dart';

import '../../widgets/followers_card.dart';

class FollowSuggestionsScreen extends StatefulWidget {
  const FollowSuggestionsScreen({super.key});

  @override
  State<FollowSuggestionsScreen> createState() => _FollowSuggestionsScreenState();
}

class _FollowSuggestionsScreenState extends State<FollowSuggestionsScreen> {

  //sample
  final List<Map<String, String>> suggestions = [
    {
      "id": "1",
      "name": "Minimal Living Co.",
      "type": "Retailer",
      "image": "https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=200&h=200&fit=crop"
    },
    {
      "id": "2",
      "name": "Urban Wellness",
      "type": "Consumer",
      "image": "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&h=200&fit=crop"
    },

  ];

  final List<String> following = [];

  void toggleFollow(String id) {
    setState(() {
      if (following.contains(id)) {
        following.remove(id);
      } else {
        following.add(id);
      }
    });
  }

  void handleNext() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ReadyPage(),
      ),
    );
  }

  void handleBack() {
    Navigator.pop(context);
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
                      "Follow & Connect",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Discover retailers and consumers",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: ListView.separated(
                        itemCount: suggestions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final suggestion = suggestions[index];
                          final isFollowing = following.contains(suggestion["id"]);
                          return FollowSuggestionCard(
                            id: suggestion["id"]!,
                            name: suggestion["name"]!,
                            type: suggestion["type"]!,
                            imageUrl: suggestion["image"],
                            isFollowing: isFollowing,
                            onToggleFollow: () => toggleFollow(suggestion["id"]!),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: MyButton(
                      onPressed: handleBack,
                      text: "Back",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MyButton(
                      onPressed: handleNext,
                      text: "Next",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
