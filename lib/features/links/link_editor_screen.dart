import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../data/providers/app_providers.dart';
import '../../models/collection_item.dart';
import '../../models/link_item.dart';
import '../../shared/widgets/state_views.dart';

/// Create or edit a single link. Returns `true` through [Navigator.pop] when a
/// row was written so the caller can show a confirmation.
class LinkEditorScreen extends ConsumerStatefulWidget {
  final LinkItem? existing;
  final String? initialUrl;

  const LinkEditorScreen({super.key, this.existing, this.initialUrl});

  @override
  ConsumerState<LinkEditorScreen> createState() => _LinkEditorScreenState();
}

class _LinkEditorScreenState extends ConsumerState<LinkEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _url;
  late final TextEditingController _description;
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
    _url = TextEditingController(text: item?.url ?? widget.initialUrl ?? '');
    _description = TextEditingController(text: item?.description ?? '');
    _tags = TextEditingController(text: item?.tags ?? '');
    _collectionId = item?.collectionId;
    _favorite = item?.favorite ?? false;
  }

  @override
  void dispose() {
    _title.dispose();
    _url.dispose();
    _description.dispose();
    _tags.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    final now = DateTime.now().toIso8601String();
    final repo = ref.read(appRepositoryProvider);
    final item = LinkItem(
      id: widget.existing?.id,
      title: _title.text.trim(),
      url: normalizeUrl(_url.text),
      description: _description.text.trim(),
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
        await repo.updateLink(item);
      } else {
        await repo.saveLink(item);
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
        title: Text(_isEditing ? 'Edit link' : 'New link'),
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
              controller: _url,
              autofocus: !_isEditing,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'URL',
                hintText: 'https://example.com',
                prefixIcon: Icon(Icons.link),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'A URL is required';
                }
                if (!isValidUrl(value)) return 'Enter a valid URL';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _title,
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
              controller: _description,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _tags,
              decoration: const InputDecoration(
                labelText: 'Tags',
                hintText: 'work, flutter, read later',
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
