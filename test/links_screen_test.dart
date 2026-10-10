import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savelink/features/links/link_editor_screen.dart';
import 'package:savelink/features/links/links_screen.dart';
import 'package:savelink/shared/widgets/state_views.dart';

import 'support/fake_repository.dart';
import 'support/fixtures.dart';

void main() {
  group('Links screen', () {
    testWidgets('shows an empty state when nothing is saved', (tester) async {
      await pumpScreen(tester, const LinksScreen(), FakeRepository());

      expect(find.text('No links saved yet'), findsOneWidget);
      expect(find.byType(EmptyStateView), findsOneWidget);
      expect(find.text('New link'), findsOneWidget);
    });

    testWidgets('creates a link through the editor and lists it',
        (tester) async {
      final repository = FakeRepository();
      await pumpScreen(tester, const LinksScreen(), repository);

      await tester.tap(find.text('New link'));
      await tester.pumpAndSettle();
      expect(find.byType(LinkEditorScreen), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'URL'),
        'example.com/article',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'),
        'Great article',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(repository.linkStore, hasLength(1));
      expect(repository.linkStore.single.url, 'https://example.com/article');
      expect(find.text('Great article'), findsOneWidget);
      expect(find.text('No links saved yet'), findsNothing);
    });

    testWidgets('rejects an invalid URL and writes nothing', (tester) async {
      final repository = FakeRepository();
      await pumpScreen(tester, const LinksScreen(), repository);

      await tester.tap(find.text('New link'));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.widgetWithText(TextFormField, 'URL'), 'not a url');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid URL'), findsOneWidget);
      expect(repository.linkStore, isEmpty);
      expect(find.byType(LinkEditorScreen), findsOneWidget);
    });

    testWidgets('toggles favorite and persists the change', (tester) async {
      final repository = FakeRepository()..linkStore.add(link());
      await pumpScreen(tester, const LinksScreen(), repository);

      await tester.tap(find.widgetWithIcon(IconButton, Icons.star_outline));
      await tester.pumpAndSettle();

      expect(repository.linkStore.single.favorite, isTrue);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('edits an existing link', (tester) async {
      final repository = FakeRepository()..linkStore.add(link());
      await pumpScreen(tester, const LinksScreen(), repository);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'),
        'Flutter docs (updated)',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(repository.linkStore.single.title, 'Flutter docs (updated)');
      expect(find.text('Flutter docs (updated)'), findsOneWidget);
    });

    testWidgets('deletes a link after confirmation', (tester) async {
      final repository = FakeRepository()..linkStore.add(link());
      await pumpScreen(tester, const LinksScreen(), repository);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Delete link?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(repository.linkStore, isEmpty);
      expect(find.text('No links saved yet'), findsOneWidget);
    });

    testWidgets('archived links move to the Archived filter', (tester) async {
      final repository = FakeRepository()..linkStore.add(link());
      await pumpScreen(tester, const LinksScreen(), repository);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Archive'));
      await tester.pumpAndSettle();

      expect(repository.linkStore.single.archived, isTrue);
      expect(find.text('No links saved yet'), findsOneWidget);

      await tester.tap(find.text('Archived'));
      await tester.pumpAndSettle();
      expect(find.text('Flutter docs'), findsOneWidget);
    });

    testWidgets('shows an error state when the read fails', (tester) async {
      final repository = FakeRepository()..failReads = true;
      await pumpScreen(tester, const LinksScreen(), repository);

      expect(find.byType(ErrorStateView), findsOneWidget);
      expect(find.textContaining('read failed'), findsOneWidget);
    });

    testWidgets('reports a failed write instead of hiding it', (tester) async {
      final repository = FakeRepository()..failWrites = true;
      await pumpScreen(tester, const LinksScreen(), repository);

      await tester.tap(find.text('New link'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'URL'),
        'example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'),
        'Doomed link',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(
          find.textContaining('Could not complete the action'), findsOneWidget);
      expect(repository.linkStore, isEmpty);
    });
  });
}
