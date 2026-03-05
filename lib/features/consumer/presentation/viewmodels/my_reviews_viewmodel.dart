import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:yayvo/features/consumer/domain/entities/review_entity.dart';
import 'package:yayvo/features/consumer/data/repositories/review_repository_impl.dart';
import 'package:yayvo/features/consumer/presentation/shell/consumer_shell.dart';
import 'package:yayvo/core/utils/network_error_helper.dart';

/// State class for my reviews screen
class MyReviewsState {
  final List<ReviewEntity> reviews;
  final bool isLoading;
  final String? error;

  MyReviewsState({this.reviews = const [], this.isLoading = true, this.error});

  MyReviewsState copyWith({
    List<ReviewEntity>? reviews,
    bool? isLoading,
    String? error,
  }) {
    return MyReviewsState(
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// View model for my reviews screen
class MyReviewsViewModel extends StateNotifier<MyReviewsState> {
  final Ref ref;

  MyReviewsViewModel({required this.ref}) : super(MyReviewsState());

  /// Load user's reviews
  Future<void> loadReviews(String authId) async {
    if (authId.isEmpty) {
      state = state.copyWith(isLoading: false, error: 'Not logged in');
      return;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      final repo = ref.read(reviewRepositoryProvider);
      final result = await repo.getReviewsByAuthor(authId);

      result.fold(
        (failure) => state = state.copyWith(
          isLoading: false,
          reviews: [],
          error: normalizeNetworkErrorMessage(failure.message),
        ),
        (list) => state = state.copyWith(
          isLoading: false,
          reviews: list,
          error: null,
        ),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        reviews: [],
        error: normalizeNetworkErrorMessage(e.toString()),
      );
    }
  }

  /// Refresh reviews
  Future<void> refresh(String authId) {
    return loadReviews(authId);
  }

  /// Remove review from list
  void removeReview(String reviewId) {
    final updated = state.reviews.where((r) => r.id != reviewId).toList();
    state = state.copyWith(reviews: updated);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provide the view model for my reviews screen
final myReviewsViewModelProvider =
    StateNotifierProvider<MyReviewsViewModel, MyReviewsState>((ref) {
      final viewModel = MyReviewsViewModel(ref: ref);
      // Auto-load reviews when provider is created
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final authId = ref.read(consumerAuthIdProvider);
        if (authId != null && authId.isNotEmpty) {
          viewModel.loadReviews(authId);
        }
      });
      return viewModel;
    });
