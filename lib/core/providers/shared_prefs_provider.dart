import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/storage/storage_service.dart';

// ====================== SHARED PREFERENCES PROVIDER ======================

/// Must be overridden in main.dart before runApp()
final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('storageServiceProvider must be overridden');
});
