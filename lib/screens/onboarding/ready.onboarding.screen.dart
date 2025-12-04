import 'package:flutter/material.dart';
import 'package:yayvo/widgets/my_button.dart';
import '../../widgets/my_review_card.dart';

class ReadyPage extends StatelessWidget {
  const ReadyPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy posts array using local icons
    final List<Map<String, dynamic>> posts = [
      {
        "imageUrl":
        "https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=400&h=300&fit=crop",
        "tags": [
          {"icon": "assets/icons/beauty.png", "label": "Beauty", "color": Colors.teal},
          {"icon": "assets/icons/dress.png", "label": "Fashion", "color": Colors.pink},
        ],
        "reviewText": "These makeups were a Lit!"
      },
      {
        "imageUrl":
        "https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400&h=300&fit=crop",
        "tags": [
          {"icon": "assets/icons/excited.png", "label": "Excite", "color": Colors.pink},
        ],
        "reviewText": "Can't wait to get this watch! The design is amazing..."
      },
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Icon(Icons.auto_awesome, size: 40, color: Colors.purple),
              const SizedBox(height: 12),
              const Text(
                "You're All Set!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                "Your personalized feed is ready",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 24),

              // Show posts from array
              Expanded(
                child: ListView.separated(
                  itemCount: posts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return ReviewCard(
                      imageUrl: post["imageUrl"],
                      tags: post["tags"],
                      reviewText: post["reviewText"],
                    );
                  },
                ),
              ),

              Row(
                children: [
                  Expanded(
                    child: MyButton(
                      onPressed: () {
                        Navigator.pop(context); // back action
                      },
                      text: "Back",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MyButton(
                      onPressed: () {
                        // TODO: Add navigation later
                      },
                      text: "Start Exploring",
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
