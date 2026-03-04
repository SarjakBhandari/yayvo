import '../../domain/entities/product_entity.dart';

class ProductApiModel {
  final String id;
  final String title;
  final String? description;
  final String authorId;
  final String? image;
  final String? retailerName;
  final String? retailerIcon;
  final List<String> targetSentiment;
  final int likes;

  ProductApiModel({
    required this.id,
    required this.title,
    this.description,
    required this.authorId,
    this.image,
    this.retailerName,
    this.retailerIcon,
    this.targetSentiment = const [],
    this.likes = 0,
  });

  factory ProductApiModel.fromJson(Map<String, dynamic> json) {
    return ProductApiModel(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      authorId: json['authorId'] ?? json['retailerId'] ?? json['retailerAuthId'] ?? '',
      image: json['image'] ?? json['imageUrl'],
      retailerName: json['retailerName'] as String?,
      retailerIcon: json['retailerIcon'] as String?,
      targetSentiment:
          (json['targetSentiment'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      likes: (json['noOfLikes'] is int)
          ? json['noOfLikes'] as int
          : (json['likes'] is int ? json['likes'] as int : 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'authorId': authorId,
      'image': image,
      'retailerName': retailerName,
      'retailerIcon': retailerIcon,
      'targetSentiment': targetSentiment,
      'likes': likes,
    };
  }

  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      title: title,
      description: description,
      authorId: authorId,
      imageUrl: image,
      retailerName: retailerName,
      retailerIconUrl: retailerIcon,
      targetSentiment: targetSentiment,
      likes: likes,
    );
  }
}
