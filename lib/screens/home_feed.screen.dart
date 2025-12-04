import 'package:flutter/material.dart';
import 'package:yayvo/widgets/my_logo.dart';
import 'package:yayvo/widgets/my_review_card.dart';
import '../widgets/my_bottom_nav.dart';
import '../common/show_my_snack_bar.dart';

class HomeFeed extends StatefulWidget {
  const HomeFeed({super.key});

  @override
  State<HomeFeed> createState() => _HomeFeedState();
}

class _HomeFeedState extends State<HomeFeed> {
  int _selectedIndex = 0;

  // Single dummy product
  final List<Map<String, dynamic>> mockProducts = [
    {
      "id": "1",
      "imageUrl":
      "https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=600&h=600&fit=crop",
      "tags": [
        {"icon": "assets/icons/calm.png", "label": "Calm", "color": Colors.teal},
        {"icon": "assets/icons/house.png", "label": "Cozy", "color": Colors.orange},
      ],
      "reviewText": "The most calming atmosphere with good makeup.",
      "retailerName": "Cozy Beauty Café",
      "retailerAvatar":
      "https://images.unsplash.com/photo-1551218808-94e220e084d2?w=100&h=100&fit=crop",
    },
  ];

  // Dummy filters
  final List<Map<String, dynamic>> filters = [
    {"label": "Joy", "icon": "assets/icons/joy.png"},
    {"label": "Calm", "icon": "assets/icons/calm.png"},
    {"label": "Excite", "icon": "assets/icons/excited.png"},
    {"label": "Nostalgia", "icon": "assets/icons/nostalgic.png"},
    {"label": "Cozy", "icon": "assets/icons/house.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: BottomNav(
        currentIndex: _selectedIndex,
        onHomeTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyLogo(size: 40, radius: 12),
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      // TODO: Navigate to notifications later
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Image.asset(filter["icon"], height: 20, width: 20),
                          const SizedBox(width: 6),
                          Text(
                            filter["label"],
                            style: TextStyle(color: Colors.grey.shade800),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Feed (vertical list of cards)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: mockProducts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final product = mockProducts[index];
                return ReviewCard(
                  imageUrl: product["imageUrl"],
                  tags: product["tags"],
                  reviewText: product["reviewText"],
                  retailerName: product["retailerName"],
                  retailerAvatar: product["retailerAvatar"],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
