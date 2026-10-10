import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/formatters.dart';
import '../../data/providers/app_providers.dart';
import '../../models/note_item.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/state_views.dart';
import 'note_editor_screen.dart';

/// Notes tab: browse, filter, edit, archive and delete notes.
class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

enum _NoteFilter { all, favorites, archived }

class _NotesScreenState extends ConsumerState<NotesScreen> {
  _NoteFilter _filter = _NoteFilter.all;

  Future<void> _openEditor({NoteItem? existing}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => NoteEditorScreen(existing: existing)),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(existing == null ? 'Note saved' : 'Note updated')),
      );
    }
  }

  Future<void> _toggleFlag(NoteItem note,
      {bool? favorite, bool? archived}) async {
    try {
      await ref.read(appRepositoryProvider).updateNote(
            note.copyWith(
              favorite: favorite,
              archived: archived,
              updatedAt: DateTime.now().toIso8601String(),
            ),
          );
      refreshAllData(ref);
    } catch (error) {
      if (!mounted) return;
      showErrorSnackBar(context, error);
    }
  }

  Future<void> _delete(NoteItem note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete note?'),
        content: Text('"${note.title}" will be removed permanently.'),
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
      await ref.read(appRepositoryProvider).deleteNote(note.id!);
      refreshAllData(ref);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Note deleted')));
    } catch (error) {
      if (!mounted) return;
      showErrorSnackBar(context, error);
    }
  }

  List<NoteItem> _apply(List<NoteItem> items) {
    final filtered = switch (_filter) {
      _NoteFilter.all => items.where((note) => !note.archived),
      _NoteFilter.favorites =>
        items.where((note) => note.favorite && !note.archived),
      _NoteFilter.archived => items.where((note) => note.archived),
    };
    return filtered.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(notesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            tooltip: 'Reload',
            onPressed: () => ref.invalidate(notesProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add),
        label: const Text('New note'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SegmentedButton<_NoteFilter>(
              segments: const [
                ButtonSegment(
                  value: _NoteFilter.all,
                  label: Text('All'),
                  icon: Icon(Icons.list_alt),
                ),
                ButtonSegment(
                  value: _NoteFilter.favorites,
                  label: Text('Favorites'),
                  icon: Icon(Icons.star_outline),
                ),
                ButtonSegment(
                  value: _NoteFilter.archived,
                  label: Text('Archived'),
                  icon: Icon(Icons.archive_outlined),
                ),
              ],
              selected: {_filter},
              onSelectionChanged: (selection) =>
                  setState(() => _filter = selection.first),
            ),
          ),
          Expanded(
            child: notes.when(
              loading: () => const LoadingView(message: 'Loading your notes…'),
              error: (error, _) => ErrorStateView(
                error: error,
                onRetry: () => ref.invalidate(notesProvider),
              ),
              data: (items) {
                final visible = _apply(items);
                if (visible.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.note_alt_outlined,
                    title: switch (_filter) {
                      _NoteFilter.all => 'No notes yet',
                      _NoteFilter.favorites => 'No favorite notes',
                      _NoteFilter.archived => 'Nothing archived',
                    },
                    message: switch (_filter) {
                      _NoteFilter.all =>
                        'Jot down an idea, a recipe or a reminder. Notes are stored offline and searchable.',
                      _NoteFilter.favorites =>
                        'Tap the star on a note to keep it within reach.',
                      _NoteFilter.archived =>
                        'Archived notes are hidden from the main list but never deleted.',
                    },
                    actionLabel:
                        _filter == _NoteFilter.all ? 'Write a note' : null,
                    onAction:
                        _filter == _NoteFilter.all ? () => _openEditor() : null,
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 96),
                  itemCount: visible.length,
                  itemBuilder: (context, index) {
                    final note = visible[index];
                    return _NoteCard(
                      note: note,
                      onEdit: () => _openEditor(existing: note),
                      onFavorite: () =>
                          _toggleFlag(note, favorite: !note.favorite),
                      onArchive: () =>
                          _toggleFlag(note, archived: !note.archived),
                      onDelete: () => _delete(note),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// A single note row with star, edit, archive and delete affordances.
class _NoteCard extends StatelessWidget {
  final NoteItem note;
  final VoidCallback onEdit;
  final VoidCallback onFavorite;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  const _NoteCard({
    required this.note,
    required this.onEdit,
    required this.onFavorite,
    required this.onArchive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      onTap: onEdit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  note.title,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                tooltip: note.favorite ? 'Remove favorite' : 'Add favorite',
                onPressed: onFavorite,
                icon: Icon(
                  note.favorite ? Icons.star : Icons.star_outline,
                  color: note.favorite ? theme.colorScheme.primary : null,
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit();
                    case 'archive':
                      onArchive();
                    case 'delete':
                      onDelete();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(
                    value: 'archive',
                    child: Text(note.archived ? 'Restore' : 'Archive'),
                  ),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
          if (note.content.isNotEmpty)
            Text(
              note.content,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
          if (parseTags(note.tags).isNotEmpty) ...[
            const SizedBox(height: 10),
            TagChips(tags: parseTags(note.tags)),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.schedule, size: 14, color: theme.colorScheme.outline),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  formatTimestamp(note.updatedAt),
                  style: theme.textTheme.labelSmall,
                ),
              ),
              if (note.archived)
                const Text('Archived', style: TextStyle(fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
