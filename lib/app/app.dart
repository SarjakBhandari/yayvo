import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/app/theme/themes.dart';
import 'package:yayvo/core/api/api_client.dart';
import 'package:yayvo/features/auth/presentation/pages/login_page.dart';
import 'package:yayvo/features/consumer/presentation/shell/consumer_shell.dart';
import 'package:yayvo/core/providers/theme_provider.dart';
import 'package:yayvo/core/services/storage/user_session_service.dart';
import 'package:yayvo/features/onboarding/presentation/pages/welcome_screen.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  bool _authCallbackSet = false;

  @override
  Widget build(BuildContext context) {
    if (!_authCallbackSet) {
      _authCallbackSet = true;
      final apiClient = ref.read(apiClientProvider);
      apiClient.setOnUnauthorized(() {
        ref.read(consumerAuthIdProvider.notifier).state = null;
        _navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      });
    }

    final themeMode = ref.watch(themeModeProvider);
    final session = ref.watch(userSessionServiceProvider).getUserSession();
    final isConsumerLoggedIn = session != null &&
        session.role.toLowerCase().contains('consumer');
    if (isConsumerLoggedIn && ref.read(consumerAuthIdProvider) == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(consumerAuthIdProvider.notifier).state = session.userId;
      });
    }

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Yayvo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: isConsumerLoggedIn ? const ConsumerShell() : const WelcomeScreen(),
    );
  }
}
