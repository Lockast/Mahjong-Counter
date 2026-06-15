import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'core/database/app_database.dart';
import 'core/l10n/strings.dart';
import 'core/models/tile.dart';
import 'providers/database_provider.dart';
import 'providers/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Load tile catalog
  final catalogJson = await rootBundle.loadString('assets/tile_catalog.json');
  TileCatalog.init(jsonDecode(catalogJson) as Map<String, dynamic>);

  // Initialize database
  final db = AppDatabase();
  await db.init();

  // Load saved locale
  AppLocale? savedLocale;
  try {
    final dir = await getApplicationDocumentsDirectory();
    final f = File('${dir.path}/locale.txt');
    if (await f.exists()) {
      final s = await f.readAsString();
      savedLocale = s.trim() == 'en' ? AppLocale.en : AppLocale.fr;
    }
  } catch (_) {}

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        localeProvider.overrideWith((ref) => LocaleNotifier(savedLocale)),
      ],
      child: const MahjongApp(),
    ),
  );
}
