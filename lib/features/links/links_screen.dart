import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/utils/formatters.dart';
import '../../data/providers/app_providers.dart';
import '../../models/link_item.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/state_views.dart';
import 'link_editor_screen.dart';

/// Links tab: browse, filter, open, edit, archive and delete saved links.
class LinksScreen extends ConsumerStatefulWidget {
  const LinksScreen({super.key});

  @override
  ConsumerState<LinksScreen> createState() => _LinksScreenState();
}

enum _LinkFilter { all, favorites, archived }

class _LinksScreenState extends ConsumerState<LinksScreen> {
  _LinkFilter _filter = _LinkFilter.all;

  Future<void> _openEditor({LinkItem? existing}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => LinkEditorScreen(existing: existing)),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(existing == null ? 'Link saved' : 'Link updated')),
      );
    }
  }

  Future<void> _toggleFlag(LinkItem item, {bool? favorite, bool? archived}) async {
    final repo = ref.read(appRepositoryProvider);
    try {
      await repo.updateLink(
        item.copyWith(
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

  Future<void> _delete(LinkItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete link?'),
        content: Text('"${item.title}" will be removed permanently.'),
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
      await ref.read(appRepositoryProvider).deleteLink(item.id!);
      refreshAllData(ref);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Link deleted')));
    } catch (error) {
      if (!mounted) return;
      showErrorSnackBar(context, error);
    }
  }

  Future<void> _open(LinkItem item) async {
    final uri = Uri.tryParse(item.url);
    if (uri == null) {
      showErrorSnackBar(context, 'Invalid URL: ${item.url}');
      return;
    }
    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        showErrorSnackBar(context, 'No app can open ${item.url}');
      }
    } catch (error) {
      if (!mounted) return;
      showErrorSnackBar(context, error);
    }
  }

  List<LinkItem> _apply(List<LinkItem> items) {
    switch (_filter) {
      case _LinkFilter.all:
        return items.where((item) => !item.archived).toList();
      case _LinkFilter.favorites:
        return items.where((item) => item.favorite && !item.archived).toList();
      case _LinkFilter.archived:
        return items.where((item) => item.archived).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final links = ref.watch(linksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Links'),
        actions: [
          IconButton(
            tooltip: 'Reload',
            onPressed: () => ref.invalidate(linksProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add),
        label: const Text('New link'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SegmentedButton<_LinkFilter>(
              segments: const [
                ButtonSegment(
                  value: _LinkFilter.all,
                  label: Text('All'),
                  icon: Icon(Icons.list_alt),
                ),
                ButtonSegment(
                  value: _LinkFilter.favorites,
                  label: Text('Favorites'),
                  icon: Icon(Icons.star_outline),
                ),
                ButtonSegment(
                  value: _LinkFilter.archived,
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
            child: links.when(
              loading: () => const LoadingView(message: 'Loading your links…'),
              error: (error, _) => ErrorStateView(
                error: error,
                onRetry: () => ref.invalidate(linksProvider),
              ),
              data: (items) {
                final visible = _apply(items);
                if (visible.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.link_rounded,
                    title: switch (_filter) {
                      _LinkFilter.all => 'No links saved yet',
                      _LinkFilter.favorites => 'No favorites yet',
                      _LinkFilter.archived => 'Nothing archived',
                    },
                    message: switch (_filter) {
                      _LinkFilter.all =>
                        'Save a link to keep it safe and find it later. Everything stays on this device.',
                      _LinkFilter.favorites =>
                        'Tap the star on a link to pin it here for quick access.',
                      _LinkFilter.archived =>
                        'Archived links are hidden from the main list but never deleted.',
                    },
                    actionLabel: _filter == _LinkFilter.all ? 'Add a link' : null,
                    onAction: _filter == _LinkFilter.all ? () => _openEditor() : null,
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 96),
                  itemCount: visible.length,
                  itemBuilder: (context, index) {
                    final item = visible[index];
                    return _LinkCard(
                      item: item,
                      onOpen: () => _open(item),
                      onFavorite: () =>
                          _toggleFlag(item, favorite: !item.favorite),
                      onEdit: () => _openEditor(existing: item),
                      onArchive: () =>
                          _toggleFlag(item, archived: !item.archived),
                      onDelete: () => _delete(item),
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

/// A single link row with star, open, edit, archive and delete affordances.
class _LinkCard extends StatelessWidget {
  final LinkItem item;
  final VoidCallback onOpen;
  final VoidCallback onFavorite;
  final VoidCallback onEdit;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  const _LinkCard({
    required this.item,
    required this.onOpen,
    required this.onFavorite,
    required this.onEdit,
    required this.onArchive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      onTap: onOpen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                tooltip: item.favorite ? 'Remove favorite' : 'Add favorite',
                onPressed: onFavorite,
                icon: Icon(
                  item.favorite ? Icons.star : Icons.star_outline,
                  color: item.favorite ? theme.colorScheme.primary : null,
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
                    child: Text(item.archived ? 'Restore' : 'Archive'),
                  ),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
          Text(
            urlHost(item.url),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          if (item.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(item.description, style: theme.textTheme.bodyMedium),
          ],
          if (parseTags(item.tags).isNotEmpty) ...[
            const SizedBox(height: 10),
            TagChips(tags: parseTags(item.tags)),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.schedule, size: 14, color: theme.colorScheme.outline),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  formatTimestamp(item.updatedAt),
                  style: theme.textTheme.labelSmall,
                ),
              ),
              if (item.archived)
                const Text('Archived', style: TextStyle(fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
