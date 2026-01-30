import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/core/providers/theme_provider.dart';

class ThemeSelector extends ConsumerWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(themeModeProvider);
    final notifier = ref.read(themeModeProvider.notifier);

    final primary = Theme.of(context).colorScheme.primary;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    // Fixed: Using consistent button styling
    final lightStyle = ElevatedButton.styleFrom(
      backgroundColor: currentMode == ThemeMode.light ? primary : null,
      foregroundColor: currentMode == ThemeMode.light ? onPrimary : null,
    );
    final darkStyle = ElevatedButton.styleFrom(
      backgroundColor: currentMode == ThemeMode.dark ? primary : null,
      foregroundColor: currentMode == ThemeMode.dark ? onPrimary : null,
    );
    final systemStyle = ElevatedButton.styleFrom(
      backgroundColor: currentMode == ThemeMode.system ? primary : null,
      foregroundColor: currentMode == ThemeMode.system ? onPrimary : null,
    );

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Theme', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => notifier.setThemeMode(ThemeMode.light),
                    style: lightStyle,
                    child: const Text('Light'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => notifier.setThemeMode(ThemeMode.dark),
                    style: darkStyle,
                    child: const Text('Dark'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => notifier.setThemeMode(ThemeMode.system),
                    style: systemStyle,
                    child: const Text('System'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}