import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/utils/formatters.dart';
import '../../models/collection_item.dart';
import '../../models/link_item.dart';
import '../../models/note_item.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/state_views.dart';

/// Read-only view of everything assigned to one collection.
class CollectionDetailScreen extends StatelessWidget {
  final CollectionItem collection;
  final List<LinkItem> links;
  final List<NoteItem> notes;

  const CollectionDetailScreen({
    super.key,
    required this.collection,
    required this.links,
    required this.notes,
  });

  Future<void> _open(BuildContext context, LinkItem link) async {
    final uri = Uri.tryParse(link.url);
    if (uri == null) {
      showErrorSnackBar(context, 'Invalid URL: ${link.url}');
      return;
    }
    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!context.mounted) return;
      if (!launched) showErrorSnackBar(context, 'No app can open ${link.url}');
    } catch (error) {
      if (!context.mounted) return;
      showErrorSnackBar(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(collection.name)),
      body: links.isEmpty && notes.isEmpty
          ? const EmptyStateView(
              icon: Icons.inbox_outlined,
              title: 'Nothing in this collection',
              message:
                  'Assign links or notes to this collection from their editor '
                  'and they will show up here.',
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                if (collection.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Text(
                      collection.description,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                if (links.isNotEmpty) const SectionHeader(title: 'Links'),
                for (final link in links)
                  GlassCard(
                    onTap: () => _open(context, link),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          link.title,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          urlHost(link.url),
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: theme.colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                if (notes.isNotEmpty) const SectionHeader(title: 'Notes'),
                for (final note in notes)
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.title,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (note.content.isNotEmpty)
                          Text(
                            note.content,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium,
                          ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
