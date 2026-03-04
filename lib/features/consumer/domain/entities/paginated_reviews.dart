import 'review_entity.dart';

class PaginatedReviews {
  const PaginatedReviews({
    required this.items,
    required this.hasMore,
  });

  final List<ReviewEntity> items;
  final bool hasMore;
}
