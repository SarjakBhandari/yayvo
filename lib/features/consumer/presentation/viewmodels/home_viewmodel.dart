import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:yayvo/features/consumer/domain/entities/review_entity.dart';
import 'package:yayvo/features/consumer/domain/usecases/get_reviews_paginated.dart';
import 'package:yayvo/features/consumer/data/repositories/review_repository_impl.dart';
import 'package:yayvo/features/consumer/data/repositories/collection_repository_impl.dart';
import 'package:yayvo/core/utils/network_error_helper.dart';
import 'package:yayvo/features/consumer/presentation/shell/consumer_shell.dart';

/// State class for home screen
class HomeState {
  final List<ReviewEntity> reviews;
  final Set<String> savedReviewIds;
  final int currentPage;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;

  HomeState({
    this.reviews = const [],
    this.savedReviewIds = const {},
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
  });

  HomeState copyWith({
    List<ReviewEntity>? reviews,
    Set<String>? savedReviewIds,
    int? currentPage,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
  }) {
    return HomeState(
      reviews: reviews ?? this.reviews,
      savedReviewIds: savedReviewIds ?? this.savedReviewIds,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
    );
  }
}

/// View model for home screen
class HomeViewModel extends StateNotifier<HomeState> {
  final GetReviewsPaginated getReviewsPaginated;
  final Ref ref;
  static const int _pageSize = 10;

  HomeViewModel({required this.getReviewsPaginated, required this.ref})
    : super(HomeState());

  /// Load reviews for a specific page
  Future<void> loadPage(int page) async {
    if (page > 1 && (state.isLoadingMore || !state.hasMore)) return;
    if (page == 1 && state.isLoading) return;

    try {
      if (page == 1) {
        state = state.copyWith(isLoading: true, error: null);
      } else {
        state = state.copyWith(isLoadingMore: true);
      }

      final result = await getReviewsPaginated.call({
        'page': page,
        'size': _pageSize,
      });

      // Load saved reviews if on first page
      Set<String> savedIds = state.savedReviewIds;
      final authId = ref.read(consumerAuthIdProvider);
      if (authId != null && authId.isNotEmpty && page == 1) {
        try {
          final repo = ref.read(collectionRepositoryProvider);
          final savedResult = await repo.getSavedReviews(authId);
          savedIds = savedResult.fold(
            (_) => <String>{},
            (list) => list.map((r) => r.id).toSet(),
          );
        } catch (_) {}
      }

      result.fold(
        (failure) => state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          error: normalizeNetworkErrorMessage(failure.message),
          reviews: page == 1 ? [] : state.reviews,
        ),
        (paginated) => state = state.copyWith(
          reviews: page == 1
              ? paginated.items
              : [...state.reviews, ...paginated.items],
          savedReviewIds: savedIds,
          hasMore: paginated.hasMore,
          currentPage: page,
          isLoading: false,
          isLoadingMore: false,
          error: null,
        ),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: page == 1
            ? normalizeNetworkErrorMessage(e.toString())
            : state.error,
        reviews: page == 1 ? [] : state.reviews,
      );
    }
  }

  /// Load more reviews
  Future<void> loadMore() {
    if (!state.hasMore || state.isLoadingMore || state.isLoading) {
      return Future.value();
    }
    return loadPage(state.currentPage + 1);
  }

  /// Refresh reviews (reload first page)
  Future<void> refresh() {
    state = state.copyWith(currentPage: 1, hasMore: true);
    return loadPage(1);
  }

  /// Update saved reviews set
  void updateSavedReview(String reviewId, bool isSaved) {
    if (isSaved) {
      state = state.copyWith(
        savedReviewIds: {...state.savedReviewIds, reviewId},
      );
    } else {
      final updated = Set<String>.from(state.savedReviewIds);
      updated.remove(reviewId);
      state = state.copyWith(savedReviewIds: updated);
    }
  }
}

/// Provide the view model for home screen
final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>((
  ref,
) {
  final usecase = ref.read(getReviewsPaginatedProvider);
  return HomeViewModel(getReviewsPaginated: usecase, ref: ref);
});

/// Internal provider for GetReviewsPaginated usecase
final getReviewsPaginatedProvider = Provider<GetReviewsPaginated>((ref) {
  return GetReviewsPaginated(ref.read(reviewRepositoryProvider));
});
