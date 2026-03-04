import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/features/consumer/presentation/shell/consumer_shell.dart';
import 'package:yayvo/features/consumer/data/repositories/product_repository_impl.dart';
import 'package:yayvo/features/consumer/data/repositories/collection_repository_impl.dart';
import 'package:yayvo/features/consumer/domain/entities/product_entity.dart';
import 'package:yayvo/features/consumer/domain/usecases/get_products.dart';
import 'package:yayvo/features/consumer/presentation/theme/consumer_theme.dart';
import 'package:yayvo/features/consumer/presentation/widgets/product_card.dart';
import 'package:yayvo/features/consumer/presentation/widgets/product_detail_dialog.dart';
import 'package:yayvo/core/utils/network_error_helper.dart';

final getProductsProvider = Provider<GetProducts>((ref) {
  return GetProducts(ref.read(productRepositoryProvider));
});

const int _pageSize = 20;

class ConsumerExploreScreen extends ConsumerStatefulWidget {
  const ConsumerExploreScreen({super.key});

  @override
  ConsumerState<ConsumerExploreScreen> createState() =>
      _ConsumerExploreScreenState();
}

class _ConsumerExploreScreenState extends ConsumerState<ConsumerExploreScreen> {
  final _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ProductEntity> _products = [];
  Set<String> _savedProductIds = {};
  Set<String> _likedProductIds = {};
  String? _error;
  int _page = 1;
  bool _hasMore = true;
  bool _loading = false;
  bool _loadingMore = false;
  String? _currentQuery;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPage(1, null));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _loadingMore || _loading) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 300) {
      _loadMore();
    }
  }

  Future<void> _loadPage(int page, String? query) async {
    if (page == 1 && _loading) return;
    if (page > 1 && _loadingMore) return;
    if (page == 1) {
      setState(() => _loading = true);
    } else {
      setState(() => _loadingMore = true);
    }
    try {
      final authId = ref.read(consumerAuthIdProvider);
      final usecase = ref.read(getProductsProvider);
      final search = query?.trim().isEmpty ?? true ? null : query?.trim();
      final result = await usecase.call({
        'search': search,
        'page': page,
        'limit': _pageSize,
      });
      Set<String> savedIds = {};
      Set<String> likedIds = {};
      final list = result.fold((_) => <ProductEntity>[], (l) => l);
      if (authId != null && authId.isNotEmpty && list.isNotEmpty) {
        try {
          final repo = ref.read(collectionRepositoryProvider);
          final savedResult = await repo.getSavedProducts(authId);
          savedIds = savedResult.fold((_) => <String>{}, (l) => l.map((p) => p.id).toSet());
          final productRepo = ref.read(productRepositoryProvider);
          for (final p in list) {
            if (await productRepo.isProductLiked(p.id, authId)) likedIds.add(p.id);
          }
        } catch (_) {}
      }
      if (!mounted) return;
      result.fold(
        (f) => setState(() {
          _loading = false;
          _loadingMore = false;
          if (page == 1) _products = [];
          _error = normalizeNetworkErrorMessage(f.message);
        }),
        (l) => setState(() {
          if (page == 1) {
            _products = l;
            _savedProductIds = savedIds;
            _likedProductIds = likedIds;
          } else {
            _products = [..._products, ...l];
            _savedProductIds = {..._savedProductIds, ...savedIds};
            _likedProductIds = {..._likedProductIds, ...likedIds};
          }
          _hasMore = l.length >= _pageSize;
          _page = page;
          _currentQuery = search;
          _loading = false;
          _loadingMore = false;
          _error = null;
        }),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadingMore = false;
        if (page == 1) _products = [];
        _error = page == 1 ? normalizeNetworkErrorMessage(e.toString()) : null;
      });
    }
  }

  Future<void> _loadMore() {
    if (!_hasMore || _loadingMore || _loading) return Future.value();
    return _loadPage(_page + 1, _currentQuery);
  }

  Future<void> _search() async {
    _page = 1;
    _hasMore = true;
    await _loadPage(1, _searchController.text);
  }

  Future<void> _refresh() async {
    _page = 1;
    _hasMore = true;
    await _loadPage(1, _currentQuery ?? _searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final authId = ref.watch(consumerAuthIdProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'EXPLORE',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: ConsumerTheme.muted,
            letterSpacing: 0.14,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Products',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: ConsumerTheme.primaryText,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: ConsumerTheme.border),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => _search(),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: _loading ? null : _search,
              child: Text(_loading ? 'Searching…' : 'Search'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: _loading && _products.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _error != null && _products.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _error!,
                              style: TextStyle(color: ConsumerTheme.error),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: _loading ? null : () => _refresh(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
              : _products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'No products found.',
                            style: TextStyle(color: ConsumerTheme.muted),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: _loading ? null : _search,
                            child: const Text('Search'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _refresh,
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
                        itemCount: _products.length + (_loadingMore ? 1 : 0),
                        itemBuilder: (context, i) {
                          if (i >= _products.length) {
                            return const Center(
                                child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ));
                          }
                          final product = _products[i];
                          final isSaved = _savedProductIds.contains(product.id);
                          final isLiked = _likedProductIds.contains(product.id);
                          return ProductCard(
                            product: product,
                            currentUserId: authId,
                            isLiked: isLiked,
                            isSaved: isSaved,
                            onTap: () => ProductDetailDialog.show(context, product),
                            onLikeChanged: () async {
                              if (authId == null) return;
                              final productId = product.id;
                              final currentlyLiked = _likedProductIds.contains(productId);
                              setState(() {
                                if (currentlyLiked) {
                                  _likedProductIds = {..._likedProductIds}..remove(productId);
                                } else {
                                  _likedProductIds = {..._likedProductIds, productId};
                                }
                              });
                              final repo = ref.read(productRepositoryProvider);
                              final result = currentlyLiked
                                  ? await repo.unlikeProduct(product.id, authId)
                                  : await repo.likeProduct(product.id, authId);
                              result.fold(
                                (_) => mounted ? setState(() {
                                  if (currentlyLiked) {
                                    _likedProductIds = {..._likedProductIds, productId};
                                  } else {
                                    _likedProductIds = {..._likedProductIds}..remove(productId);
                                  }
                                }) : null,
                                (_) {},
                              );
                            },
                            onSaveChanged: () async {
                              if (authId == null) return;
                              final productId = product.id;
                              final currentlySaved = _savedProductIds.contains(productId);
                              setState(() {
                                if (currentlySaved) {
                                  _savedProductIds = {..._savedProductIds}..remove(productId);
                                } else {
                                  _savedProductIds = {..._savedProductIds, productId};
                                }
                              });
                              final repo = ref.read(collectionRepositoryProvider);
                              final result = currentlySaved
                                  ? await repo.unsaveProduct(authId, product.id)
                                  : await repo.saveProduct(authId, product.id);
                              result.fold(
                                (_) => mounted ? setState(() {
                                  if (currentlySaved) {
                                    _savedProductIds = {..._savedProductIds, productId};
                                  } else {
                                    _savedProductIds = {..._savedProductIds}..remove(productId);
                                  }
                                }) : null,
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
