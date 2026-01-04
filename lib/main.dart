// =============================================================================
// MAIN.DART
// =============================================================================
// Entry Point fuer ZCANTAG Web App
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'shared/core/storage/web_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Web Storage initialisieren
  await WebStorage.init();

  runApp(
    const ProviderScope(
      child: ZcantagWebApp(),
    ),
  );
}
