import 'package:flutter/material.dart';

class SentimentCard extends StatefulWidget {
  final String id;
  final String imageUrl;
  final String title;
  final String retailerName;
  final String retailerAvatar;
  final List<Map<String, String>> emotions; // {emotion, icon}
  final String sentimentSummary;
  final int likes;
  final bool saved;

  const SentimentCard({
    super.key,
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.retailerName,
    required this.retailerAvatar,
    required this.emotions,
    required this.sentimentSummary,
    this.likes = 0,
    this.saved = false,
  });

  @override
  State<SentimentCard> createState() => _SentimentCardState();
}

class _SentimentCardState extends State<SentimentCard> {
  late bool isSaved;
  late bool isLiked;
  late int likeCount;

  @override
  void initState() {
    super.initState();
    isSaved = widget.saved;
    isLiked = false;
    likeCount = widget.likes;
  }

  void handleSave() {
    setState(() {
      isSaved = !isSaved;
    });
  }

  void handleLike() {
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });
  }

  void handleShare() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Share functionality not implemented yet")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with save button
          Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: 200,
                child: Image.network(
                  widget.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.asset(
                    "assets/images/dress.png",
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: handleSave,
                  icon: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: isSaved
                        ? theme.colorScheme.primary
                        : theme.iconTheme.color ?? Colors.grey,
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      theme.colorScheme.surface.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Retailer info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(widget.retailerAvatar),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.retailerName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
              ],
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              widget.title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onBackground,
              ),
            ),
          ),

          // Emotions with asset icons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: widget.emotions.map((e) {
                return Chip(
                  avatar: Image.asset(
                    e["icon"]!, // <-- use "icon" consistently
                    height: 20,
                    width: 20,
                    fit: BoxFit.contain,
                  ),
                  label: Text(e["emotion"]!),
                  backgroundColor: theme.colorScheme.surfaceVariant,
                  labelStyle: theme.textTheme.bodySmall,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
          ),

          // Sentiment summary
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              widget.sentimentSummary,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              softWrap: true,
            ),
          ),

          // Actions: like + share
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: handleLike,
                  icon: Icon(
                    Icons.favorite,
                    color: isLiked ? Colors.red : theme.iconTheme.color ?? Colors.grey,
                  ),
                  label: Text("$likeCount",
                      style: theme.textTheme.bodyMedium),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: handleShare,
                  icon: Icon(Icons.share,
                      color: theme.colorScheme.secondary),
                  label: Text("Share",
                      style: theme.textTheme.bodyMedium),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}