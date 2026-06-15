import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../core/l10n/strings.dart';

class LocaleNotifier extends StateNotifier<AppLocale?> {
  LocaleNotifier(super.initial);

  Future<void> setLocale(AppLocale locale) async {
    state = locale;
    try {
      final dir = await getApplicationDocumentsDirectory();
      await File('${dir.path}/locale.txt').writeAsString(locale.name);
    } catch (_) {}
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, AppLocale?>(
  (ref) => LocaleNotifier(null),
);

final stringsProvider = Provider<AppStrings>((ref) {
  final locale = ref.watch(localeProvider);
  return locale == AppLocale.en ? AppStrings.en : AppStrings.fr;
});
