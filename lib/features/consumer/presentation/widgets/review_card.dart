import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:yayvo/core/utils/image_url_helper.dart';
import 'package:yayvo/features/consumer/domain/entities/review_entity.dart';
import 'package:yayvo/features/consumer/presentation/theme/consumer_theme.dart';
import 'package:yayvo/features/consumer/presentation/providers/consumer_providers.dart';
import 'package:yayvo/features/consumer/data/repositories/review_repository_impl.dart';

class ReviewCard extends ConsumerWidget {
  const ReviewCard({
    super.key,
    required this.review,
    this.currentUserId,
    this.authorName,
    this.authorHandle,
    this.authorImageUrl,
    this.onLikeChanged,
    this.onSaveChanged,
    this.onTap,
    this.onLikeChangedWithState,
    this.isLiked = false,
    this.isSaved = false,
    this.isOnline = true,
  });

  final ReviewEntity review;
  final String? currentUserId;
  final String? authorName;
  final String? authorHandle;
  final String? authorImageUrl;
  final VoidCallback? onLikeChanged;
  final VoidCallback? onSaveChanged;
  /// When set, tapping the card (e.g. image/content) opens detail view. Called with (review, displayName).
  final void Function(ReviewEntity review, String? authorName)? onTap;
  /// Called after like/unlike with the new liked state so parent can update review in list.
  final void Function(bool isNowLiked)? onLikeChangedWithState;
  final bool isLiked;
  final bool isSaved;
  /// When false, like button is disabled (e.g. offline).
  final bool isOnline;

  String _imageUrl(ReviewEntity r) => imageUrlFromPath(r.imageUrl);

  /// Try doc id then auth id so author shows whether backend uses _id or authId.
  String _displayName(WidgetRef ref) {
    if (authorName != null && authorName!.isNotEmpty) return authorName!;
    final async = ref.watch(consumerForReviewAuthorProvider(review.authorId));
    final consumer = async.value;
    if (consumer != null && consumer.displayName.isNotEmpty) return consumer.displayName;
    return 'User';
  }

  String _displayHandle(WidgetRef ref) {
    if (authorHandle != null) return authorHandle!.startsWith('@') ? authorHandle! : '@$authorHandle';
    final async = ref.watch(consumerForReviewAuthorProvider(review.authorId));
    final consumer = async.value;
    if (consumer != null) {
      if (consumer.username != null && consumer.username!.isNotEmpty) {
        final u = consumer.username!.trim();
        return u.startsWith('@') ? u : '@$u';
      }
      if (consumer.displayName.isNotEmpty) return '@${consumer.displayName.split(' ').first}';
    }
    return '';
  }

  String _authorImageUrl(WidgetRef ref) {
    if (authorImageUrl != null && authorImageUrl!.isNotEmpty) {
      final u = imageUrlFromPath(authorImageUrl);
      return u.isNotEmpty ? u : authorImageUrl!;
    }
    final async = ref.watch(consumerForReviewAuthorProvider(review.authorId));
    final consumer = async.value;
    if (consumer?.profilePicture != null && consumer!.profilePicture!.isNotEmpty) return imageUrlFromPath(consumer.profilePicture);
    return '';
  }

  String get _dateStr {
    if (review.createdAt == null) return '';
    final d = review.createdAt!;
    return '${_month(d.month)} ${d.day}, ${d.year}';
  }

  static String _month(int m) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[m - 1];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayName = _displayName(ref);
    final displayHandle = _displayHandle(ref);
    final authorImg = _authorImageUrl(ref);
    final imageUrl = _imageUrl(review);
    final isLikedAsync = currentUserId != null && currentUserId!.isNotEmpty
        ? ref.watch(isReviewLikedProvider('${review.id}|$currentUserId'))
        : null;
    // Prefer async value when available; else use likedBy from API; fallback to isLiked prop
    final bool fromApi = currentUserId != null &&
        currentUserId!.isNotEmpty &&
        review.likedBy.contains(currentUserId);
    final isLikedVal = isLikedAsync?.value ?? fromApi || isLiked;
    final initials = displayName
        .split(' ')
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s[0].toUpperCase())
        .join();
    return Material(
      color: ConsumerTheme.surfaceOf(context),
      borderRadius: BorderRadius.circular(12),
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ConsumerTheme.borderOf(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: ConsumerTheme.accent,
                    backgroundImage: authorImg.isNotEmpty
                        ? CachedNetworkImageProvider(authorImg)
                        : null,
                    child: authorImg.isEmpty
                        ? Text(
                            initials.isEmpty ? 'U' : initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            fontSize: 10,
                          ),
                        )
                        : null,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: ConsumerTheme.primaryTextOf(context),
                          ),
                        ),
                        if (displayHandle.isNotEmpty)
                          Text(
                            displayHandle,
                            style: TextStyle(
                              fontSize: 10,
                              color: ConsumerTheme.mutedOf(context),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (_dateStr.isNotEmpty)
                    Text(
                      _dateStr,
                      style: TextStyle(
                        fontSize: 9,
                        color: ConsumerTheme.mutedOf(context),
                        letterSpacing: 0.04,
                      ),
                    ),
                ],
              ),
            ),
            // Image
            GestureDetector(
              onTap: onTap != null
                  ? () => onTap!(review, displayName)
                  : null,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(0),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: imageUrl.isEmpty
                      ? Container(
                          color: ConsumerTheme.primaryTextOf(context),
                          child: review.productName != null
                              ? Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: ConsumerTheme.surfaceOf(context)
                                            .withOpacity(0.92),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Text(
                                        review.productName!,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: ConsumerTheme.bodyTextOf(context),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : null,
                        )
                      : CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: ConsumerTheme.primaryTextOf(context),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: ConsumerTheme.primaryTextOf(context),
                          ),
                        ),
                ),
              ),
            ),
            // Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: currentUserId != null && isOnline
                        ? () async {
                            if (currentUserId == null) return;
                            final repo = ref.read(reviewRepositoryProvider);
                            final wasLiked = isLikedVal;
                            // Optimistic update (like /temp): update UI first, then call API; revert on failure
                            onLikeChangedWithState?.call(!wasLiked);
                            onLikeChanged?.call();
                            final result = wasLiked
                                ? await repo.unlikeReview(review.id, currentUserId!)
                                : await repo.likeReview(review.id, currentUserId!);
                            result.fold(
                              (_) {
                                // Revert on failure
                                onLikeChangedWithState?.call(wasLiked);
                              },
                              (_) {
                                ref.invalidate(
                                    isReviewLikedProvider('${review.id}|$currentUserId'));
                              },
                            );
                          }
                        : null,
                    icon: Icon(
                      Icons.favorite_rounded,
                      size: 16,
                      color: isLikedVal ? ConsumerTheme.error : ConsumerTheme.bodyTextOf(context),
                      fill: isLikedVal ? 1.0 : 0,
                    ),
                    label: Text(
                      isLikedVal ? 'Liked (${review.likes})' : 'Like (${review.likes})',
                      style: TextStyle(
                        fontSize: 12,
                        color: isLikedVal
                            ? ConsumerTheme.error
                            : ConsumerTheme.bodyTextOf(context),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: ConsumerTheme.bodyTextOf(context),
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: currentUserId != null ? onSaveChanged : null,
                    icon: Icon(
                      Icons.bookmark_rounded,
                      size: 16,
                      color: isSaved
                          ? ConsumerTheme.primaryTextOf(context)
                          : ConsumerTheme.bodyTextOf(context),
                      fill: isSaved ? 1.0 : 0,
                    ),
                    label: Text(
                      isSaved ? 'Saved' : 'Save',
                      style: TextStyle(
                        fontSize: 12,
                        color: isSaved
                            ? ConsumerTheme.primaryTextOf(context)
                            : ConsumerTheme.bodyTextOf(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (review.title.isNotEmpty)
                    Text(
                      review.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: ConsumerTheme.primaryTextOf(context),
                        letterSpacing: -0.02,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (review.title.isNotEmpty) const SizedBox(height: 3),
                  if (review.description.isNotEmpty)
                    Text(
                      review.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: ConsumerTheme.bodyTextOf(context),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (review.sentiments.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 3,
                      runSpacing: 3,
                      children: review.sentiments
                          .map((s) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: ConsumerTheme.borderLightOf(context),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  '#$s',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w500,
                                    color: ConsumerTheme.bodyTextOf(context),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
