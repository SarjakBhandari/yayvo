import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/features/consumer/data/repositories/collection_repository_impl.dart';
import 'package:yayvo/features/consumer/domain/entities/product_entity.dart';
import 'package:yayvo/features/consumer/domain/entities/review_entity.dart';
import 'package:yayvo/features/consumer/presentation/shell/consumer_shell.dart';
import 'package:yayvo/features/consumer/presentation/theme/consumer_theme.dart';
import 'package:yayvo/features/consumer/presentation/widgets/product_card.dart';
import 'package:yayvo/features/consumer/presentation/widgets/review_card.dart';
import 'package:yayvo/features/consumer/presentation/widgets/review_detail_dialog.dart';
import 'package:yayvo/features/consumer/presentation/widgets/product_detail_dialog.dart';
import 'package:yayvo/core/utils/network_error_helper.dart';
import 'package:yayvo/core/services/connectivity/network_info.dart';
import 'package:yayvo/features/consumer/presentation/providers/consumer_providers.dart';

class ConsumerCollectionScreen extends ConsumerStatefulWidget {
  const ConsumerCollectionScreen({super.key});

  @override
  ConsumerState<ConsumerCollectionScreen> createState() =>
      _ConsumerCollectionScreenState();
}

class _ConsumerCollectionScreenState
    extends ConsumerState<ConsumerCollectionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ReviewEntity> _savedReviews = [];
  List<ProductEntity> _savedProducts = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (_loading) return;
    final authId = ref.read(consumerAuthIdProvider);
    setState(() => _error = null);
    if (authId == null || authId.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Log in to see collections';
      });
      return;
    }
    setState(() => _loading = true);
    try {
      final repo = ref.read(collectionRepositoryProvider);
      final revResult = await repo.getSavedReviews(authId);
      final prodResult = await repo.getSavedProducts(authId);
      if (!mounted) return;
      revResult.fold(
        (f) => setState(() => _error = normalizeNetworkErrorMessage(f.message)),
        (list) => setState(() => _savedReviews = list),
      );
      prodResult.fold(
        (f) => setState(
          () => _error = _error ?? normalizeNetworkErrorMessage(f.message),
        ),
        (list) => setState(() => _savedProducts = list),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = normalizeNetworkErrorMessage(e.toString()));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authId = ref.watch(consumerAuthIdProvider);
    final currentUser = authId != null && authId.isNotEmpty
        ? ref.watch(consumerByAuthIdProvider(authId)).value
        : null;
    final isOnlineAsync = ref.watch(isOnlineProvider);
    final isOnline = isOnlineAsync.value ?? false;

    final primaryTextColor = ConsumerTheme.primaryTextOf(context);
    final mutedColor = ConsumerTheme.mutedOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'COLLECTION',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: mutedColor,
            letterSpacing: 0.14,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Saved & liked',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: primaryTextColor,
          ),
        ),
        const SizedBox(height: 20),
        TabBar(
          controller: _tabController,
          labelColor: primaryTextColor,
          unselectedLabelColor: mutedColor,
          indicatorColor: ConsumerTheme.accent,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Saved reviews'),
            Tab(text: 'Saved products'),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
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
                          onPressed: _load,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _savedReviews.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.bookmark_border_rounded,
                                    size: 64,
                                    color: ConsumerTheme.muted,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No saved reviews yet',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: ConsumerTheme.primaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Save reviews from the home feed to find them here.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: ConsumerTheme.muted,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 20),
                                  FilledButton.icon(
                                    onPressed: _load,
                                    icon: const Icon(
                                      Icons.refresh_rounded,
                                      size: 20,
                                    ),
                                    label: const Text('Refresh'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.builder(
                              padding: const EdgeInsets.only(bottom: 40),
                              itemCount: _savedReviews.length,
                              itemBuilder: (context, i) {
                                final review = _savedReviews[i];
                                final isOwnReview =
                                    authId != null && review.authorId == authId;
                                final authorDisplayName = isOwnReview
                                    ? currentUser?.displayName
                                    : null;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.06,
                                          ),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ReviewCard(
                                      review: review,
                                      currentUserId: authId,
                                      authorName: authorDisplayName,
                                      isSaved: true,
                                      isOnline: isOnline,
                                      onTap: (r, authorName) async {
                                        final connected = await ref
                                            .read(networkInfoProvider)
                                            .isConnected;
                                        if (!mounted) return;
                                        ReviewDetailDialog.show(
                                          context,
                                          r,
                                          authorName: authorName,
                                          isOnline: connected,
                                        );
                                      },
                                      onLikeChanged: () {},
                                      onLikeChangedWithState: (isNowLiked) {
                                        if (!mounted || authId == null) return;
                                        setState(() {
                                          final idx = _savedReviews.indexWhere(
                                            (e) => e.id == review.id,
                                          );
                                          if (idx >= 0) {
                                            final r = _savedReviews[idx];
                                            final newLikedBy = isNowLiked
                                                ? [...r.likedBy, authId]
                                                : r.likedBy
                                                      .where(
                                                        (id) => id != authId,
                                                      )
                                                      .toList();
                                            _savedReviews =
                                                List.from(_savedReviews)
                                                  ..[idx] = r.copyWith(
                                                    likedBy: newLikedBy,
                                                    likes:
                                                        r.likes +
                                                        (isNowLiked ? 1 : -1),
                                                  );
                                          }
                                        });
                                      },
                                      onSaveChanged: () async {
                                        if (authId == null) return;
                                        await ref
                                            .read(collectionRepositoryProvider)
                                            .unsaveReview(authId, review.id);
                                        if (mounted)
                                          setState(() {
                                            _savedReviews = _savedReviews
                                                .where((r) => r.id != review.id)
                                                .toList();
                                          });
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                    _savedProducts.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    size: 64,
                                    color: mutedColor,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No saved products yet',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: primaryTextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Save products from Explore to find them here.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: mutedColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 20),
                                  FilledButton.icon(
                                    onPressed: _load,
                                    icon: const Icon(
                                      Icons.refresh_rounded,
                                      size: 20,
                                    ),
                                    label: const Text('Refresh'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.builder(
                              padding: const EdgeInsets.only(bottom: 40),
                              itemCount: _savedProducts.length,
                              itemBuilder: (context, i) {
                                final product = _savedProducts[i];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.06,
                                          ),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: SizedBox(
                                        height: 220,
                                        child: ProductCard(
                                          product: product,
                                          currentUserId: authId,
                                          isSaved: true,
                                          onTap: () => ProductDetailDialog.show(
                                            context,
                                            product,
                                          ),
                                          onLikeChanged: () {},
                                          onSaveChanged: () async {
                                            if (authId == null) return;
                                            await ref
                                                .read(
                                                  collectionRepositoryProvider,
                                                )
                                                .unsaveProduct(
                                                  authId,
                                                  product.id,
                                                );
                                            if (mounted)
                                              setState(() {
                                                _savedProducts = _savedProducts
                                                    .where(
                                                      (p) => p.id != product.id,
                                                    )
                                                    .toList();
                                              });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ],
                ),
        ),
      ],
    );
  }
}
