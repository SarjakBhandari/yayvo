import 'package:flutter/material.dart';
import 'package:yayvo/features/consumer/presentation/theme/consumer_theme.dart';
import 'package:yayvo/features/consumer/presentation/shell/consumer_routes.dart';

class ConsumerSidebar extends StatelessWidget {
  const ConsumerSidebar({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
    required this.onLogout,
  });

  final ConsumerRoute currentRoute;
  final ValueChanged<ConsumerRoute> onNavigate;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo
          InkWell(
            onTap: () => onNavigate(ConsumerRoute.home),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Text(
                'YAYVO',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: ConsumerTheme.primaryText,
                  letterSpacing: -0.02,
                ),
              ),
            ),
          ),
          const SizedBox(height: 36),
          Text(
            'MENU',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: ConsumerTheme.muted,
              letterSpacing: 0.14,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: ConsumerRoute.values.map((route) {
                final active = currentRoute == route;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Material(
                    color: active
                        ? ConsumerTheme.primaryText
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => onNavigate(route),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 11,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              route.icon,
                              size: 17,
                              color: active
                                  ? ConsumerTheme.accent
                                  : ConsumerTheme.bodyText,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              route.label,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight:
                                    active ? FontWeight.w600 : FontWeight.w500,
                                color: active
                                    ? ConsumerTheme.surface
                                    : ConsumerTheme.bodyText,
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
          Divider(height: 1, color: ConsumerTheme.border),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout_rounded, size: 17),
            label: const Text('Log out'),
            style: OutlinedButton.styleFrom(
              foregroundColor: ConsumerTheme.muted,
              side: const BorderSide(color: ConsumerTheme.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
