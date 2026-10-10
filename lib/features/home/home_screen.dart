import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/formatters.dart';
import '../../data/providers/app_providers.dart';
import '../../models/link_item.dart';
import '../../models/note_item.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/state_views.dart';
import '../collections/collection_editor_screen.dart';
import '../links/link_editor_screen.dart';
import '../notes/note_editor_screen.dart';
import '../search/search_screen.dart';
import '../settings/settings_screen.dart';

/// Home tab: a real dashboard built from the local SQLite database.
/// Renders meaningful content (counts, recent items, quick actions) even when
/// the database is completely empty.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _open(BuildContext context, Widget screen) {
    return Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final links = ref.watch(linksProvider);
    final notes = ref.watch(notesProvider);
    final collections = ref.watch(collectionsProvider);
    final theme = Theme.of(context);

    final loading = links.isLoading && notes.isLoading && collections.isLoading;
    final error = links.error ?? notes.error ?? collections.error;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SaveLink'),
        actions: [
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () => _open(context, const SearchScreen()),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _open(context, const SettingsScreen()),
          ),
        ],
      ),
      body: loading
          ? const LoadingView(message: 'Opening your library…')
          : error != null
              ? ErrorStateView(
                  error: error,
                  onRetry: () => refreshAllData(ref),
                )
              : RefreshIndicator(
                  onRefresh: () async => refreshAllData(ref),
                  child: _HomeBody(
                    links: links.value ?? const <LinkItem>[],
                    notes: notes.value ?? const <NoteItem>[],
                    collectionCount: collections.value?.length ?? 0,
                    onNewLink: () => _open(context, const LinkEditorScreen()),
                    onNewNote: () => _open(context, const NoteEditorScreen()),
                    onNewCollection: () =>
                        _open(context, const CollectionEditorScreen()),
                    onOpenSearch: () => _open(context, const SearchScreen()),
                    theme: theme,
                  ),
                ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  final List<LinkItem> links;
  final List<NoteItem> notes;
  final int collectionCount;
  final VoidCallback onNewLink;
  final VoidCallback onNewNote;
  final VoidCallback onNewCollection;
  final VoidCallback onOpenSearch;
  final ThemeData theme;

  const _HomeBody({
    required this.links,
    required this.notes,
    required this.collectionCount,
    required this.onNewLink,
    required this.onNewNote,
    required this.onNewCollection,
    required this.onOpenSearch,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final activeLinks = links.where((l) => !l.archived).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final activeNotes = notes.where((n) => !n.archived).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final isEmpty = links.isEmpty && notes.isEmpty && collectionCount == 0;

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Text(
            'Save what matters.\nFind it when you need it.',
            style: theme.textTheme.titleLarge?.copyWith(height: 1.25),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Text(
            'Everything is stored offline on this device.',
            style: theme.textTheme.bodyMedium,
          ),
        ),
        Row(
          children: [
            Expanded(
              child: StatTile(
                icon: Icons.link_rounded,
                label: 'Links',
                value: activeLinks.length,
              ),
            ),
            Expanded(
              child: StatTile(
                icon: Icons.note_alt_outlined,
                label: 'Notes',
                value: activeNotes.length,
              ),
            ),
            Expanded(
              child: StatTile(
                icon: Icons.folder_open_rounded,
                label: 'Collections',
                value: collectionCount,
              ),
            ),
          ],
        ),
        const SectionHeader(title: 'Quick actions'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: onNewLink,
                icon: const Icon(Icons.add_link),
                label: const Text('New link'),
              ),
              FilledButton.tonalIcon(
                onPressed: onNewNote,
                icon: const Icon(Icons.note_add_outlined),
                label: const Text('New note'),
              ),
              OutlinedButton.icon(
                onPressed: onNewCollection,
                icon: const Icon(Icons.create_new_folder_outlined),
                label: const Text('New collection'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenSearch,
                icon: const Icon(Icons.search),
                label: const Text('Search'),
              ),
            ],
          ),
        ),
        if (isEmpty) ...[
          const SizedBox(height: 24),
          const EmptyStateView(
            icon: Icons.auto_awesome,
            title: 'Your library is empty',
            message:
                'Nothing has been saved yet. Start with a link, a quick note, '
                'or a collection — it will be here when you come back.',
          ),
        ] else ...[
          SectionHeader(
            title: 'Recent links',
            trailing: Text('${activeLinks.length}'),
          ),
          if (activeLinks.isEmpty)
            const _InlineEmpty(
                text: 'No active links. Archived items live in the Links tab.')
          else
            for (final link in activeLinks.take(5)) _RecentLinkCard(link: link),
          SectionHeader(
            title: 'Recent notes',
            trailing: Text('${activeNotes.length}'),
          ),
          if (activeNotes.isEmpty)
            const _InlineEmpty(
                text: 'No notes yet. Notes are perfect for quick thoughts.')
          else
            for (final note in activeNotes.take(5)) _RecentNoteCard(note: note),
        ],
      ],
    );
  }
}

class _InlineEmpty extends StatelessWidget {
  final String text;
  const _InlineEmpty({required this.text});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
      );
}

class _RecentLinkCard extends StatelessWidget {
  final LinkItem link;
  const _RecentLinkCard({required this.link});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            link.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            urlHost(link.url),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 8),
          TagChips(tags: parseTags(link.tags)),
        ],
      ),
    );
  }
}

class _RecentNoteCard extends StatelessWidget {
  final NoteItem note;
  const _RecentNoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (note.favorite)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(
                    Icons.star,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                ),
              Expanded(
                child: Text(
                  note.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          if (note.content.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              note.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 8),
          TagChips(tags: parseTags(note.tags)),
        ],
      ),
    );
  }
}
