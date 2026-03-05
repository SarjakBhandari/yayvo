import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:yayvo/features/consumer/domain/entities/product_entity.dart';
import 'package:yayvo/features/consumer/domain/usecases/get_products.dart';
import 'package:yayvo/features/consumer/data/repositories/product_repository_impl.dart';
import 'package:yayvo/features/consumer/data/repositories/collection_repository_impl.dart';
import 'package:yayvo/core/utils/network_error_helper.dart';
import 'package:yayvo/features/consumer/presentation/shell/consumer_shell.dart';

/// State class for explore screen
class ExploreState {
  final List<ProductEntity> products;
  final Set<String> savedProductIds;
  final Set<String> likedProductIds;
  final int currentPage;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final String? currentQuery;
  final String? error;

  ExploreState({
    this.products = const [],
    this.savedProductIds = const {},
    this.likedProductIds = const {},
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.currentQuery,
    this.error,
  });

  ExploreState copyWith({
    List<ProductEntity>? products,
    Set<String>? savedProductIds,
    Set<String>? likedProductIds,
    int? currentPage,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    String? currentQuery,
    String? error,
  }) {
    return ExploreState(
      products: products ?? this.products,
      savedProductIds: savedProductIds ?? this.savedProductIds,
      likedProductIds: likedProductIds ?? this.likedProductIds,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentQuery: currentQuery ?? this.currentQuery,
      error: error ?? this.error,
    );
  }
}

/// View model for explore screen
class ExploreViewModel extends StateNotifier<ExploreState> {
  final GetProducts getProducts;
  final Ref ref;
  static const int _pageSize = 20;

  ExploreViewModel({required this.getProducts, required this.ref})
    : super(ExploreState());

  /// Load products for a specific page
  Future<void> loadPage(int page, String? query) async {
    if (page == 1 && state.isLoading) return;
    if (page > 1 && state.isLoadingMore) return;

    try {
      if (page == 1) {
        state = state.copyWith(isLoading: true, error: null);
      } else {
        state = state.copyWith(isLoadingMore: true);
      }

      final search = query?.trim().isEmpty ?? true ? null : query?.trim();
      final result = await getProducts.call({
        'search': search,
        'page': page,
        'limit': _pageSize,
      });

      Set<String> savedIds = {};
      Set<String> likedIds = {};

      final list = result.fold((_) => <ProductEntity>[], (l) => l);

      // Load saved and liked products if on first page
      final authId = ref.read(consumerAuthIdProvider);
      if (authId != null && authId.isNotEmpty && list.isNotEmpty) {
        try {
          final repo = ref.read(collectionRepositoryProvider);
          final savedResult = await repo.getSavedProducts(authId);
          savedIds = savedResult.fold(
            (_) => <String>{},
            (l) => l.map((p) => p.id).toSet(),
          );

          final productRepo = ref.read(productRepositoryProvider);
          for (final p in list) {
            if (await productRepo.isProductLiked(p.id, authId)) {
              likedIds.add(p.id);
            }
          }
        } catch (_) {}
      }

      result.fold(
        (failure) => state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          error: normalizeNetworkErrorMessage(failure.message),
          products: page == 1 ? [] : state.products,
        ),
        (l) => state = state.copyWith(
          products: page == 1 ? l : [...state.products, ...l],
          savedProductIds: page == 1
              ? savedIds
              : {...state.savedProductIds, ...savedIds},
          likedProductIds: page == 1
              ? likedIds
              : {...state.likedProductIds, ...likedIds},
          hasMore: l.length >= _pageSize,
          currentPage: page,
          currentQuery: search,
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
        products: page == 1 ? [] : state.products,
      );
    }
  }

  /// Load more products
  Future<void> loadMore() {
    if (!state.hasMore || state.isLoadingMore || state.isLoading) {
      return Future.value();
    }
    return loadPage(state.currentPage + 1, state.currentQuery);
  }

  /// Search products
  Future<void> search(String query) {
    state = state.copyWith(currentPage: 1, hasMore: true);
    return loadPage(1, query);
  }

  /// Refresh products
  Future<void> refresh() {
    state = state.copyWith(currentPage: 1, hasMore: true);
    return loadPage(1, state.currentQuery);
  }

  /// Update saved product
  void updateSavedProduct(String productId, bool isSaved) {
    if (isSaved) {
      state = state.copyWith(
        savedProductIds: {...state.savedProductIds, productId},
      );
    } else {
      final updated = Set<String>.from(state.savedProductIds);
      updated.remove(productId);
      state = state.copyWith(savedProductIds: updated);
    }
  }

  /// Update liked product
  void updateLikedProduct(String productId, bool isLiked) {
    if (isLiked) {
      state = state.copyWith(
        likedProductIds: {...state.likedProductIds, productId},
      );
    } else {
      final updated = Set<String>.from(state.likedProductIds);
      updated.remove(productId);
      state = state.copyWith(likedProductIds: updated);
    }
  }
}

/// Provide the view model for explore screen
final exploreViewModelProvider =
    StateNotifierProvider<ExploreViewModel, ExploreState>((ref) {
      final usecase = ref.read(getProductsProvider);
      return ExploreViewModel(getProducts: usecase, ref: ref);
    });

/// Internal provider for GetProducts usecase
final getProductsProvider = Provider<GetProducts>((ref) {
  return GetProducts(ref.read(productRepositoryProvider));
});
