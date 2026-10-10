import '../database/database_helper.dart';
import '../../models/link_item.dart';
import '../../models/note_item.dart';
import '../../models/collection_item.dart';

class AppRepository {
  final DatabaseHelper db = DatabaseHelper.instance;
  Future<int> saveLink(LinkItem item) => db.insertLink(item);
  Future<List<LinkItem>> links({bool? archived}) =>
      db.getLinks(archived: archived);
  Future<int> updateLink(LinkItem item) => db.updateLink(item);
  Future<int> deleteLink(int id) => db.deleteLink(id);
  Future<int> saveNote(NoteItem item) => db.insertNote(item);
  Future<List<NoteItem>> notes({bool? archived}) =>
      db.getNotes(archived: archived);
  Future<int> updateNote(NoteItem item) => db.updateNote(item);
  Future<int> deleteNote(int id) => db.deleteNote(id);
  Future<int> saveCollection(CollectionItem item) => db.insertCollection(item);
  Future<List<CollectionItem>> collections() => db.getCollections();
  Future<int> updateCollection(CollectionItem item) =>
      db.updateCollection(item);
  Future<int> deleteCollection(int id) => db.deleteCollection(id);
  Future<List<LinkItem>> searchLinks(String query) => db.searchLinks(query);
  Future<List<NoteItem>> searchNotes(String query) => db.searchNotes(query);
}
