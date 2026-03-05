import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:yayvo/features/consumer/domain/entities/review_entity.dart';
import 'package:yayvo/features/consumer/domain/usecases/create_review.dart';
import 'package:yayvo/features/consumer/data/repositories/review_repository_impl.dart';
import 'package:yayvo/core/utils/network_error_helper.dart';
import 'package:yayvo/core/services/connectivity/network_info.dart';

/// State class for create review screen
class CreateReviewState {
  final String title;
  final String description;
  final String productName;
  final List<String> sentiments;
  final File? image;
  final bool isSubmitting;
  final bool isUploading;
  final String? error;
  final bool isSuccessful;

  CreateReviewState({
    this.title = '',
    this.description = '',
    this.productName = '',
    this.sentiments = const [],
    this.image,
    this.isSubmitting = false,
    this.isUploading = false,
    this.error,
    this.isSuccessful = false,
  });

  CreateReviewState copyWith({
    String? title,
    String? description,
    String? productName,
    List<String>? sentiments,
    File? image,
    bool? isSubmitting,
    bool? isUploading,
    String? error,
    bool? isSuccessful,
  }) {
    return CreateReviewState(
      title: title ?? this.title,
      description: description ?? this.description,
      productName: productName ?? this.productName,
      sentiments: sentiments ?? this.sentiments,
      image: image ?? this.image,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isUploading: isUploading ?? this.isUploading,
      error: error ?? this.error,
      isSuccessful: isSuccessful ?? this.isSuccessful,
    );
  }
}

/// View model for create review screen
class CreateReviewViewModel extends StateNotifier<CreateReviewState> {
  final CreateReview createReview;
  final Ref ref;

  CreateReviewViewModel({required this.createReview, required this.ref})
    : super(CreateReviewState());

  /// Update title
  void setTitle(String title) {
    state = state.copyWith(title: title);
  }

  /// Update description
  void setDescription(String description) {
    state = state.copyWith(description: description);
  }

  /// Update product name
  void setProductName(String productName) {
    state = state.copyWith(productName: productName);
  }

  /// Update sentiments
  void setSentiments(List<String> sentiments) {
    state = state.copyWith(sentiments: sentiments);
  }

  /// Set image
  void setImage(File? image) {
    state = state.copyWith(image: image);
  }

  /// Validate and submit review
  Future<void> submitReview({required String authId}) async {
    if (authId.isEmpty) {
      state = state.copyWith(error: 'Please log in to create a review.');
      return;
    }

    final title = state.title.trim();
    if (title.isEmpty) {
      state = state.copyWith(error: 'Title is required.');
      return;
    }

    // Check connection
    final connected = await ref.read(networkInfoProvider).isConnected;
    if (!connected) {
      state = state.copyWith(error: 'No internet connection');
      return;
    }

    try {
      state = state.copyWith(isSubmitting: true, error: null);

      final entity = ReviewEntity(
        id: '',
        title: title,
        description: state.description.trim(),
        authorId: authId,
        productName: state.productName.trim().isEmpty
            ? null
            : state.productName.trim(),
        sentiments: state.sentiments,
        likes: 0,
        likedBy: const [],
      );

      final result = await createReview.call(entity);

      result.fold(
        (failure) => state = state.copyWith(
          isSubmitting: false,
          error: normalizeNetworkErrorMessage(failure.message),
        ),
        (createdReview) async {
          // Upload image if available
          if (state.image != null && createdReview.id.isNotEmpty) {
            state = state.copyWith(isUploading: true);
            try {
              final repo = ref.read(reviewRepositoryProvider);
              await repo.uploadReviewImage(createdReview.id, state.image!);
            } catch (e) {
              // Image upload failed but review was created
              state = state.copyWith(
                isUploading: false,
                error: 'Review created but image upload failed',
              );
              return;
            }
          }

          state = state.copyWith(
            isSubmitting: false,
            isUploading: false,
            isSuccessful: true,
            error: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        isUploading: false,
        error: normalizeNetworkErrorMessage(e.toString()),
      );
    }
  }

  /// Reset form
  void reset() {
    state = CreateReviewState();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provide the view model for create review screen
final createReviewViewModelProvider =
    StateNotifierProvider<CreateReviewViewModel, CreateReviewState>((ref) {
      final usecase = ref.read(createReviewProvider);
      return CreateReviewViewModel(createReview: usecase, ref: ref);
    });

/// Internal provider for CreateReview usecase
final createReviewProvider = Provider<CreateReview>((ref) {
  return CreateReview(ref.read(reviewRepositoryProvider));
});
