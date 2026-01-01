import 'package:flutter/material.dart';

import '../../../models/product_model.dart';
import '../../../models/sentiment_model.dart';

// Sample data
final trendingProducts = [
  Product(
    id: '2',
    image:
    'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=600&h=600&fit=crop',
    title: 'Minimalist Smart Watch',
    retailerName: 'Tech Vibes',
    retailerAvatar:
    'https://images.unsplash.com/photo-1531297484001-80022131f5a1?w=100&h=100&fit=crop',
    emotions: [
      Sentiment(emotion: 'Excite'),
      Sentiment(emotion: 'Minimalist'),
    ],
    sentimentSummary:
    'Clean design that sparks joy. The interface is so intuitive, wearing it feels effortless and exciting.',
    likes: 567,
  ),
  Product(
    id: '3',
    image:
    'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=600&h=600&fit=crop',
    title: 'Scandinavian Home Decor',
    retailerName: 'Minimal Living Co.',
    retailerAvatar:
    'https://images.unsplash.com/photo-1600607687644-aac4c3eac7f4?w=100&h=100&fit=crop',
    emotions: [
      Sentiment(emotion: 'Calm', ),
      Sentiment(emotion: 'Minimalist'),
    ],
    sentimentSummary:
    'Transformed my space into a serene sanctuary. The textures and tones bring such peaceful energy.',
    likes: 892,
  ),
];

final newProducts = [
  Product(
    id: '7',
    image:
    'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600&h=600&fit=crop',
    title: 'Wireless Headphones',
    retailerName: 'Audio Collective',
    retailerAvatar:
    'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop',
    emotions: [
      Sentiment(emotion: 'Joy', ),
      Sentiment(emotion: 'Excite', ),
    ],
    sentimentSummary:
    'The sound quality is incredible! Feels like being in a concert hall. Pure audio bliss.',
    likes: 234,
  ),
  Product(
    id: '8',
    image:
    'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600&h=600&fit=crop',
    title: 'Running Sneakers',
    retailerName: 'Athletic Gear',
    retailerAvatar:
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop',
    emotions: [
      Sentiment(emotion: 'Excite', ),
    ],
    sentimentSummary:
    'These make me want to run every morning! Comfortable, stylish, and energizing.',
    likes: 445,
  ),
];

// SentimentCard widget
class SentimentCard extends StatelessWidget {
  final Product product;

  const SentimentCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(product.image, height: 180, fit: BoxFit.cover),
            ),
            const SizedBox(height: 8),
            // Title
            Text(product.title,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            // Retailer info
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(product.retailerAvatar),
                  radius: 14,
                ),
                const SizedBox(width: 8),
                Text(product.retailerName,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 8),
            // Emotions with icons
            Row(
              children: product.emotions
                  .map((e) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Column(
                  children: [
                    Image.asset(e.iconPath, width: 24, height: 24),
                    Text(e.emotion,
                        style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
              ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            // Sentiment summary
            Text(product.sentimentSummary,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            // Likes
            Row(
              children: [
                const Icon(Icons.favorite, color: Colors.red, size: 18),
                const SizedBox(width: 4),
                Text('${product.likes} likes',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Explore screen
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.trending_up), text: 'Trending'),
            Tab(text: 'New'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search products, retailers, emotions...',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => setState(() => searchQuery = val),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Trending products
                ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: trendingProducts.length,
                  itemBuilder: (context, index) =>
                      SentimentCard(product: trendingProducts[index]),
                ),
                // New products
                ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: newProducts.length,
                  itemBuilder: (context, index) =>
                      SentimentCard(product: newProducts[index]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}