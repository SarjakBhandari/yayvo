import 'package:flutter/material.dart';

class ReviewCard extends StatelessWidget {
  final String imageUrl;
  final List<Map<String, dynamic>> tags;
  final String reviewText;
  final String retailerName;
  final String retailerAvatar;

  const ReviewCard({
    super.key,
    required this.imageUrl,
    required this.tags,
    required this.reviewText,
    required this.retailerName,
    required this.retailerAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: Align(
        alignment: AlignmentGeometry.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // take only needed space
          children: [
            // Header: avatar + name + follow button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(retailerAvatar),
                    onBackgroundImageError: (_, __) {},
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      retailerName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: implement follow logic
                    },
                    child: const Text("Follow"),
                  ),
                ],
              ),
            ),

            // Post image
            Image.network(
              imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Image.asset(
                  "assets/images/person.png",
                  width: double.infinity,
                  fit: BoxFit.cover,
                );
              },
            ),

            // Tags + review text
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
                            Image.asset(tag["icon"], height: 16, width: 16),
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

            // Actions: like + save
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () {
                      // TODO: implement like logic
                    },
                  ),
                  const Text("0"), // static like count for now
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.bookmark_border),
                    onPressed: () {
                      // TODO: implement save logic
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
