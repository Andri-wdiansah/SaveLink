import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/app_providers.dart';
import '../../models/collection_item.dart';
import '../../models/link_item.dart';
import '../../models/note_item.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/state_views.dart';
import 'collection_detail_screen.dart';
import 'collection_editor_screen.dart';

/// Collections tab: group links and notes into named folders.
class CollectionsScreen extends ConsumerStatefulWidget {
  const CollectionsScreen({super.key});

  @override
  ConsumerState<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends ConsumerState<CollectionsScreen> {
  Future<void> _openEditor({CollectionItem? existing}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CollectionEditorScreen(existing: existing),
      ),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              existing == null ? 'Collection created' : 'Collection updated'),
        ),
      );
    }
  }

  Future<void> _delete(
      CollectionItem collection, int linkCount, int noteCount) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete collection?'),
        content: Text(
          '"${collection.name}" will be removed. '
          '${linkCount + noteCount} item(s) will stay saved but become unassigned.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(appRepositoryProvider).deleteCollection(collection.id!);
      refreshAllData(ref);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Collection deleted')));
    } catch (error) {
      if (!mounted) return;
      showErrorSnackBar(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final collections = ref.watch(collectionsProvider);
    // valueOrNull (not value) so a failing links/notes query cannot take the
    // whole screen down; the collections query itself drives the error state.
    final links = ref.watch(linksProvider).valueOrNull ?? const <LinkItem>[];
    final notes = ref.watch(notesProvider).valueOrNull ?? const <NoteItem>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Collections'),
        actions: [
          IconButton(
            tooltip: 'Reload',
            onPressed: () => refreshAllData(ref),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        // Tabs live in an IndexedStack, so every FAB needs its own hero tag.
        heroTag: 'collections-fab',
        icon: const Icon(Icons.create_new_folder_outlined),
        label: const Text('New'),
      ),
      body: collections.when(
        loading: () => const LoadingView(message: 'Loading collections…'),
        error: (error, _) => ErrorStateView(
          error: error,
          onRetry: () => ref.invalidate(collectionsProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return EmptyStateView(
              icon: Icons.folder_open_rounded,
              title: 'No collections yet',
              message:
                  'Collections group related links and notes, like "Flutter" or '
                  '"Recipes". Create one to keep your library tidy.',
              actionLabel: 'Create a collection',
              onAction: () => _openEditor(),
            );
          }
          final sorted = [...items]..sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final collection = sorted[index];
              final collectionLinks = links
                  .where((link) => link.collectionId == collection.id)
                  .toList();
              final collectionNotes = notes
                  .where((note) => note.collectionId == collection.id)
                  .toList();
              return _CollectionCard(
                collection: collection,
                linkCount: collectionLinks.length,
                noteCount: collectionNotes.length,
                onOpen: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CollectionDetailScreen(
                      collection: collection,
                      links: collectionLinks,
                      notes: collectionNotes,
                    ),
                  ),
                ),
                onEdit: () => _openEditor(existing: collection),
                onDelete: () => _delete(
                  collection,
                  collectionLinks.length,
                  collectionNotes.length,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  final CollectionItem collection;
  final int linkCount;
  final int noteCount;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CollectionCard({
    required this.collection,
    required this.linkCount,
    required this.noteCount,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      onTap: onOpen,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
            child: Icon(
              Icons.folder_open_rounded,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  collection.name,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (collection.description.isNotEmpty)
                  Text(
                    collection.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                const SizedBox(height: 4),
                Text(
                  '$linkCount link${linkCount == 1 ? '' : 's'} · '
                  '$noteCount note${noteCount == 1 ? '' : 's'}',
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  onEdit();
                case 'delete':
                  onDelete();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }
}
