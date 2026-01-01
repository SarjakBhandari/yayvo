import 'package:flutter/material.dart';

enum SnackBarStatus { success, warning, error }

void showMySnackBar({
  required BuildContext context,
  required String message,
  required SnackBarStatus status,
}) {
  final theme = Theme.of(context);

  // Pick colors from the app theme
  late Color backgroundColor;
  late Color textColor;

  switch (status) {
    case SnackBarStatus.success:
      backgroundColor = theme.colorScheme.primaryContainer;
      textColor = theme.colorScheme.onPrimaryContainer;
      break;
    case SnackBarStatus.warning:
      backgroundColor = theme.colorScheme.tertiaryContainer;
      textColor = theme.colorScheme.onTertiaryContainer;
      break;
    case SnackBarStatus.error:
      backgroundColor = theme.colorScheme.errorContainer;
      textColor = theme.colorScheme.onErrorContainer;
      break;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(color: textColor),
      ),
      duration: const Duration(seconds: 4),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
    ),
  );
}