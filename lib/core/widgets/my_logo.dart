import 'package:flutter/material.dart';

/// App logo used on splash, login, register, and welcome screens.
/// Prefers assets/images/logo.png (same as app icon and native splash); falls back to logo.jpg if needed.
class MyLogo extends StatelessWidget {
  final double size;
  final double? radius;

  const MyLogo({
    super.key,
    required this.size,
    this.radius,
  });

  static const String _assetPath = 'assets/images/logo.png';
  static const String _assetPathFallback = 'assets/images/logo.jpg';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(
          width: 2,
          color: theme.colorScheme.secondary,
        ),
        borderRadius: BorderRadius.circular(radius ?? 24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius ?? 24),
        child: Image.asset(
          _assetPath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Image.asset(
            _assetPathFallback,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                size: size * 0.5,
                color: theme.colorScheme.outline,
              ),
            ),
          ),
        ),
      ),
    );
  }
}