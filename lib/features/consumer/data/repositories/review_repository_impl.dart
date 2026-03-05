import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:yayvo/core/error/failures.dart';
import 'package:yayvo/core/services/connectivity/network_info.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/entities/paginated_reviews.dart';
import '../../domain/repositories/i_review_repository.dart';
import '../datasources/local/review_local_datasource.dart';
import '../datasources/remote/review_remote_datasource.dart';

final reviewRepositoryProvider = Provider<ReviewRepositoryImpl>((ref) {
  return ReviewRepositoryImpl(
    ref.read(reviewRemoteProvider),
    ref.read(reviewLocalProvider),
    ref.read(networkInfoProvider),
  );
});

class ReviewRepositoryImpl implements IReviewRepository {
  final ReviewRemoteDatasource _remote;
  final ReviewLocalDatasource _local;
  final INetworkInfo _networkInfo;

  ReviewRepositoryImpl(this._remote, this._local, this._networkInfo);

  @override
  Future<Either<Failure, ReviewEntity>> createReview(
    ReviewEntity review,
  ) async {
    try {
      final payload = {
        'title': review.title,
        'description': review.description,
        'authorId': review.authorId,
        if (review.productName != null && review.productName!.isNotEmpty)
          'productName': review.productName,
        'productImage': review.imageUrl ?? '',
        'sentiments': review.sentiments,
      };
      final model = await _remote.createReview(payload);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReviewEntity>> updateReview(
    String id,
    ReviewEntity updates,
  ) async {
    try {
      final payload = {
        'title': updates.title,
        'description': updates.description,
        if (updates.productName != null && updates.productName!.isNotEmpty)
          'productName': updates.productName,
        'sentiments': updates.sentiments,
      };
      final model = await _remote.updateReview(id, payload);
      return Right(model.id.isNotEmpty ? model.toEntity() : updates);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteReview(String id) async {
    try {
      await _remote.deleteReview(id);
      return const Right(true);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedReviews>> getReviewsPaginated(
    Map<String, dynamic>? params,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remote.getReviewsPaginated(params);
        final list = result.list.map((e) => e.toEntity()).toList();
        try {
          await _local.cacheReviews(result.list);
        } catch (_) {}
        return Right(PaginatedReviews(items: list, hasMore: result.hasMore));
      } catch (e) {
        final cached = _local.getCachedReviews();
        if (cached.isNotEmpty) {
          return Right(
            PaginatedReviews(
              items: cached.map((e) => e.toEntity()).toList(),
              hasMore: false,
            ),
          );
        }
        return Left(ApiFailure(message: e.toString()));
      }
    }
    final cached = _local.getCachedReviews();
    if (cached.isNotEmpty) {
      return Right(
        PaginatedReviews(
          items: cached.map((e) => e.toEntity()).toList(),
          hasMore: false,
        ),
      );
    }
    return const Left(ApiFailure(message: 'Offline. No cached reviews.'));
  }

  @override
  Future<Either<Failure, List<ReviewEntity>>> getReviewsByAuthor(
    String authorId,
  ) async {
    if (authorId.isEmpty) return const Right([]);
    if (await _networkInfo.isConnected) {
      try {
        final list = await _remote.getReviewsByAuthor(authorId);
        return Right(list.map((e) => e.toEntity()).toList());
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    }
    final cached = _local.getCachedReviews();
    final filtered = cached
        .where((m) => m.authorId == authorId)
        .map((e) => e.toEntity())
        .toList();
    return Right(filtered);
  }

  @override
  Future<Either<Failure, bool>> likeReview(
    String reviewId,
    String userId,
  ) async {
    try {
      await _remote.likeReview(reviewId, userId);
      return const Right(true);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> unlikeReview(
    String reviewId,
    String userId,
  ) async {
    try {
      await _remote.unlikeReview(reviewId, userId);
      return const Right(true);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<bool> isReviewLiked(String reviewId, String userId) async {
    try {
      return await _remote.isReviewLiked(reviewId, userId);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<Either<Failure, void>> uploadReviewImage(
    String reviewId,
    dynamic imageFile,
  ) async {
    try {
      final file = imageFile as File;
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split(Platform.pathSeparator).last,
        ),
      });
      await _remote.uploadReviewImage(reviewId, formData);
      return const Right(null);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
