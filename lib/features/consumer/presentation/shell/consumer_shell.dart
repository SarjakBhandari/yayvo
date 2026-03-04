import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:yayvo/core/services/sensors/proximity_theme_changer.dart';
import 'package:yayvo/features/consumer/presentation/theme/consumer_theme.dart';
import 'package:yayvo/features/consumer/presentation/shell/consumer_routes.dart';
import 'package:yayvo/features/consumer/data/repositories/consumer_repository_impl.dart';
import 'package:yayvo/features/consumer/domain/usecases/get_consumer_profile.dart';
import 'package:yayvo/features/consumer/presentation/pages/consumer_home_screen.dart';
import 'package:yayvo/features/consumer/presentation/pages/consumer_explore_screen.dart';
import 'package:yayvo/features/consumer/presentation/pages/consumer_create_review_screen.dart';
import 'package:yayvo/features/consumer/presentation/pages/consumer_profile_screen.dart';
import 'package:yayvo/features/consumer/presentation/pages/consumer_collection_screen.dart';
import 'package:yayvo/core/services/sensors/sensor_service.dart';
import 'package:yayvo/core/services/sensors/shake_detector.dart';
import 'package:yayvo/core/services/storage/user_session_service.dart';

final currentConsumerRouteProvider =
    StateProvider<ConsumerRoute>((ref) => ConsumerRoute.home);

/// Set after login; replace with reading from secure storage if needed.
final consumerAuthIdProvider = StateProvider<String?>((ref) => null);

final getConsumerProfileProvider = Provider<GetConsumerProfile>((ref) {
  return GetConsumerProfile(ref.read(consumerRepositoryProvider));
});

/// Increment to trigger reload on current screen (e.g. on shake).
final reloadTriggerProvider = StateProvider<int>((ref) => 0);

class ConsumerShell extends ConsumerStatefulWidget {
  const ConsumerShell({super.key});

  @override
  ConsumerState<ConsumerShell> createState() => _ConsumerShellState();
}

class _ConsumerShellState extends ConsumerState<ConsumerShell> {
  ShakeDetector? _shakeDetector;
  final Set<ConsumerRoute> _visitedTabs = {ConsumerRoute.home};
  final Map<ConsumerRoute, Widget> _tabWidgets = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreConsumerAuth();
      _initShakeDetector();
      _initProximityThemeChanger();
    });
  }

  void _initProximityThemeChanger() {
    ref.read(proximityThemeChangerProvider).startListening();
  }
  
  void _restoreConsumerAuth() {
    final current = ref.read(consumerAuthIdProvider);
    if (current != null && current.isNotEmpty) return;
    final session = ref.read(userSessionServiceProvider).getUserSession();
    if (session != null &&
        session.role.toLowerCase().contains('consumer')) {
      ref.read(consumerAuthIdProvider.notifier).state = session.userId;
    }
  }

  void _initShakeDetector() {
    final sensor = ref.read(sensorServiceProvider);
    _shakeDetector = ShakeDetector(
      onShake: () {
        if (!mounted) return;
        ref.read(reloadTriggerProvider.notifier).state++;
      },
      thresholdGravity: 18.0,
      slopTimeMs: 500,
    )..startListening(sensor.accelerometer);
  }

  @override
  void dispose() {
    _shakeDetector?.stopListening();
    ref.read(proximityThemeChangerProvider).stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final route = ref.watch(currentConsumerRouteProvider);
    ref.listen<ConsumerRoute>(currentConsumerRouteProvider, (prev, next) {
      if (next != prev) setState(() => _visitedTabs.add(next));
    });
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    return Scaffold(
      backgroundColor: ConsumerTheme.backgroundOf(context),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            isWide ? 24 : 16,
            8,
            isWide ? 24 : 16,
            8,
          ),
          child: _buildPage(route),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: ConsumerTheme.surfaceOf(context),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ConsumerRoute.values.map((r) {
                final selected = route == r;
                return Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        ref.read(currentConsumerRouteProvider.notifier).state = r;
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              r.icon,
                              size: 24,
                              color: selected
                                  ? ConsumerTheme.accent
                                  : ConsumerTheme.mutedOf(context),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              r.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                                color: selected
                                    ? ConsumerTheme.accent
                                    : ConsumerTheme.mutedOf(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage(ConsumerRoute route) {
    // Only build a tab's screen when it has been visited, so we don't load all 4 tabs at once.
    final index = ConsumerRoute.values.indexOf(route);
    return IndexedStack(
      index: index,
      children: List.generate(ConsumerRoute.values.length, (i) {
        final r = ConsumerRoute.values[i];
        if (!_visitedTabs.contains(r)) return const SizedBox.shrink();
        _tabWidgets[r] ??= _buildScreen(r);
        return _tabWidgets[r]!;
      }),
    );
  }

  Widget _buildScreen(ConsumerRoute r) {
    switch (r) {
      case ConsumerRoute.home:
        return const ConsumerHomeScreen();
      case ConsumerRoute.explore:
        return const ConsumerExploreScreen();
      case ConsumerRoute.create:
        return const ConsumerCreateReviewScreen();
      case ConsumerRoute.collection:
        return const ConsumerCollectionScreen();
      case ConsumerRoute.profile:
        return const ConsumerProfileScreen();
    }
  }
}
