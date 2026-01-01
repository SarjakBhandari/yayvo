import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/services/hive/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive before app starts
  final hiveService = HiveService();
  await hiveService.init();

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
