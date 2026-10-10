import 'dart:ffi';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:savelink/data/database/database_helper.dart';
import 'package:savelink/models/collection_item.dart';
import 'package:savelink/models/link_item.dart';
import 'package:savelink/models/note_item.dart';
import 'package:sqlite3/open.dart' as sqlite3_open;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Exercises the real SQLite schema (no fakes) through sqflite's FFI backend.
/// Some Linux images only ship the versioned sqlite3 soname.
bool _loadSqliteLibrary() {
  for (final name in ['libsqlite3.so', 'libsqlite3.so.0']) {
    try {
      final library = DynamicLibrary.open(name);
      sqlite3_open.open
          .overrideFor(sqlite3_open.OperatingSystem.linux, () => library);
      return true;
    } catch (_) {
      // try the next candidate name
    }
  }
  return false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final sqliteAvailable = Platform.isLinux ? _loadSqliteLibrary() : true;

  late String dbName;
  late DatabaseHelper helper;

  setUpAll(() {
    sqfliteFfiInit();
    // The no-isolate factory keeps the sqlite3 library override above effective.
    databaseFactory = databaseFactoryFfiNoIsolate;
  });

  setUp(() {
    dbName = 'savelink_test_${DateTime.now().microsecondsSinceEpoch}.db';
    helper = DatabaseHelper.forTesting(dbName);
  });

  tearDown(() async {
    await helper.close();
    final dir = await databaseFactory.getDatabasesPath();
    await databaseFactory.deleteDatabase(p.join(dir, dbName));
  });

  String stamp(int minutesAgo) =>
      DateTime.now().subtract(Duration(minutes: minutesAgo)).toIso8601String();

  group('DatabaseHelper (real SQLite)', () {
    test('links round-trip through SQLite', () async {
      final id = await helper.insertLink(
        LinkItem(
          title: 'Flutter docs',
          url: 'https://docs.flutter.dev',
          description: 'Reference',
          tags: 'flutter, docs',
          favorite: true,
          createdAt: stamp(10),
          updatedAt: stamp(10),
        ),
      );

      final rows = await helper.getLinks();
      expect(rows, hasLength(1));
      expect(rows.single.id, id);
      expect(rows.single.title, 'Flutter docs');
      expect(rows.single.url, 'https://docs.flutter.dev');
      expect(rows.single.description, 'Reference');
      expect(rows.single.tags, 'flutter, docs');
      expect(rows.single.favorite, isTrue);
      expect(rows.single.archived, isFalse);
      expect(rows.single.collectionId, isNull);
    });

    test('updates, archives and deletes a link', () async {
      final id = await helper.insertLink(
        LinkItem(
          title: 'Old',
          url: 'https://example.com',
          createdAt: stamp(10),
          updatedAt: stamp(10),
        ),
      );
      final stored = (await helper.getLinks()).single;

      await helper.updateLink(
        stored.copyWith(title: 'New', archived: true, updatedAt: stamp(1)),
      );

      final updated = (await helper.getLinks()).single;
      expect(updated.id, id);
      expect(updated.title, 'New');
      expect(updated.archived, isTrue);
      expect(await helper.getLinks(archived: false), isEmpty);
      expect(await helper.getLinks(archived: true), hasLength(1));

      expect(await helper.deleteLink(id), 1);
      expect(await helper.getLinks(), isEmpty);
    });

    test('orders rows by most recently updated', () async {
      await helper.insertLink(LinkItem(
        title: 'Older',
        url: 'https://a.example.com',
        createdAt: stamp(30),
        updatedAt: stamp(30),
      ));
      await helper.insertLink(LinkItem(
        title: 'Newer',
        url: 'https://b.example.com',
        createdAt: stamp(20),
        updatedAt: stamp(2),
      ));

      final rows = await helper.getLinks();
      expect(rows.map((row) => row.title), ['Newer', 'Older']);
    });

    test('notes round-trip and search matches content and tags', () async {
      await helper.insertNote(NoteItem(
        title: 'Groceries',
        content: 'Milk, eggs and bread',
        tags: 'home',
        createdAt: stamp(5),
        updatedAt: stamp(5),
      ));
      await helper.insertNote(NoteItem(
        title: 'Trip',
        content: 'Book the train',
        tags: 'travel',
        createdAt: stamp(4),
        updatedAt: stamp(4),
      ));

      expect(await helper.getNotes(), hasLength(2));
      expect((await helper.searchNotes('eggs')).single.title, 'Groceries');
      expect((await helper.searchNotes('travel')).single.title, 'Trip');
      expect(await helper.searchNotes('nothing-matches'), isEmpty);
    });

    test('link search covers title, url, description and tags', () async {
      await helper.insertLink(LinkItem(
        title: 'Riverpod',
        url: 'https://riverpod.dev',
        description: 'state management',
        tags: 'flutter, state',
        createdAt: stamp(5),
        updatedAt: stamp(5),
      ));

      expect(await helper.searchLinks('riverpod'), hasLength(1));
      expect(await helper.searchLinks('state'), hasLength(1));
      expect(await helper.searchLinks('missing'), isEmpty);
    });

    test('collections keep their items when deleted', () async {
      final collectionId = await helper.insertCollection(CollectionItem(
        name: 'Flutter',
        description: 'Reading list',
        createdAt: stamp(5),
        updatedAt: stamp(5),
      ));
      final linkId = await helper.insertLink(LinkItem(
        title: 'Flutter docs',
        url: 'https://docs.flutter.dev',
        collectionId: collectionId,
        createdAt: stamp(5),
        updatedAt: stamp(5),
      ));
      await helper.insertNote(NoteItem(
        title: 'Widget notes',
        content: 'Stateless vs stateful',
        collectionId: collectionId,
        createdAt: stamp(5),
        updatedAt: stamp(5),
      ));

      expect(await helper.getCollections(), hasLength(1));
      expect((await helper.getLinks()).single.collectionId, collectionId);
      expect((await helper.getNotes()).single.collectionId, collectionId);

      await helper.deleteCollection(collectionId);

      expect(await helper.getCollections(), isEmpty);
      final orphan = (await helper.getLinks()).single;
      expect(orphan.id, linkId);
      expect(orphan.collectionId, isNull);
      expect((await helper.getNotes()).single.collectionId, isNull);
    });

    test('data survives closing and reopening the database', () async {
      await helper.insertLink(LinkItem(
        title: 'Persisted',
        url: 'https://persisted.example.com',
        createdAt: stamp(5),
        updatedAt: stamp(5),
      ));
      await helper.close();

      // A fresh helper on the same file simulates an app restart.
      helper = DatabaseHelper.forTesting(dbName);
      final rows = await helper.getLinks();
      expect(rows, hasLength(1));
      expect(rows.single.title, 'Persisted');
      expect(rows.single.url, 'https://persisted.example.com');
    });

    test('database failures are thrown, not swallowed', () async {
      await helper.close();
      expect(() => helper.getLinks(), throwsA(anything));
    });
  }, skip: sqliteAvailable ? null : 'libsqlite3 is not installed');
}
