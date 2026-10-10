import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/formatters.dart';
import '../../data/providers/app_providers.dart';
import '../../models/collection_item.dart';
import '../../models/note_item.dart';
import '../../shared/widgets/state_views.dart';

/// Create or edit a note. Pops `true` when the row was written.
class NoteEditorScreen extends ConsumerStatefulWidget {
  final NoteItem? existing;

  const NoteEditorScreen({super.key, this.existing});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _content;
  late final TextEditingController _tags;

  int? _collectionId;
  bool _favorite = false;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final item = widget.existing;
    _title = TextEditingController(text: item?.title ?? '');
    _content = TextEditingController(text: item?.content ?? '');
    _tags = TextEditingController(text: item?.tags ?? '');
    _collectionId = item?.collectionId;
    _favorite = item?.favorite ?? false;
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    _tags.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    final now = DateTime.now().toIso8601String();
    final repo = ref.read(appRepositoryProvider);
    final item = NoteItem(
      id: widget.existing?.id,
      title: _title.text.trim(),
      content: _content.text.trim(),
      tags: normalizeTags(_tags.text),
      collectionId: _collectionId,
      favorite: _favorite,
      pinned: widget.existing?.pinned ?? false,
      archived: widget.existing?.archived ?? false,
      createdAt: widget.existing?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      if (_isEditing) {
        await repo.updateNote(item);
      } else {
        await repo.saveNote(item);
      }
      if (!mounted) return;
      refreshAllData(ref);
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      showErrorSnackBar(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final collections = ref.watch(collectionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit note' : 'New note'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              autofocus: !_isEditing,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Title',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'A title is required'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _content,
              minLines: 6,
              maxLines: 14,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                labelText: 'Note',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _tags,
              decoration: const InputDecoration(
                labelText: 'Tags',
                hintText: 'ideas, shopping, work',
                prefixIcon: Icon(Icons.sell_outlined),
              ),
            ),
            const SizedBox(height: 12),
            collections.when(
              loading: () => const InputDecorator(
                decoration: InputDecoration(labelText: 'Collection'),
                child: LinearProgressIndicator(),
              ),
              error: (error, _) => Text(
                'Collections unavailable: $error',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              data: (items) => DropdownButtonFormField<int?>(
                initialValue: _collectionId,
                decoration: const InputDecoration(
                  labelText: 'Collection',
                  prefixIcon: Icon(Icons.folder_open_rounded),
                ),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('No collection'),
                  ),
                  for (final CollectionItem collection in items)
                    DropdownMenuItem<int?>(
                      value: collection.id,
                      child: Text(collection.name),
                    ),
                ],
                onChanged: (value) => setState(() => _collectionId = value),
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              value: _favorite,
              onChanged: (value) => setState(() => _favorite = value),
              title: const Text('Favorite'),
              secondary: const Icon(Icons.star_outline),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}
