import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/features/consumer/presentation/shell/consumer_shell.dart';
import 'package:yayvo/features/consumer/data/repositories/review_repository_impl.dart';
import 'package:yayvo/features/consumer/data/repositories/collection_repository_impl.dart';
import 'package:yayvo/features/consumer/domain/entities/review_entity.dart';
import 'package:yayvo/features/consumer/domain/usecases/get_reviews_paginated.dart';
import 'package:yayvo/features/consumer/presentation/theme/consumer_theme.dart';
import 'package:yayvo/features/consumer/presentation/widgets/review_card.dart';
import 'package:yayvo/features/consumer/presentation/widgets/review_detail_dialog.dart';
import 'package:yayvo/core/utils/network_error_helper.dart';

final getReviewsPaginatedProvider = Provider<GetReviewsPaginated>((ref) {
  return GetReviewsPaginated(ref.read(reviewRepositoryProvider));
});

const int _pageSize = 10;

class ConsumerHomeScreen extends ConsumerStatefulWidget {
  const ConsumerHomeScreen({super.key});

  @override
  ConsumerState<ConsumerHomeScreen> createState() => _ConsumerHomeScreenState();
}

class _ConsumerHomeScreenState extends ConsumerState<ConsumerHomeScreen> {
  final ScrollController _scrollController = ScrollController();
  List<ReviewEntity> _reviews = [];
  Set<String> _savedReviewIds = {};
  int _page = 1;
  bool _hasMore = true;
  bool _loading = false;
  bool _loadingMore = false;
  bool _didInitialLoad = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_didInitialLoad && mounted) {
        _didInitialLoad = true;
        _loadPage(1);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPage(int page) async {
    if (page > 1 && (_loadingMore || !_hasMore)) return;
    if (page == 1 && _loading) return;
    if (page == 1) {
      setState(() {
        _loading = true;
        _error = null;
      });
    } else {
      setState(() => _loadingMore = true);
    }
    try {
      final authId = ref.read(consumerAuthIdProvider);
      final usecase = ref.read(getReviewsPaginatedProvider);
      final result = await usecase.call({'page': page, 'size': _pageSize});
      Set<String> savedIds = _savedReviewIds;
      if (authId != null && authId.isNotEmpty && page == 1) {
        try {
          final repo = ref.read(collectionRepositoryProvider);
          final savedResult = await repo.getSavedReviews(authId);
          savedIds = savedResult.fold((_) => <String>{}, (list) => list.map((r) => r.id).toSet());
        } catch (_) {}
      }
      if (!mounted) return;
      result.fold(
        (f) => setState(() {
          _loading = false;
          _loadingMore = false;
          _error = normalizeNetworkErrorMessage(f.message);
          if (page == 1) _reviews = [];
        }),
        (paginated) => setState(() {
          if (page == 1) {
            _reviews = paginated.items;
            _savedReviewIds = savedIds;
          } else {
            _reviews = [..._reviews, ...paginated.items];
          }
          _hasMore = paginated.hasMore;
          _page = page;
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
        _error = page == 1 ? normalizeNetworkErrorMessage(e.toString()) : _error;
        if (page == 1) _reviews = [];
      });
    }
  }

  Future<void> _loadMore() {
    if (!_hasMore || _loadingMore || _loading) return Future.value();
    return _loadPage(_page + 1);
  }

  Future<void> _refresh() async {
    _page = 1;
    _hasMore = true;
    await _loadPage(1);
  }

  @override
  Widget build(BuildContext context) {
    final authId = ref.watch(consumerAuthIdProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Text(
          'DISCOVER',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: ConsumerTheme.muted,
            letterSpacing: 0.14,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Reviews',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: ConsumerTheme.primaryText,
            letterSpacing: -0.03,
          ),
        ),
        if (_reviews.isNotEmpty && !_loading)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${_reviews.length} review${_reviews.length == 1 ? '' : 's'}',
              style: TextStyle(
                fontSize: 12,
                color: ConsumerTheme.muted,
              ),
            ),
          ),
        const SizedBox(height: 16),
        Expanded(
          child: _loading && _reviews.isEmpty
              ? _buildSkeleton()
              : _error != null && _reviews.isEmpty
                  ? _buildError()
                  : _reviews.isEmpty
                      ? _buildEmpty()
                      : RefreshIndicator(
                          onRefresh: _refresh,
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.only(bottom: 40),
                            itemCount: _reviews.length + (_loadingMore || _hasMore ? 1 : 0),
                            itemBuilder: (context, i) {
                              if (i >= _reviews.length) {
                                if (_loadingMore) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                }
                                if (_hasMore) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Center(
                                      child: TextButton.icon(
                                        onPressed: _loadingMore ? null : () => _loadMore(),
                                        icon: const Icon(Icons.refresh_rounded, size: 20),
                                        label: const Text('Load more reviews'),
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              }
                              final review = _reviews[i];
                              final isSaved = _savedReviewIds.contains(review.id);
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
                                      isSaved: isSaved,
                                      onTap: (r, authorName) =>
                                          ReviewDetailDialog.show(context, r, authorName: authorName),
                                      onLikeChanged: () {},
                                      onLikeChangedWithState: (isNowLiked) {
                                        if (!mounted || authId == null) return;
                                        setState(() {
                                          final idx = _reviews.indexWhere((e) => e.id == review.id);
                                          if (idx >= 0) {
                                            final r = _reviews[idx];
                                            final newLikedBy = isNowLiked
                                                ? [...r.likedBy, authId]
                                                : r.likedBy.where((id) => id != authId).toList();
                                            _reviews = List.from(_reviews)
                                              ..[idx] = r.copyWith(
                                                likedBy: newLikedBy,
                                                likes: r.likes + (isNowLiked ? 1 : -1),
                                              );
                                          }
                                        });
                                      },
                                      onSaveChanged: () async {
                                        if (authId == null) return;
                                        final repo = ref.read(collectionRepositoryProvider);
                                        final result = isSaved
                                            ? await repo.unsaveReview(authId, review.id)
                                            : await repo.saveReview(authId, review.id);
                                        result.fold((_) {}, (_) {
                                          if (mounted) setState(() {
                                            if (isSaved) {
                                              _savedReviewIds = {..._savedReviewIds}..remove(review.id);
                                            } else {
                                              _savedReviewIds = {..._savedReviewIds, review.id};
                                            }
                                          });
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

  Widget _buildSkeleton() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 40),
      children: List.generate(
        3,
        (i) => Container(
          margin: const EdgeInsets.only(bottom: 20),
          height: 320,
          decoration: BoxDecoration(
            color: ConsumerTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ConsumerTheme.border),
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8F5),
            border: Border.all(color: ConsumerTheme.errorBorder),
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
              Text(_error!, style: TextStyle(color: ConsumerTheme.error)),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => _refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return RefreshIndicator(
      onRefresh: _refresh,
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
                    color: ConsumerTheme.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Be the first to share a review.',
                  style: TextStyle(color: ConsumerTheme.muted, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
