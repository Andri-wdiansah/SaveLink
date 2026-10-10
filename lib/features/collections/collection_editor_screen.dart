import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/app_providers.dart';
import '../../models/collection_item.dart';
import '../../shared/widgets/state_views.dart';

/// Create or edit a collection. Pops `true` when the row was written.
class CollectionEditorScreen extends ConsumerStatefulWidget {
  final CollectionItem? existing;

  const CollectionEditorScreen({super.key, this.existing});

  @override
  ConsumerState<CollectionEditorScreen> createState() =>
      _CollectionEditorScreenState();
}

class _CollectionEditorScreenState
    extends ConsumerState<CollectionEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name ?? '');
    _description =
        TextEditingController(text: widget.existing?.description ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    final now = DateTime.now().toIso8601String();
    final repo = ref.read(appRepositoryProvider);
    final item = CollectionItem(
      id: widget.existing?.id,
      name: _name.text.trim(),
      description: _description.text.trim(),
      createdAt: widget.existing?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      if (_isEditing) {
        await repo.updateCollection(item);
      } else {
        await repo.saveCollection(item);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit collection' : 'New collection'),
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
              controller: _name,
              autofocus: !_isEditing,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g. Flutter reading',
                prefixIcon: Icon(Icons.folder_open_rounded),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'A name is required'
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
          ],
        ),
      ),
    );
  }
}
