import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';

final themePreferenceProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) => ThemeNotifier());

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _load();
  }
  void setTheme(ThemeMode mode) {
    state = mode;
    SharedPreferences.getInstance().then((prefs) => prefs.setString('theme', mode.name));
  }
  void _load() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('theme');
    if (name == 'ThemeMode.dark') state = ThemeMode.dark;
    else if (name == 'ThemeMode.light') state = ThemeMode.light;
  }
}
