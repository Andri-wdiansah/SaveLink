import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savelink/data/providers/app_providers.dart';
import 'package:savelink/models/collection_item.dart';
import 'package:savelink/models/link_item.dart';
import 'package:savelink/models/note_item.dart';

import 'fake_repository.dart';

Widget wrapScreen(Widget screen, FakeRepository repository) => ProviderScope(
      overrides: [appRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(home: screen),
    );

/// Tall viewport so lazily built list children are laid out during tests.
void useTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Future<void> pumpScreen(
  WidgetTester tester,
  Widget screen,
  FakeRepository repository,
) async {
  useTallViewport(tester);
  await tester.pumpWidget(wrapScreen(screen, repository));
  await tester.pumpAndSettle();
}

String stamp(int minutesAgo) =>
    DateTime.now().subtract(Duration(minutes: minutesAgo)).toIso8601String();

LinkItem link({
  int id = 1,
  String title = 'Flutter docs',
  String url = 'https://docs.flutter.dev',
  String tags = 'flutter, docs',
  bool favorite = false,
  bool archived = false,
  int? collectionId,
}) =>
    LinkItem(
      id: id,
      title: title,
      url: url,
      description: 'Description for $title',
      tags: tags,
      collectionId: collectionId,
      favorite: favorite,
      pinned: false,
      archived: archived,
      createdAt: stamp(60),
      updatedAt: stamp(5),
    );

NoteItem note({
  int id = 1,
  String title = 'Groceries',
  String content = 'Milk, eggs',
  bool archived = false,
  bool favorite = false,
  int? collectionId,
}) =>
    NoteItem(
      id: id,
      title: title,
      content: content,
      tags: 'home',
      collectionId: collectionId,
      favorite: favorite,
      pinned: false,
      archived: archived,
      createdAt: stamp(60),
      updatedAt: stamp(3),
    );

CollectionItem collection({int id = 1, String name = 'Flutter'}) =>
    CollectionItem(
      id: id,
      name: name,
      description: 'Saved reading',
      createdAt: stamp(60),
      updatedAt: stamp(1),
    );
