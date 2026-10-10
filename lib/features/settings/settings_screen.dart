import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themePreferenceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const ListTile(
              title: Text('Theme'), subtitle: Text('System, Light, Dark')),
          RadioGroup<ThemeMode>(
            groupValue: theme,
            onChanged: (ThemeMode? v) {
              if (v == null) return;
              ref.read(themePreferenceProvider.notifier).setTheme(v);
            },
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RadioListTile<ThemeMode>(
                  title: Text('System'),
                  value: ThemeMode.system,
                ),
                RadioListTile<ThemeMode>(
                  title: Text('Light'),
                  value: ThemeMode.light,
                ),
                RadioListTile<ThemeMode>(
                  title: Text('Dark'),
                  value: ThemeMode.dark,
                ),
              ],
            ),
          ),
          const Divider(),
          const ListTile(
              title: Text('Data'),
              subtitle: Text(
                  'All data is stored locally on your device. Google Drive backup will come in a future phase.')),
          const ListTile(
              title: Text('App'), subtitle: Text('SaveLink by domoiki v1.0.0')),
        ],
      ),
    );
  }
}
