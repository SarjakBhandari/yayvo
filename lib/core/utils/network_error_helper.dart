/// Returns a user-friendly message when [errorMessage] is a network/Dio error.
String normalizeNetworkErrorMessage(String errorMessage) {
  final lower = errorMessage.toLowerCase();
  if (lower.contains('dio') ||
      lower.contains('socketexception') ||
      lower.contains('connection') ||
      lower.contains('connection refused') ||
      lower.contains('network is unreachable') ||
      lower.contains('failed host lookup') ||
      lower.contains('timed out') ||
      lower.contains('no internet')) {
    return 'No internet connection';
  }
  return errorMessage;
}

/// Returns true if [errorMessage] looks like a network/connectivity error.
bool isNetworkError(String errorMessage) {
  final lower = errorMessage.toLowerCase();
  return lower.contains('dio') ||
      lower.contains('socketexception') ||
      lower.contains('connection') ||
      lower.contains('connection refused') ||
      lower.contains('network is unreachable') ||
      lower.contains('failed host lookup') ||
      lower.contains('timed out') ||
      lower.contains('no internet') ||
      lower.contains('offline');
}
