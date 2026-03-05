import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/features/consumer/presentation/shell/consumer_shell.dart';
import 'package:yayvo/features/consumer/data/repositories/collection_repository_impl.dart';
import 'package:yayvo/features/consumer/presentation/theme/consumer_theme.dart';
import 'package:yayvo/features/consumer/presentation/widgets/review_card.dart';
import 'package:yayvo/features/consumer/presentation/widgets/review_detail_dialog.dart';
import 'package:yayvo/core/services/connectivity/network_info.dart';
import 'package:yayvo/features/consumer/presentation/providers/consumer_providers.dart';
import 'package:yayvo/features/consumer/presentation/viewmodels/home_viewmodel.dart';

class ConsumerHomeScreen extends ConsumerStatefulWidget {
  const ConsumerHomeScreen({super.key});

  @override
  ConsumerState<ConsumerHomeScreen> createState() => _ConsumerHomeScreenState();
}

class _ConsumerHomeScreenState extends ConsumerState<ConsumerHomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _didInitialLoad = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_didInitialLoad && mounted) {
        _didInitialLoad = true;
        ref.read(homeViewModelProvider.notifier).loadPage(1);
      }
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 500) {
      ref.read(homeViewModelProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeViewModelProvider);
    final authId = ref.watch(consumerAuthIdProvider);
    final currentUser = authId != null && authId.isNotEmpty
        ? ref.watch(consumerByAuthIdProvider(authId)).value
        : null;
    final isOnline = ref.watch(isOnlineProvider).value ?? false;

    ref.listen(reloadTriggerProvider, (prev, next) {
      if (prev != next && next > 0) {
        ref.read(homeViewModelProvider.notifier).loadPage(1);
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Text(
          'DISCOVER',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: ConsumerTheme.mutedOf(context),
            letterSpacing: 0.14,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Reviews',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: ConsumerTheme.primaryTextOf(context),
            letterSpacing: -0.03,
          ),
        ),
        if (homeState.reviews.isNotEmpty && !homeState.isLoading)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${homeState.reviews.length} review${homeState.reviews.length == 1 ? '' : 's'}',
              style: TextStyle(
                fontSize: 12,
                color: ConsumerTheme.mutedOf(context),
              ),
            ),
          ),
        const SizedBox(height: 16),
        Expanded(
          child: homeState.isLoading && homeState.reviews.isEmpty
              ? _buildSkeleton(context)
              : homeState.error != null && homeState.reviews.isEmpty
              ? _buildError(context)
              : homeState.reviews.isEmpty
              ? _buildEmpty(context)
              : RefreshIndicator(
                  onRefresh: () =>
                      ref.read(homeViewModelProvider.notifier).refresh(),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 40),
                    itemCount:
                        homeState.reviews.length +
                        (homeState.isLoadingMore || homeState.hasMore ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i >= homeState.reviews.length) {
                        if (homeState.isLoadingMore) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (homeState.hasMore) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Center(
                              child: TextButton.icon(
                                onPressed: homeState.isLoadingMore
                                    ? null
                                    : () => ref
                                          .read(homeViewModelProvider.notifier)
                                          .loadMore(),
                                icon: const Icon(
                                  Icons.refresh_rounded,
                                  size: 20,
                                ),
                                label: const Text('Load more reviews'),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }
                      final review = homeState.reviews[i];
                      final isSaved = homeState.savedReviewIds.contains(
                        review.id,
                      );
                      final isOwnReview =
                          authId != null && review.authorId == authId;
                      final authorDisplayName = isOwnReview
                          ? currentUser?.displayName
                          : null;
                      final width = MediaQuery.sizeOf(context).width;
                      final maxW = width > 600 ? 480.0 : 380.0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: maxW),
                            child: ReviewCard(
                              review: review,
                              currentUserId: authId,
                              authorName: authorDisplayName,
                              isSaved: isSaved,
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
                                // The view model can track this if needed
                              },
                              onSaveChanged: () async {
                                if (authId == null) return;
                                final repo = ref.read(
                                  collectionRepositoryProvider,
                                );
                                final result = isSaved
                                    ? await repo.unsaveReview(authId, review.id)
                                    : await repo.saveReview(authId, review.id);
                                result.fold((_) {}, (_) {
                                  ref
                                      .read(homeViewModelProvider.notifier)
                                      .updateSavedReview(review.id, !isSaved);
                                });
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 40),
      children: List.generate(
        3,
        (i) => Container(
          margin: const EdgeInsets.only(bottom: 20),
          height: 320,
          decoration: BoxDecoration(
            color: ConsumerTheme.surfaceOf(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ConsumerTheme.borderOf(context)),
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    final homeState = ref.watch(homeViewModelProvider);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ConsumerTheme.surfaceOf(context),
            border: Border.all(color: ConsumerTheme.borderOf(context)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Could not load reviews',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: ConsumerTheme.error,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                homeState.error ?? 'Unknown error',
                style: const TextStyle(color: ConsumerTheme.error),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () =>
                    ref.read(homeViewModelProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => ref.read(homeViewModelProvider.notifier).refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, size: 64, color: ConsumerTheme.accent),
                const SizedBox(height: 12),
                Text(
                  'Nothing here yet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: ConsumerTheme.primaryTextOf(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Be the first to share a review.',
                  style: TextStyle(
                    color: ConsumerTheme.mutedOf(context),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
