import 'package:flutter/material.dart';
import 'package:yayvo/features/consumer/presentation/theme/consumer_theme.dart';

const List<SentimentOption> kSentimentOptions = [
  SentimentOption(key: 'calm', label: 'Calm', emoji: '🌊'),
  SentimentOption(key: 'cozy', label: 'Cozy', emoji: '🕯️'),
  SentimentOption(key: 'happy', label: 'Happy', emoji: '😊'),
  SentimentOption(key: 'excited', label: 'Excited', emoji: '🚀'),
  SentimentOption(key: 'sad', label: 'Sad', emoji: '🌧️'),
  SentimentOption(key: 'minimal', label: 'Minimal', emoji: '◻️'),
  SentimentOption(key: 'disappointed', label: 'Disappointed', emoji: '😞'),
  SentimentOption(key: 'nostalgic', label: 'Nostalgic', emoji: '📷'),
  SentimentOption(key: 'beauty', label: 'Beauty', emoji: '✨'),
  SentimentOption(key: 'satisfied', label: 'Satisfied', emoji: '🙌'),
];

class SentimentOption {
  const SentimentOption({
    required this.key,
    required this.label,
    required this.emoji,
  });
  final String key;
  final String label;
  final String emoji;
}

class SentimentPicker extends StatelessWidget {
  const SentimentPicker({
    super.key,
    required this.selected,
    required this.onChange,
  });

  final List<String> selected;
  final ValueChanged<List<String>> onChange;

  void _toggle(String key) {
    if (selected.contains(key)) {
      onChange(selected.where((s) => s != key).toList());
    } else {
      onChange([...selected, key]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final surfaceColor = ConsumerTheme.surfaceOf(context);
    final primaryTextColor = ConsumerTheme.primaryTextOf(context);
    final bodyTextColor = ConsumerTheme.bodyTextOf(context);
    final borderColor = ConsumerTheme.borderOf(context);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: kSentimentOptions.map((s) {
        final isActive = selected.contains(s.key);
        return GestureDetector(
          onTap: () => _toggle(s.key),
          child: Container(
            width: 104,
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isActive ? primaryTextColor : borderColor,
                width: isActive ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Text(s.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 8),
                Text(
                  s.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                    color: isActive ? primaryTextColor : bodyTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (isActive)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFC9A96E), Color(0xFF8B6B3D)],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(16),
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 11),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
