import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savelink/features/collections/collection_editor_screen.dart';
import 'package:savelink/features/collections/collections_screen.dart';
import 'package:savelink/shared/widgets/state_views.dart';

import 'support/fake_repository.dart';
import 'support/fixtures.dart';

void main() {
  group('Collections screen', () {
    testWidgets('shows an empty state when nothing is saved', (tester) async {
      await pumpScreen(tester, const CollectionsScreen(), FakeRepository());

      expect(find.text('No collections yet'), findsOneWidget);
      expect(find.byType(EmptyStateView), findsOneWidget);
    });

    testWidgets('creates a collection and shows zeroed counts', (tester) async {
      final repository = FakeRepository();
      await pumpScreen(tester, const CollectionsScreen(), repository);

      await tester.tap(find.text('New'));
      await tester.pumpAndSettle();
      expect(find.byType(CollectionEditorScreen), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Name'),
        'Flutter reading',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(repository.collectionStore, hasLength(1));
      expect(repository.collectionStore.single.name, 'Flutter reading');
      expect(find.text('Flutter reading'), findsOneWidget);
      expect(find.text('0 links · 0 notes'), findsOneWidget);
    });

    testWidgets('counts assigned items and opens the detail screen',
        (tester) async {
      final repository = FakeRepository()
        ..collectionStore.add(collection(name: 'Flutter'))
        ..linkStore.add(link(collectionId: 1))
        ..noteStore.add(note(collectionId: 1));

      await pumpScreen(tester, const CollectionsScreen(), repository);

      expect(find.text('1 link · 1 note'), findsOneWidget);

      await tester.tap(find.text('Flutter'));
      await tester.pumpAndSettle();

      expect(find.text('Links'), findsOneWidget);
      expect(find.text('Notes'), findsOneWidget);
      expect(find.text('Flutter docs'), findsOneWidget);
      expect(find.text('Groceries'), findsOneWidget);
    });

    testWidgets('deleting a collection keeps its items but unassigns them',
        (tester) async {
      final repository = FakeRepository()
        ..collectionStore.add(collection(name: 'Flutter'))
        ..linkStore.add(link(collectionId: 1));

      await pumpScreen(tester, const CollectionsScreen(), repository);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.textContaining('1 item(s) will stay saved'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(repository.collectionStore, isEmpty);
      expect(repository.linkStore, hasLength(1));
      expect(repository.linkStore.single.collectionId, isNull);
      expect(find.text('No collections yet'), findsOneWidget);
    });

    testWidgets('surfaces read failures', (tester) async {
      final repository = FakeRepository()..failReads = true;
      await pumpScreen(tester, const CollectionsScreen(), repository);

      expect(find.byType(ErrorStateView), findsOneWidget);
    });
  });
}
