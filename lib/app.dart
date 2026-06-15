import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/locale_provider.dart';
import 'ui/screens/language_picker_screen.dart';
import 'ui/screens/main_screen.dart';

class MahjongApp extends ConsumerWidget {
  const MahjongApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Mahjong Counter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: locale == null ? const LanguagePickerScreen() : const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
