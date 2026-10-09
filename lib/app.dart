import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

class SaveLinkApp extends ConsumerWidget {
  const SaveLinkApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'SaveLink by domoiki',
      theme: lightGlassTheme(),
      darkTheme: darkGlassTheme(),
      themeMode: mode,
      home: const MainShell(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  @override
  Widget build(BuildContext context) {
    final screens = [const HomeScreen(), const LinksScreen(), const NotesScreen(), const CollectionsScreen()];
    return Scaffold(
      body: screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.link), label: 'Links'),
          NavigationDestination(icon: Icon(Icons.note), label: 'Notes'),
          NavigationDestination(icon: Icon(Icons.folder_open_rounded), label: 'Collections'),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('SaveLink')));
}
class LinksScreen extends StatelessWidget {
  const LinksScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Links')));
}
class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Notes')));
}
class CollectionsScreen extends StatelessWidget {
  const CollectionsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Collections')));
}
