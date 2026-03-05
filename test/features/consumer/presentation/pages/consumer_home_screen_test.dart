import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yayvo/core/error/failures.dart';
import 'package:yayvo/core/services/connectivity/network_info.dart';
import 'package:yayvo/features/consumer/domain/entities/paginated_reviews.dart';
import 'package:yayvo/features/consumer/domain/entities/review_entity.dart';
import 'package:yayvo/features/consumer/domain/usecases/get_reviews_paginated.dart';
import 'package:yayvo/features/consumer/presentation/pages/consumer_home_screen.dart';
import 'package:yayvo/features/consumer/presentation/shell/consumer_shell.dart';
import 'package:yayvo/features/consumer/presentation/widgets/review_card.dart';
import 'package:yayvo/features/consumer/presentation/viewmodels/home_viewmodel.dart';

class MockGetReviewsPaginated extends Mock implements GetReviewsPaginated {}

final tReview1 = ReviewEntity(
  id: 'r1',
  title: 'Amazing sunscreen',
  description: 'SPF 50 and no white cast.',
  authorId: 'consumer1',
);

final tReview2 = ReviewEntity(
  id: 'r2',
  title: 'Lip balm review',
  description: 'Hydrating for dry weather.',
  authorId: 'consumer2',
);

Widget _buildScreen(MockGetReviewsPaginated usecase) {
  return ProviderScope(
    overrides: [
      getReviewsPaginatedProvider.overrideWithValue(usecase),
      consumerAuthIdProvider.overrideWith((ref) => null),
      isOnlineProvider.overrideWith((ref) async => true),
    ],
    child: const MaterialApp(
      home: Scaffold(body: SafeArea(child: ConsumerHomeScreen())),
    ),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  group('ConsumerHomeScreen baseline layout', () {
    testWidgets('shows DISCOVER label', (tester) async {
      final usecase = MockGetReviewsPaginated();
      when(() => usecase.call(any())).thenAnswer(
        (_) async => const Right(PaginatedReviews(items: [], hasMore: false)),
      );

      await tester.pumpWidget(_buildScreen(usecase));
      await tester.pumpAndSettle();

      expect(find.text('DISCOVER'), findsOneWidget);
    });

    testWidgets('shows Reviews heading', (tester) async {
      final usecase = MockGetReviewsPaginated();
      when(() => usecase.call(any())).thenAnswer(
        (_) async => const Right(PaginatedReviews(items: [], hasMore: false)),
      );

      await tester.pumpWidget(_buildScreen(usecase));
      await tester.pumpAndSettle();

      expect(find.text('Reviews'), findsOneWidget);
    });

    testWidgets('has a SafeArea wrapper', (tester) async {
      final usecase = MockGetReviewsPaginated();
      when(() => usecase.call(any())).thenAnswer(
        (_) async => const Right(PaginatedReviews(items: [], hasMore: false)),
      );

      await tester.pumpWidget(_buildScreen(usecase));
      await tester.pumpAndSettle();

      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('uses a Scaffold host', (tester) async {
      final usecase = MockGetReviewsPaginated();
      when(() => usecase.call(any())).thenAnswer(
        (_) async => const Right(PaginatedReviews(items: [], hasMore: false)),
      );

      await tester.pumpWidget(_buildScreen(usecase));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows a scrollable view in empty mode', (tester) async {
      final usecase = MockGetReviewsPaginated();
      when(() => usecase.call(any())).thenAnswer(
        (_) async => const Right(PaginatedReviews(items: [], hasMore: false)),
      );

      await tester.pumpWidget(_buildScreen(usecase));
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });

  group('ConsumerHomeScreen error state', () {
    testWidgets('shows error title when loading fails', (tester) async {
      final usecase = MockGetReviewsPaginated();
      when(() => usecase.call(any())).thenAnswer(
        (_) async =>
            const Left(ApiFailure(message: 'timeout', statusCode: 500)),
      );

      await tester.pumpWidget(_buildScreen(usecase));
      await tester.pumpAndSettle();

      expect(find.text('Could not load reviews'), findsOneWidget);
    });

    testWidgets('shows the failure message text', (tester) async {
      final usecase = MockGetReviewsPaginated();
      when(() => usecase.call(any())).thenAnswer(
        (_) async =>
            const Left(ApiFailure(message: 'timeout', statusCode: 500)),
      );

      await tester.pumpWidget(_buildScreen(usecase));
      await tester.pumpAndSettle();

      expect(find.textContaining('timeout'), findsOneWidget);
    });

    testWidgets('shows Retry button on error', (tester) async {
      final usecase = MockGetReviewsPaginated();
      when(() => usecase.call(any())).thenAnswer(
        (_) async =>
            const Left(ApiFailure(message: 'timeout', statusCode: 500)),
      );

      await tester.pumpWidget(_buildScreen(usecase));
      await tester.pumpAndSettle();

      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('retry button triggers another fetch', (tester) async {
      final usecase = MockGetReviewsPaginated();
      when(() => usecase.call(any())).thenAnswer(
        (_) async =>
            const Left(ApiFailure(message: 'timeout', statusCode: 500)),
      );

      await tester.pumpWidget(_buildScreen(usecase));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      verify(() => usecase.call(any())).called(greaterThanOrEqualTo(2));
    });

    testWidgets('keeps top headings visible in error mode', (tester) async {
      final usecase = MockGetReviewsPaginated();
      when(() => usecase.call(any())).thenAnswer(
        (_) async =>
            const Left(ApiFailure(message: 'timeout', statusCode: 500)),
      );

      await tester.pumpWidget(_buildScreen(usecase));
      await tester.pumpAndSettle();

      expect(find.text('DISCOVER'), findsOneWidget);
      expect(find.text('Reviews'), findsOneWidget);
    });
  });

  group('ConsumerHomeScreen empty state', () {
    testWidgets('shows empty title when no reviews are returned', (
      tester,
    ) async {
      final usecase = MockGetReviewsPaginated();
      when(() => usecase.call(any())).thenAnswer(
        (_) async => const Right(PaginatedReviews(items: [], hasMore: false)),
      );

      await tester.pumpWidget(_buildScreen(usecase));
      await tester.pumpAndSettle();

      expect(find.text('Nothing here yet'), findsOneWidget);
    });

    testWidgets('shows empty subtitle guidance', (tester) async {
      final usecase = MockGetReviewsPaginated();
      when(() => usecase.call(any())).thenAnswer(
        (_) async => const Right(PaginatedReviews(items: [], hasMore: false)),
      );

      await tester.pumpWidget(_buildScreen(usecase));
      await tester.pumpAndSettle();

      expect(find.text('Be the first to share a review.'), findsOneWidget);
    });

    testWidgets('shows the auto_awesome icon for empty mode', (tester) async {
      final usecase = MockGetReviewsPaginated();
      when(() => usecase.call(any())).thenAnswer(
        (_) async => const Right(PaginatedReviews(items: [], hasMore: false)),
      );

      await tester.pumpWidget(_buildScreen(usecase));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });

    testWidgets('wraps empty content with RefreshIndicator', (tester) async {
      final usecase = MockGetReviewsPaginated();
      when(() => usecase.call(any())).thenAnswer(
        (_) async => const Right(PaginatedReviews(items: [], hasMore: false)),
      );

      await tester.pumpWidget(_buildScreen(usecase));
      await tester.pumpAndSettle();

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('does not render review cards in empty mode', (tester) async {
      final usecase = MockGetReviewsPaginated();
      when(() => usecase.call(any())).thenAnswer(
        (_) async => const Right(PaginatedReviews(items: [], hasMore: false)),
      );

      await tester.pumpWidget(_buildScreen(usecase));
      await tester.pumpAndSettle();

      expect(find.byType(ReviewCard), findsNothing);
    });
  });

  group('ConsumerHomeScreen list state', () {
    testWidgets('renders review cards when reviews are available', (
      tester,
    ) async {
      final usecase = MockGetReviewsPaginated();
      when(() => usecase.call(any())).thenAnswer(
        (_) async => Right(
          PaginatedReviews(items: [tReview1, tReview2], hasMore: false),
        ),
      );

      await tester.pumpWidget(_buildScreen(usecase));
      await tester.pumpAndSettle();

      expect(find.byType(ReviewCard), findsNWidgets(2));
    });

    testWidgets('shows each review title in the list', (tester) async {
      final usecase = MockGetReviewsPaginated();
      when(() => usecase.call(any())).thenAnswer(
        (_) async => Right(
          PaginatedReviews(items: [tReview1, tReview2], hasMore: false),
        ),
      );

      await tester.pumpWidget(_buildScreen(usecase));
      await tester.pumpAndSettle();

      expect(find.text('Amazing sunscreen'), findsOneWidget);
      expect(find.text('Lip balm review'), findsOneWidget);
    });

    testWidgets('shows review count text for list mode', (tester) async {
      final usecase = MockGetReviewsPaginated();
      when(() => usecase.call(any())).thenAnswer(
        (_) async => Right(
          PaginatedReviews(items: [tReview1, tReview2], hasMore: false),
        ),
      );

      await tester.pumpWidget(_buildScreen(usecase));
      await tester.pumpAndSettle();

      expect(find.text('2 reviews'), findsOneWidget);
    });

    testWidgets('hides empty-state title in list mode', (tester) async {
      final usecase = MockGetReviewsPaginated();
      when(() => usecase.call(any())).thenAnswer(
        (_) async => Right(PaginatedReviews(items: [tReview1], hasMore: false)),
      );

      await tester.pumpWidget(_buildScreen(usecase));
      await tester.pumpAndSettle();

      expect(find.text('Nothing here yet'), findsNothing);
    });

    testWidgets('shows RefreshIndicator in list mode', (tester) async {
      final usecase = MockGetReviewsPaginated();
      when(() => usecase.call(any())).thenAnswer(
        (_) async => Right(PaginatedReviews(items: [tReview1], hasMore: false)),
      );

      await tester.pumpWidget(_buildScreen(usecase));
      await tester.pumpAndSettle();

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });
  });
}
