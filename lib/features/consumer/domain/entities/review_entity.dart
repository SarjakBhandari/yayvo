import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String authorId;
  final String? productName;
  final String? imageUrl;
  final List<String> sentiments;
  final int likes;
  final List<String> likedBy;
  final DateTime? createdAt;

  const ReviewEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.authorId,
    this.productName,
    this.imageUrl,
    this.sentiments = const [],
    this.likes = 0,
    this.likedBy = const [],
    this.createdAt,
  });

  ReviewEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? authorId,
    String? productName,
    String? imageUrl,
    List<String>? sentiments,
    int? likes,
    List<String>? likedBy,
    DateTime? createdAt,
  }) {
    return ReviewEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      authorId: authorId ?? this.authorId,
      productName: productName ?? this.productName,
      imageUrl: imageUrl ?? this.imageUrl,
      sentiments: sentiments ?? this.sentiments,
      likes: likes ?? this.likes,
      likedBy: likedBy ?? this.likedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    authorId,
    productName,
    imageUrl,
    sentiments,
    likes,
    likedBy,
    createdAt,
  ];
}
