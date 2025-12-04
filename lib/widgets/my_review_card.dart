import 'package:flutter/material.dart';

class ReviewCard extends StatelessWidget {
  final String imageUrl; // main post image
  final List<Map<String, dynamic>> tags;
  // Example: [{ "icon": "assets/icons/calm.png", "label": "Calm", "color": Colors.teal }]
  final String reviewText;

  const ReviewCard({
    super.key,
    required this.imageUrl,
    required this.tags,
    required this.reviewText,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            imageUrl,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return Image.asset(
                "assets/images/person.png",
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  children: tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [tag["color"], tag["color"].withOpacity(0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            tag["icon"],
                            height: 16,
                            width: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            tag["label"],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Text(
                  reviewText,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
