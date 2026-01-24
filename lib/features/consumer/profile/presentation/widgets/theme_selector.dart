import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayvo/core/providers/theme_provider.dart';

class ThemeSelector extends ConsumerWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(themeModeProvider);
    final notifier = ref.read(themeModeProvider.notifier);

    Widget _button({
      required String label,
      required ThemeMode mode,
      required ButtonStyle style,
      required VoidCallback onPressed,
    }) {
      return Expanded(
        child: ElevatedButton(
          onPressed: onPressed,
          style: style,
          child: Text(label),
        ),
      );
    }

    final primary = Theme.of(context).colorScheme.primary;
    final lightStyle = ElevatedButton.styleFrom(
      backgroundColor: currentMode == ThemeMode.light ? primary : null,
    );
    final darkStyle = ElevatedButton.styleFrom(
      backgroundColor: currentMode == ThemeMode.dark ? primary : null,
    );
    final systemStyle = OutlinedButton.styleFrom();

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
                _button(
                  label: 'Light',
                  mode: ThemeMode.light,
                  style: lightStyle,
                  onPressed: () => notifier.setThemeMode(ThemeMode.light),
                ),
                const SizedBox(width: 8),
                _button(
                  label: 'Dark',
                  mode: ThemeMode.dark,
                  style: darkStyle,
                  onPressed: () => notifier.setThemeMode(ThemeMode.dark),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => notifier.setThemeMode(ThemeMode.system),
                    style: systemStyle,
                    child: const Text('System'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Spacer(),
                IconButton(
                  tooltip: currentMode == ThemeMode.dark ? 'Switch to light' : 'Switch to dark',
                  icon: Icon(currentMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
                  onPressed: () => notifier.toggleTheme(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
