import '../../domain/entities/review_entity.dart';

class ReviewApiModel {
  final String id;
  final String title;
  final String description;
  final String authorId;
  final String? productName;
  final String? image;
  final List<String> sentiments;
  final int likes;
  final List<String> likedBy;
  final DateTime? createdAt;

  ReviewApiModel({
    required this.id,
    required this.title,
    required this.description,
    required this.authorId,
    this.productName,
    this.image,
    this.sentiments = const [],
    this.likes = 0,
    this.likedBy = const [],
    this.createdAt,
  });

  factory ReviewApiModel.fromJson(Map<String, dynamic> json) {
    String str(dynamic v) => v == null ? '' : v.toString();
    final likedByRaw = json['likedBy'];
    final likedByList = likedByRaw is List
        ? (likedByRaw).map((e) => str(e)).where((s) => s.isNotEmpty).toList()
        : <String>[];
    return ReviewApiModel(
      id: str(json['id'] ?? json['_id']),
      title: str(json['title']),
      description: str(json['description']),
      authorId: str(json['authorId'] ?? json['author']),
      productName: json['productName'] != null ? str(json['productName']) : null,
      image: json['image'] != null ? str(json['image']) : (json['productImage'] != null ? str(json['productImage']) : (json['imageUrl'] != null ? str(json['imageUrl']) : null)),
      sentiments:
          (json['sentiments'] as List<dynamic>?)
              ?.map((e) => e == null ? '' : e.toString())
              .where((s) => s.isNotEmpty)
              .toList() ??
          [],
      likes: likedByList.isNotEmpty
          ? likedByList.length
          : (json['noOfLikes'] is int
              ? json['noOfLikes'] as int
              : (json['likes'] is int ? json['likes'] as int : 0)),
      likedBy: likedByList,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'authorId': authorId,
      'productName': productName,
      'image': image,
      'sentiments': sentiments,
      'likes': likes,
      'likedBy': likedBy,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  ReviewEntity toEntity() {
    return ReviewEntity(
      id: id,
      title: title,
      description: description,
      authorId: authorId,
      productName: productName,
      imageUrl: image,
      sentiments: sentiments,
      likes: likes,
      likedBy: likedBy,
      createdAt: createdAt,
    );
  }
}
