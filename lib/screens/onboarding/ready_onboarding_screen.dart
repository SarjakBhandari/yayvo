import 'package:flutter/material.dart';
import 'package:yayvo/screens/dashboard_screen.dart';
import 'package:yayvo/widgets/my_button.dart';
import '../../widgets/my_sentiment_card.dart';

class ReadyPage extends StatelessWidget {
  const ReadyPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy posts array adapted for SentimentCard
    final List<Map<String, dynamic>> posts = [
      {
        "id": "1",
        "imageUrl":
        "https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=600&h=600&fit=crop",
        "title": "Cozy Corner Café",
        "emotions": [
          {"emotion": "Calm", "emoji": "😌"},
          {"emotion": "Cozy", "emoji": "🏠"},
        ],
        "sentimentSummary":
        "The most calming atmosphere with ethically sourced beans. Every sip feels like a warm hug on a rainy day.",
        "retailerName": "Cozy Corner Café",
        "retailerAvatar":
        "https://images.unsplash.com/photo-1551218808-94e220e084d2?w=100&h=100&fit=crop",
        "likes": 12,
        "saved": false,
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
              const Icon(Icons.auto_awesome, size: 48, color: Colors.purple),
              const SizedBox(height: 16),
              const Text(
                "You're All Set!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Your personalized feed is ready",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),

              // Show posts from array
              Expanded(
                child: ListView.separated(
                  itemCount: posts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return SentimentCard(
                      id: post["id"],
                      imageUrl: post["imageUrl"],
                      title: post["title"],
                      retailerName: post["retailerName"],
                      retailerAvatar: post["retailerAvatar"],
                      emotions: List<Map<String, String>>.from(post["emotions"]),
                      sentimentSummary: post["sentimentSummary"],
                      likes: post["likes"],
                      saved: post["saved"],
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: MyButton(
                      onPressed: () => Navigator.pop(context),
                      text: "Back",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MyButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeFeed(),
                          ),
                        );
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

