import 'package:yayvo/models/sentiment_model.dart';

class Product {
  final String id;
  final String image;
  final String title;
  final String retailerName;
  final String retailerAvatar;
  final List<Sentiment> emotions;
  final String sentimentSummary;
  final int likes;

  Product({
    required this.id,
    required this.image,
    required this.title,
    required this.retailerName,
    required this.retailerAvatar,
    required this.emotions,
    required this.sentimentSummary,
    required this.likes,
  });
}
