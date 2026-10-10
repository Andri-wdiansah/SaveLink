import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/collection_item.dart';
import '../../models/link_item.dart';
import '../../models/note_item.dart';
import '../repositories/repository.dart';

/// Single source of truth for data access. Overridable in tests.
final appRepositoryProvider = Provider<AppRepository>((ref) => AppRepository());

/// All saved links (active + archived). Filtering happens in the UI.
final linksProvider = FutureProvider<List<LinkItem>>(
  (ref) => ref.watch(appRepositoryProvider).links(),
);

/// All saved notes (active + archived).
final notesProvider = FutureProvider<List<NoteItem>>(
  (ref) => ref.watch(appRepositoryProvider).notes(),
);

/// All collections.
final collectionsProvider = FutureProvider<List<CollectionItem>>(
  (ref) => ref.watch(appRepositoryProvider).collections(),
);

/// Invalidate every cached query so all screens see fresh database contents
/// after a write or delete.
void refreshAllData(WidgetRef ref) {
  ref.invalidate(linksProvider);
  ref.invalidate(notesProvider);
  ref.invalidate(collectionsProvider);
}
