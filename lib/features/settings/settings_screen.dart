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
          ListTile(title: const Text('Theme'), subtitle: const Text('System, Light, Dark')),
          RadioListTile<ThemeMode>(title: const Text('System'), value: ThemeMode.system, groupValue: theme, onChanged: (v) => v != null ? ref.read(themePreferenceProvider.notifier).setTheme(v) : null),
          RadioListTile<ThemeMode>(title: const Text('Light'), value: ThemeMode.light, groupValue: theme, onChanged: (v) => v != null ? ref.read(themePreferenceProvider.notifier).setTheme(v) : null),
          RadioListTile<ThemeMode>(title: const Text('Dark'), value: ThemeMode.dark, groupValue: theme, onChanged: (v) => v != null ? ref.read(themePreferenceProvider.notifier).setTheme(v) : null),
          const Divider(),
          const ListTile(title: Text('Data'), subtitle: Text('All data is stored locally on your device. Google Drive backup will come in a future phase.')),
          const ListTile(title: Text('App'), subtitle: Text('SaveLink by domoiki v1.0.0')),
        ],
      ),
    );
  }
}
