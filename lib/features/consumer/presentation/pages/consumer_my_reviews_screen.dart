import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/features/consumer/presentation/shell/consumer_shell.dart';
import 'package:yayvo/features/consumer/domain/entities/review_entity.dart';
import 'package:yayvo/features/consumer/presentation/theme/consumer_theme.dart';
import 'package:yayvo/features/consumer/presentation/widgets/review_card.dart';
import 'package:yayvo/features/consumer/presentation/widgets/review_detail_dialog.dart';
import 'package:yayvo/features/consumer/data/repositories/review_repository_impl.dart';
import 'package:yayvo/features/consumer/presentation/providers/consumer_providers.dart';
import 'package:yayvo/core/services/connectivity/network_info.dart';

/// Full-screen page showing the current user's reviews, with back button.
class ConsumerMyReviewsScreen extends ConsumerStatefulWidget {
  const ConsumerMyReviewsScreen({super.key});

  @override
  ConsumerState<ConsumerMyReviewsScreen> createState() =>
      _ConsumerMyReviewsScreenState();
}

class _ConsumerMyReviewsScreenState
    extends ConsumerState<ConsumerMyReviewsScreen> {
  List<ReviewEntity> _reviews = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final authId = ref.read(consumerAuthIdProvider);
    if (authId == null || authId.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Not logged in';
      });
      return;
    }
    // Use the consumer document _id as authorId — the backend stores reviews
    // keyed to the consumer doc _id, not the auth _id.
    final consumerProfile = ref.read(consumerByAuthIdProvider(authId)).value;
    final effectiveAuthorId = consumerProfile?.id ?? authId;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(reviewRepositoryProvider);
      final result = await repo.getReviewsByAuthor(effectiveAuthorId);
      if (!mounted) return;
      result.fold(
        (f) => setState(() {
          _reviews = [];
          _loading = false;
          _error = f.message;
        }),
        (list) => setState(() {
          _reviews = list;
          _loading = false;
          _error = null;
        }),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _reviews = [];
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authId = ref.watch(consumerAuthIdProvider);
    final currentUser = authId != null && authId.isNotEmpty
        ? ref.watch(consumerByAuthIdProvider(authId)).value
        : null;
    final displayName = currentUser?.displayName ?? 'You';
    final isOnline = ref.watch(isOnlineProvider).value ?? false;

    return Scaffold(
      backgroundColor: ConsumerTheme.backgroundOf(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'My Reviews',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: ConsumerTheme.primaryTextOf(context),
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: _loading && _reviews.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _error != null && _reviews.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 48,
                          color: ConsumerTheme.mutedOf(context),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: ConsumerTheme.bodyTextOf(context),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _load,
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _reviews.isEmpty
              ? SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 48),
                        Icon(
                          Icons.rate_review_outlined,
                          size: 64,
                          color: ConsumerTheme.mutedOf(context),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No reviews yet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: ConsumerTheme.primaryTextOf(context),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Reviews you create will appear here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: ConsumerTheme.mutedOf(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: _reviews.length,
                  itemBuilder: (context, index) {
                    final review = _reviews[index];
                    final maxW = MediaQuery.sizeOf(context).width > 600
                        ? 480.0
                        : 380.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxW),
                          child: ReviewCard(
                            review: review,
                            currentUserId: authId,
                            authorName: displayName,
                            isOnline: isOnline,
                            onTap: (r, authorName) async {
                              final connected = await ref
                                  .read(networkInfoProvider)
                                  .isConnected;
                              if (!context.mounted) return;
                              await ReviewDetailDialog.show(
                                context,
                                r,
                                authorName: authorName,
                                isOwner: true,
                                isOnline: connected,
                                onDeleted: () => _load(),
                                onUpdated: (updated) {
                                  if (!mounted) return;
                                  setState(() {
                                    final i = _reviews.indexWhere(
                                      (rev) => rev.id == r.id,
                                    );
                                    if (i >= 0) {
                                      _reviews = List.from(_reviews)
                                        ..[i] = updated;
                                    }
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
