import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String authorId;
  final String? imageUrl;
  final String? retailerName;
  final String? retailerIconUrl;
  final List<String> targetSentiment;
  final int likes;

  const ProductEntity({
    required this.id,
    required this.title,
    this.description,
    required this.authorId,
    this.imageUrl,
    this.retailerName,
    this.retailerIconUrl,
    this.targetSentiment = const [],
    this.likes = 0,
  });

  ProductEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? authorId,
    String? imageUrl,
    String? retailerName,
    String? retailerIconUrl,
    List<String>? targetSentiment,
    int? likes,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      authorId: authorId ?? this.authorId,
      imageUrl: imageUrl ?? this.imageUrl,
      retailerName: retailerName ?? this.retailerName,
      retailerIconUrl: retailerIconUrl ?? this.retailerIconUrl,
      targetSentiment: targetSentiment ?? this.targetSentiment,
      likes: likes ?? this.likes,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    authorId,
    imageUrl,
    retailerName,
    retailerIconUrl,
    targetSentiment,
    likes,
  ];
}
