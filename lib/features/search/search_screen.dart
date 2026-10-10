import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/providers/app_providers.dart';
import '../../models/link_item.dart';
import '../../models/note_item.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/state_views.dart';
import '../links/link_editor_screen.dart';

/// Search tab: queries SQLite directly (links + notes) instead of faking rows.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;

  AsyncValue<List<LinkItem>> _linkResults = const AsyncData(<LinkItem>[]);
  AsyncValue<List<NoteItem>> _noteResults = const AsyncData(<NoteItem>[]);
  bool _hasQuery = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () => _run(value));
  }

  Future<void> _run(String rawQuery) async {
    final query = rawQuery.trim();
    if (query.isEmpty) {
      setState(() {
        _hasQuery = false;
        _linkResults = const AsyncData(<LinkItem>[]);
        _noteResults = const AsyncData(<NoteItem>[]);
      });
      return;
    }

    setState(() {
      _hasQuery = true;
      _linkResults = const AsyncLoading();
      _noteResults = const AsyncLoading();
    });

    final repo = ref.read(appRepositoryProvider);
    final links = await AsyncValue.guard(() => repo.searchLinks(query));
    final notes = await AsyncValue.guard(() => repo.searchNotes(query));
    if (!mounted) return;
    setState(() {
      _linkResults = links;
      _noteResults = notes;
    });
  }

  Future<void> _openLink(LinkItem link) async {
    final uri = Uri.tryParse(link.url);
    if (uri == null) {
      showErrorSnackBar(context, 'Invalid URL: ${link.url}');
      return;
    }
    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        showErrorSnackBar(context, 'No app can open ${link.url}');
      }
    } catch (error) {
      if (!mounted) return;
      showErrorSnackBar(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loading = _linkResults.isLoading || _noteResults.isLoading;
    final error = _linkResults.error ?? _noteResults.error;

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: _onChanged,
              onSubmitted: _run,
              decoration: InputDecoration(
                hintText: 'Search links, notes and tags…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear',
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _controller.clear();
                          _run('');
                        },
                      ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: !_hasQuery
                ? const EmptyStateView(
                    icon: Icons.search,
                    title: 'Search your library',
                    message:
                        'Type a few letters to find saved links, notes and tags. '
                        'Results come straight from the local database.',
                  )
                : loading
                    ? const LoadingView(message: 'Searching…')
                    : error != null
                        ? ErrorStateView(
                            error: error,
                            onRetry: () => _run(_controller.text),
                          )
                        : _buildResults(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(ThemeData theme) {
    final links = _linkResults.value ?? const <LinkItem>[];
    final notes = _noteResults.value ?? const <NoteItem>[];

    if (links.isEmpty && notes.isEmpty) {
      return EmptyStateView(
        icon: Icons.search_off,
        title: 'No matches',
        message: 'Nothing matched "${_controller.text.trim()}". '
            'Try a different word or save something new.',
        actionLabel: 'Save a link',
        onAction: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LinkEditorScreen(
              initialUrl: _controller.text.trim(),
            ),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        if (links.isNotEmpty) const SectionHeader(title: 'Links'),
        for (final link in links)
          GlassCard(
            onTap: () => _openLink(link),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  link.title,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  link.url,
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
    );
  }
}
