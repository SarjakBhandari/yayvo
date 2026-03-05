import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/features/consumer/presentation/shell/consumer_shell.dart';
import 'package:yayvo/features/consumer/domain/entities/review_entity.dart';
import 'package:yayvo/features/consumer/presentation/theme/consumer_theme.dart';
import 'package:yayvo/features/consumer/presentation/widgets/review_card.dart';
import 'package:yayvo/features/consumer/presentation/widgets/review_detail_dialog.dart';
import 'package:yayvo/features/consumer/presentation/viewmodels/my_reviews_viewmodel.dart';
import 'package:yayvo/features/consumer/presentation/providers/consumer_providers.dart';
import 'package:yayvo/core/services/connectivity/network_info.dart';

/// Full-screen page showing the current user's reviews, with back button.
class ConsumerMyReviewsScreen extends ConsumerWidget {
  const ConsumerMyReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authId = ref.watch(consumerAuthIdProvider);
    final myReviewsState = ref.watch(myReviewsViewModelProvider);
    final myReviewsNotifier = ref.read(myReviewsViewModelProvider.notifier);
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
          onRefresh: () => myReviewsNotifier.refresh(authId ?? ''),
          child: myReviewsState.isLoading && myReviewsState.reviews.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : myReviewsState.error != null && myReviewsState.reviews.isEmpty
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
                          myReviewsState.error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: ConsumerTheme.bodyTextOf(context),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () =>
                              myReviewsNotifier.refresh(authId ?? ''),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : myReviewsState.reviews.isEmpty
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
                  itemCount: myReviewsState.reviews.length,
                  itemBuilder: (context, index) {
                    final review = myReviewsState.reviews[index];
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
                                onDeleted: () {
                                  myReviewsNotifier.removeReview(r.id);
                                },
                                onUpdated: (updated) {
                                  // Update the reviews list with the updated review
                                  final updated_reviews =
                                      List<ReviewEntity>.from(
                                        myReviewsState.reviews,
                                      );
                                  final i = updated_reviews.indexWhere(
                                    (rev) => rev.id == r.id,
                                  );
                                  if (i >= 0) {
                                    updated_reviews[i] = updated;
                                  }
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
