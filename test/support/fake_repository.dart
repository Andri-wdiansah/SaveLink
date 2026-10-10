import 'package:savelink/data/repositories/repository.dart';
import 'package:savelink/models/collection_item.dart';
import 'package:savelink/models/link_item.dart';
import 'package:savelink/models/note_item.dart';

/// In-memory [AppRepository] used by widget tests. Nothing here touches sqflite,
/// but the behaviour mirrors the real database (auto-increment ids, ordering,
/// unassigning items when a collection is deleted).
class FakeRepository extends AppRepository {
  final List<LinkItem> linkStore = [];
  final List<NoteItem> noteStore = [];
  final List<CollectionItem> collectionStore = [];

  /// When true every read/write throws, to exercise error states.
  bool failReads = false;
  bool failWrites = false;

  /// Optional gate to hold reads open and observe the loading state.
  Duration readDelay = Duration.zero;

  int _nextId = 0;
  int _newId() => ++_nextId;

  void _check(bool isWrite) {
    if (isWrite && failWrites) throw StateError('write failed');
    if (!isWrite && failReads) throw StateError('read failed');
  }

  @override
  Future<List<LinkItem>> links({bool? archived}) async {
    if (readDelay > Duration.zero) await Future<void>.delayed(readDelay);
    _check(false);
    final items = linkStore
        .where((item) => archived == null || item.archived == archived)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return items;
  }

  @override
  Future<List<NoteItem>> notes({bool? archived}) async {
    if (readDelay > Duration.zero) await Future<void>.delayed(readDelay);
    _check(false);
    final items = noteStore
        .where((item) => archived == null || item.archived == archived)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return items;
  }

  @override
  Future<List<CollectionItem>> collections() async {
    if (readDelay > Duration.zero) await Future<void>.delayed(readDelay);
    _check(false);
    return [...collectionStore];
  }

  @override
  Future<int> saveLink(LinkItem item) async {
    _check(true);
    final id = _newId();
    linkStore.add(_withId(item, id));
    return id;
  }

  @override
  Future<int> updateLink(LinkItem item) async {
    _check(true);
    final index = linkStore.indexWhere((stored) => stored.id == item.id);
    if (index == -1) throw StateError('link ${item.id} not found');
    linkStore[index] = item;
    return 1;
  }

  @override
  Future<int> deleteLink(int id) async {
    _check(true);
    linkStore.removeWhere((item) => item.id == id);
    return 1;
  }

  @override
  Future<int> saveNote(NoteItem item) async {
    _check(true);
    final id = _newId();
    noteStore.add(_noteWithId(item, id));
    return id;
  }

  @override
  Future<int> updateNote(NoteItem item) async {
    _check(true);
    final index = noteStore.indexWhere((stored) => stored.id == item.id);
    if (index == -1) throw StateError('note ${item.id} not found');
    noteStore[index] = item;
    return 1;
  }

  @override
  Future<int> deleteNote(int id) async {
    _check(true);
    noteStore.removeWhere((item) => item.id == id);
    return 1;
  }

  @override
  Future<int> saveCollection(CollectionItem item) async {
    _check(true);
    final id = _newId();
    collectionStore.add(_collectionWithId(item, id));
    return id;
  }

  @override
  Future<int> updateCollection(CollectionItem item) async {
    _check(true);
    final index = collectionStore.indexWhere((stored) => stored.id == item.id);
    if (index == -1) throw StateError('collection ${item.id} not found');
    collectionStore[index] = item;
    return 1;
  }

  @override
  Future<int> deleteCollection(int id) async {
    _check(true);
    collectionStore.removeWhere((item) => item.id == id);
    for (var i = 0; i < linkStore.length; i++) {
      final link = linkStore[i];
      if (link.collectionId == id) linkStore[i] = _clearCollection(link);
    }
    for (var i = 0; i < noteStore.length; i++) {
      final note = noteStore[i];
      if (note.collectionId == id) noteStore[i] = _clearNoteCollection(note);
    }
    return 1;
  }

  @override
  Future<List<LinkItem>> searchLinks(String query) async {
    _check(false);
    final needle = query.toLowerCase();
    return linkStore
        .where((item) =>
            item.title.toLowerCase().contains(needle) ||
            item.url.toLowerCase().contains(needle) ||
            item.tags.toLowerCase().contains(needle))
        .toList();
  }

  @override
  Future<List<NoteItem>> searchNotes(String query) async {
    _check(false);
    final needle = query.toLowerCase();
    return noteStore
        .where((item) =>
            item.title.toLowerCase().contains(needle) ||
            item.content.toLowerCase().contains(needle) ||
            item.tags.toLowerCase().contains(needle))
        .toList();
  }

  LinkItem _clearCollection(LinkItem item) => LinkItem(
        id: item.id,
        title: item.title,
        url: item.url,
        description: item.description,
        tags: item.tags,
        favorite: item.favorite,
        pinned: item.pinned,
        archived: item.archived,
        createdAt: item.createdAt,
        updatedAt: item.updatedAt,
      );

  NoteItem _clearNoteCollection(NoteItem item) => NoteItem(
        id: item.id,
        title: item.title,
        content: item.content,
        tags: item.tags,
        favorite: item.favorite,
        pinned: item.pinned,
        archived: item.archived,
        createdAt: item.createdAt,
        updatedAt: item.updatedAt,
      );

  LinkItem _withId(LinkItem item, int? id) => LinkItem(
        id: id,
        title: item.title,
        url: item.url,
        description: item.description,
        tags: item.tags,
        collectionId: item.collectionId,
        favorite: item.favorite,
        pinned: item.pinned,
        archived: item.archived,
        createdAt: item.createdAt,
        updatedAt: item.updatedAt,
      );

  NoteItem _noteWithId(NoteItem item, int? id) => NoteItem(
        id: id,
        title: item.title,
        content: item.content,
        tags: item.tags,
        collectionId: item.collectionId,
        favorite: item.favorite,
        pinned: item.pinned,
        archived: item.archived,
        createdAt: item.createdAt,
        updatedAt: item.updatedAt,
      );

  CollectionItem _collectionWithId(CollectionItem item, int? id) =>
      CollectionItem(
        id: id,
        name: item.name,
        description: item.description,
        createdAt: item.createdAt,
        updatedAt: item.updatedAt,
      );
}
