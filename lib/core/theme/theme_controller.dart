import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeModeKey = 'theme_mode';

final themePreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

class ThemeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    ref.listen<AsyncValue<SharedPreferences>>(themePreferencesProvider, (
      _,
      next,
    ) {
      next.whenData((prefs) {
        final savedMode = prefs.getString(_themeModeKey);
        if (savedMode == null) {
          return;
        }

        state = ThemeMode.values.firstWhere(
          (mode) => mode.name == savedMode,
          orElse: () => ThemeMode.system,
        );
      });
    });

    return ThemeMode.system;
  }

  Future<void> toggleDarkMode(bool enabled) async {
    state = enabled ? ThemeMode.dark : ThemeMode.light;
    final prefs = await ref.read(themePreferencesProvider.future);
    await prefs.setString(_themeModeKey, state.name);
  }

  Future<void> useSystemMode() async {
    state = ThemeMode.system;
    final prefs = await ref.read(themePreferencesProvider.future);
    await prefs.setString(_themeModeKey, state.name);
  }
}

final themeControllerProvider = NotifierProvider<ThemeController, ThemeMode>(
  ThemeController.new,
);
