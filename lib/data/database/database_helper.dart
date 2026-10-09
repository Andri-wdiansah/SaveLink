import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/link_item.dart';
import '../../models/note_item.dart';
import '../../models/collection_item.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();
  Future<Database> get database async => _database ??= await _initDB('savelink.db');
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }
  Future _createDB(Database db, int version) async {
    await db.execute('CREATE TABLE links (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, url TEXT, description TEXT DEFAULT \'\', tags TEXT DEFAULT \'\', collection_id INTEGER, favorite INTEGER DEFAULT 0, pinned INTEGER DEFAULT 0, archived INTEGER DEFAULT 0, created_at TEXT, updated_at TEXT)');
    await db.execute('CREATE TABLE notes (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, content TEXT, tags TEXT DEFAULT \'\', collection_id INTEGER, favorite INTEGER DEFAULT 0, pinned INTEGER DEFAULT 0, archived INTEGER DEFAULT 0, created_at TEXT, updated_at TEXT)');
    await db.execute('CREATE TABLE tags (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT UNIQUE, created_at TEXT)');
    await db.execute('CREATE TABLE collections (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, description TEXT DEFAULT \'\', created_at TEXT, updated_at TEXT)');
  }
  Future<int> insertLink(LinkItem item) async => (await instance.database).insert('links', item.toMap());
  Future<List<LinkItem>> getLinks({bool? archived}) async => (await (await instance.database).query('links', where: archived == null ? null : 'archived = ?', whereArgs: archived == null ? null : [archived ? 1 : 0])).map((m) => LinkItem.fromMap(m)).toList();
  Future<int> updateLink(LinkItem item) async => (await instance.database).update('links', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  Future<int> deleteLink(int id) async => (await instance.database).delete('links', where: 'id = ?', whereArgs: [id]);
  Future<int> insertNote(NoteItem item) async => (await instance.database).insert('notes', item.toMap());
  Future<List<NoteItem>> getNotes({bool? archived}) async => (await (await instance.database).query('notes', where: archived == null ? null : 'archived = ?', whereArgs: archived == null ? null : [archived ? 1 : 0])).map((m) => NoteItem.fromMap(m)).toList();
  Future<int> updateNote(NoteItem item) async => (await instance.database).update('notes', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  Future<int> deleteNote(int id) async => (await instance.database).delete('notes', where: 'id = ?', whereArgs: [id]);
  Future<int> insertCollection(CollectionItem item) async => (await instance.database).insert('collections', item.toMap());
  Future<List<CollectionItem>> getCollections() async => (await (await instance.database).query('collections')).map((m) => CollectionItem.fromMap(m)).toList();
  Future<int> updateCollection(CollectionItem item) async => (await instance.database).update('collections', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  Future<int> deleteCollection(int id) async {
    final db = await instance.database;
    await db.update('links', {'collection_id': null}, where: 'collection_id = ?', whereArgs: [id]);
    await db.update('notes', {'collection_id': null}, where: 'collection_id = ?', whereArgs: [id]);
    return await db.delete('collections', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<LinkItem>> searchLinks(String query) async {
    final db = await instance.database;
    final like = '%$query%';
    final results = await db.query('links', where: 'title LIKE ? OR url LIKE ? OR description LIKE ? OR tags LIKE ?', whereArgs: [like, like, like, like]);
    return results.map((m) => LinkItem.fromMap(m)).toList();
  }
  Future<List<NoteItem>> searchNotes(String query) async {
    final db = await instance.database;
    final like = '%$query%';
    final results = await db.query('notes', where: 'title LIKE ? OR content LIKE ? OR tags LIKE ?', whereArgs: [like, like, like]);
    return results.map((m) => NoteItem.fromMap(m)).toList();
  }
  Future close() async => (await instance.database).close();
}
