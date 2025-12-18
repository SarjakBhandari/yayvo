import 'package:flutter/material.dart';
import 'package:yayvo/screens/notifications_screen.dart';

import '../../../common/show_my_snack_bar.dart';
import '../../../widgets/my_logo.dart';
import '../../../widgets/my_sentiment_card.dart';

class ConsumerHomeScreen extends StatelessWidget {
  const ConsumerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Dummy products
    final List<Map<String, dynamic>> mockProducts = [
      {
        "id": "1",
        "imageUrl":
        "https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=600&h=600&fit=crop",
        "title": "Cozy Beauty Café",
        "emotions": [
          {"emotion": "Calm", "icon": "assets/icons/calm.png"},
          {"emotion": "Cozy", "icon": "assets/icons/house.png"},
        ],
        "sentimentSummary": "The most calming atmosphere with good makeup.",
        "retailerName": "Cozy Beauty Café",
        "retailerAvatar":
        "https://images.unsplash.com/photo-1551218808-94e220e084d2?w=100&h=100&fit=crop",
        "likes": 5,
        "saved": false,
      },
      // Add more products here...
    ];

    // Dummy filters
    final List<Map<String, dynamic>> filters = [
      {"label": "Joy", "icon": "assets/icons/joy.png"},
      {"label": "Calm", "icon": "assets/icons/calm.png"},
      {"label": "Excite", "icon": "assets/icons/excited.png"},
      {"label": "Nostalgia", "icon": "assets/icons/nostalgic.png"},
      {"label": "Cozy", "icon": "assets/icons/house.png"},
    ];

    return SizedBox.expand(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                border: Border(
                  bottom: BorderSide(color: theme.dividerColor),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyLogo(size: 40, radius: 12),
                  IconButton(
                    icon: Icon(Icons.notifications,
                        color: theme.colorScheme.onBackground),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Filter buttons row
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filters.length,
                itemBuilder: (context, index) {
                  final filter = filters[index];
                  final iconPath = filter["icon"] ?? "";
                  final label = filter["label"] ?? "Unknown";

                  return GestureDetector(
                    onTap: () {
                      showMySnackBar(
                        context: context,
                        message: "Not implemented yet",
                        status: SnackBarStatus.warning,
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.chipTheme.backgroundColor ??
                            theme.colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          iconPath.isNotEmpty
                              ? Image.asset(iconPath, height: 20, width: 20)
                              : const Icon(Icons.sentiment_satisfied),
                          const SizedBox(width: 6),
                          Text(
                            label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onBackground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Feed (grid of SentimentCards)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: mockProducts.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 800 ? 2 : 1,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 0.62,
              ),
              itemBuilder: (context, index) {
                final product = mockProducts[index];

                return SentimentCard(
                  id: product["id"] ?? "",
                  imageUrl: product["imageUrl"] ?? "",
                  title: product["title"] ?? "Untitled",
                  retailerName: product["retailerName"] ?? "Unknown Retailer",
                  retailerAvatar: product["retailerAvatar"] ?? "",
                  emotions: product["emotions"] != null
                      ? List<Map<String, String>>.from(product["emotions"])
                      : const [],
                  sentimentSummary:
                  product["sentimentSummary"] ?? "No summary available",
                  likes: product["likes"] ?? 0,
                  saved: product["saved"] ?? false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}