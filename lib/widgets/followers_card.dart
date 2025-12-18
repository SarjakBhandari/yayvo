import 'package:flutter/material.dart';
import 'package:yayvo/widgets/my_button.dart';

class FollowSuggestionCard extends StatelessWidget {
  final String id;
  final String name;
  final String type;
  final String? imageUrl;
  final bool isFollowing;
  final VoidCallback onToggleFollow;

  const FollowSuggestionCard({
    super.key,
    required this.id,
    required this.name,
    required this.type,
    required this.imageUrl,
    required this.isFollowing,
    required this.onToggleFollow,
  });

  Widget buildImage() {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Image.asset(
        "assets/images/person.png",
        width: 48,
        height: 48,
        fit: BoxFit.cover,
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Image.network(
        imageUrl!,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return Image.asset(
            "assets/images/person.png",
            width: 48,
            height: 48,
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      color: theme.cardColor, // ✅ themed card background
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            buildImage(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  Text(
                    type,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 36,
              child: MyButton(
                onPressed: onToggleFollow,
                text: isFollowing ? "Following" : "Follow",
              ),
            ),
          ],
        ),
      ),
    );
  }
}