import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/collections/collections_screen.dart';
import 'features/home/home_screen.dart';
import 'features/links/links_screen.dart';
import 'features/notes/notes_screen.dart';
import 'features/settings/theme_provider.dart';
import 'shared/components/share_intent_listener.dart';

class SaveLinkApp extends ConsumerWidget {
  const SaveLinkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themePreferenceProvider);
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

/// Bottom navigation shell. Each tab keeps its own state via [IndexedStack].
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    LinksScreen(),
    NotesScreen(),
    CollectionsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ShareIntentListener(
      child: Scaffold(
        body: IndexedStack(index: _index, children: _screens),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(icon: Icon(Icons.link), label: 'Links'),
            NavigationDestination(icon: Icon(Icons.note), label: 'Notes'),
            NavigationDestination(
              icon: Icon(Icons.folder_open_rounded),
              label: 'Collections',
            ),
          ],
        ),
      ),
    );
  }
}
