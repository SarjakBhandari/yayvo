import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:yayvo/features/consumer/domain/entities/review_entity.dart';
import 'package:yayvo/features/consumer/domain/entities/product_entity.dart';
import 'package:yayvo/features/consumer/data/repositories/collection_repository_impl.dart';
import 'package:yayvo/core/utils/network_error_helper.dart';

/// Collection tab type
enum CollectionTab { reviews, products }

/// State class for collections screen
class CollectionsState {
  final List<ReviewEntity> savedReviews;
  final List<ProductEntity> savedProducts;
  final CollectionTab selectedTab;
  final bool isLoading;
  final String? error;

  CollectionsState({
    this.savedReviews = const [],
    this.savedProducts = const [],
    this.selectedTab = CollectionTab.reviews,
    this.isLoading = false,
    this.error,
  });

  CollectionsState copyWith({
    List<ReviewEntity>? savedReviews,
    List<ProductEntity>? savedProducts,
    CollectionTab? selectedTab,
    bool? isLoading,
    String? error,
  }) {
    return CollectionsState(
      savedReviews: savedReviews ?? this.savedReviews,
      savedProducts: savedProducts ?? this.savedProducts,
      selectedTab: selectedTab ?? this.selectedTab,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// View model for collections screen
class CollectionsViewModel extends StateNotifier<CollectionsState> {
  final Ref ref;

  CollectionsViewModel({required this.ref}) : super(CollectionsState());

  /// Load saved collections (reviews and products)
  Future<void> loadCollections(String authId) async {
    if (authId.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        error: 'Log in to see collections',
      );
      return;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      final repo = ref.read(collectionRepositoryProvider);
      final revResult = await repo.getSavedReviews(authId);
      final prodResult = await repo.getSavedProducts(authId);

      List<ReviewEntity> reviews = [];
      List<ProductEntity> products = [];

      revResult.fold(
        (failure) => state = state.copyWith(
          error: normalizeNetworkErrorMessage(failure.message),
        ),
        (list) => reviews = list,
      );

      prodResult.fold(
        (failure) => state = state.copyWith(
          error: state.error ?? normalizeNetworkErrorMessage(failure.message),
        ),
        (list) => products = list,
      );

      state = state.copyWith(
        savedReviews: reviews,
        savedProducts: products,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: normalizeNetworkErrorMessage(e.toString()),
      );
    }
  }

  /// Refresh collections
  Future<void> refresh(String authId) {
    return loadCollections(authId);
  }

  /// Select tab
  void selectTab(CollectionTab tab) {
    state = state.copyWith(selectedTab: tab);
  }

  /// Remove saved review
  void removeSavedReview(String reviewId) {
    final updated = state.savedReviews.where((r) => r.id != reviewId).toList();
    state = state.copyWith(savedReviews: updated);
  }

  /// Remove saved product
  void removeSavedProduct(String productId) {
    final updated = state.savedProducts
        .where((p) => p.id != productId)
        .toList();
    state = state.copyWith(savedProducts: updated);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provide the view model for collections screen
final collectionsViewModelProvider =
    StateNotifierProvider<CollectionsViewModel, CollectionsState>((ref) {
      return CollectionsViewModel(ref: ref);
    });
