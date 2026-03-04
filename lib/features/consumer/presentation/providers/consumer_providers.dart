import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/features/consumer/data/repositories/consumer_repository_impl.dart';
import 'package:yayvo/features/consumer/data/repositories/product_repository_impl.dart';
import 'package:yayvo/features/consumer/data/repositories/review_repository_impl.dart';
import 'package:yayvo/features/consumer/domain/entities/consumer_entity.dart';

/// Fetches consumer profile by authId (login id).
final consumerByAuthIdProvider =
    FutureProvider.family<ConsumerEntity?, String>((ref, authId) async {
  if (authId.isEmpty) return null;
  final repo = ref.read(consumerRepositoryProvider);
  final result = await repo.getConsumerByAuthId(authId);
  return result.fold((_) => null, (c) => c);
});

/// Fetches consumer by document _id (e.g. review authorId). Use for review card author.
final consumerByDocIdProvider =
    FutureProvider.family<ConsumerEntity?, String>((ref, docId) async {
  if (docId.isEmpty) return null;
  final repo = ref.read(consumerRepositoryProvider);
  final result = await repo.getConsumerByDocId(docId);
  return result.fold((_) => null, (c) => c);
});

/// Fetches consumer for review author: tries doc id first, then auth id. Use in ReviewCard.
final consumerForReviewAuthorProvider =
    FutureProvider.family<ConsumerEntity?, String>((ref, authorId) async {
  if (authorId.isEmpty) return null;
  final repo = ref.read(consumerRepositoryProvider);
  final byDoc = await repo.getConsumerByDocId(authorId);
  final entity = byDoc.fold((_) => null, (c) => c);
  if (entity != null && entity.displayName.isNotEmpty) return entity;
  final byAuth = await repo.getConsumerByAuthId(authorId);
  return byAuth.fold((_) => null, (c) => c);
});

/// Whether the current user has liked this review. Key: 'reviewId|userId'.
final isReviewLikedProvider =
    FutureProvider.family<bool, String>((ref, key) async {
  final parts = key.split('|');
  if (parts.length != 2 || parts[0].isEmpty || parts[1].isEmpty) return false;
  final repo = ref.read(reviewRepositoryProvider);
  return repo.isReviewLiked(parts[0], parts[1]);
});

/// Whether the current user has liked this product. Key: 'productId|userId'.
final isProductLikedProvider =
    FutureProvider.family<bool, String>((ref, key) async {
  final parts = key.split('|');
  if (parts.length != 2 || parts[0].isEmpty || parts[1].isEmpty) return false;
  final repo = ref.read(productRepositoryProvider);
  return repo.isProductLiked(parts[0], parts[1]);
});
