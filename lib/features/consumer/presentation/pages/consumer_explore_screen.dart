import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/features/consumer/presentation/shell/consumer_shell.dart';
import 'package:yayvo/features/consumer/data/repositories/product_repository_impl.dart';
import 'package:yayvo/features/consumer/data/repositories/collection_repository_impl.dart';
import 'package:yayvo/features/consumer/presentation/theme/consumer_theme.dart';
import 'package:yayvo/features/consumer/presentation/widgets/product_card.dart';
import 'package:yayvo/features/consumer/presentation/widgets/product_detail_dialog.dart';
import 'package:yayvo/features/consumer/presentation/viewmodels/explore_viewmodel.dart';

class ConsumerExploreScreen extends ConsumerStatefulWidget {
  const ConsumerExploreScreen({super.key});

  @override
  ConsumerState<ConsumerExploreScreen> createState() =>
      _ConsumerExploreScreenState();
}

class _ConsumerExploreScreenState extends ConsumerState<ConsumerExploreScreen> {
  final _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _didInitialLoad = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_didInitialLoad && mounted) {
        _didInitialLoad = true;
        ref.read(exploreViewModelProvider.notifier).loadPage(1, null);
      }
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 300) {
      ref.read(exploreViewModelProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final exploreState = ref.watch(exploreViewModelProvider);
    final authId = ref.watch(consumerAuthIdProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'EXPLORE',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: ConsumerTheme.mutedOf(context),
            letterSpacing: 0.14,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Products',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: ConsumerTheme.primaryTextOf(context),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search products...',
                ),
                onSubmitted: (_) => ref
                    .read(exploreViewModelProvider.notifier)
                    .search(_searchController.text),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: exploreState.isLoading
                  ? null
                  : () => ref
                        .read(exploreViewModelProvider.notifier)
                        .search(_searchController.text),
              child: Text(exploreState.isLoading ? 'Searching…' : 'Search'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: exploreState.isLoading && exploreState.products.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : exploreState.error != null && exploreState.products.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          exploreState.error!,
                          style: const TextStyle(color: ConsumerTheme.error),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: exploreState.isLoading
                              ? null
                              : () => ref
                                    .read(exploreViewModelProvider.notifier)
                                    .refresh(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : exploreState.products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'No products found.',
                        style: TextStyle(color: ConsumerTheme.mutedOf(context)),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: exploreState.isLoading
                            ? null
                            : () => ref
                                  .read(exploreViewModelProvider.notifier)
                                  .search(_searchController.text),
                        child: const Text('Search'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () =>
                      ref.read(exploreViewModelProvider.notifier).refresh(),
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.88,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount:
                        exploreState.products.length +
                        (exploreState.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i >= exploreState.products.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final product = exploreState.products[i];
                      final isSaved = exploreState.savedProductIds.contains(
                        product.id,
                      );
                      final isLiked = exploreState.likedProductIds.contains(
                        product.id,
                      );
                      return ProductCard(
                        product: product,
                        currentUserId: authId,
                        isLiked: isLiked,
                        isSaved: isSaved,
                        onTap: () => ProductDetailDialog.show(context, product),
                        onLikeChanged: () async {
                          if (authId == null) return;
                          final newIsLiked = !isLiked;
                          ref
                              .read(exploreViewModelProvider.notifier)
                              .updateLikedProduct(product.id, newIsLiked);
                          final repo = ref.read(productRepositoryProvider);
                          final result = isLiked
                              ? await repo.unlikeProduct(product.id, authId)
                              : await repo.likeProduct(product.id, authId);
                          result.fold(
                            (_) => ref
                                .read(exploreViewModelProvider.notifier)
                                .updateLikedProduct(product.id, isLiked),
                            (_) {},
                          );
                        },
                        onSaveChanged: () async {
                          if (authId == null) return;
                          final newIsSaved = !isSaved;
                          ref
                              .read(exploreViewModelProvider.notifier)
                              .updateSavedProduct(product.id, newIsSaved);
                          final repo = ref.read(collectionRepositoryProvider);
                          final result = isSaved
                              ? await repo.unsaveProduct(authId, product.id)
                              : await repo.saveProduct(authId, product.id);
                          result.fold(
                            (_) => ref
                                .read(exploreViewModelProvider.notifier)
                                .updateSavedProduct(product.id, isSaved),
                            (_) {},
                          );
                        },
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
