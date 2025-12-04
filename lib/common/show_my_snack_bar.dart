import 'package:flutter/material.dart';

enum SnackBarStatus { success, warning, error }

void showMySnackBar({
  required BuildContext context,
  required String message,
  required SnackBarStatus status,
}) {
  // Pick color based on status
  Color backgroundColor;
  switch (status) {
    case SnackBarStatus.success:
      backgroundColor = Colors.green;
      break;
    case SnackBarStatus.warning:
      backgroundColor = Colors.yellow.shade700;
      break;
    case SnackBarStatus.error:
      backgroundColor = Colors.red;
      break;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 4),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
