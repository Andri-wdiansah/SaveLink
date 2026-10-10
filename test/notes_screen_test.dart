import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savelink/features/notes/note_editor_screen.dart';
import 'package:savelink/features/notes/notes_screen.dart';
import 'package:savelink/shared/widgets/state_views.dart';

import 'support/fake_repository.dart';
import 'support/fixtures.dart';

void main() {
  group('Notes screen', () {
    testWidgets('shows an empty state when nothing is saved', (tester) async {
      await pumpScreen(tester, const NotesScreen(), FakeRepository());

      expect(find.text('No notes yet'), findsOneWidget);
      expect(find.byType(EmptyStateView), findsOneWidget);
    });

    testWidgets('creates a note through the editor and lists it',
        (tester) async {
      final repository = FakeRepository();
      await pumpScreen(tester, const NotesScreen(), repository);

      await tester.tap(find.text('New note'));
      await tester.pumpAndSettle();
      expect(find.byType(NoteEditorScreen), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'),
        'Trip plan',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Note'),
        'Book the train to Bandung',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(repository.noteStore, hasLength(1));
      expect(repository.noteStore.single.title, 'Trip plan');
      expect(find.text('Trip plan'), findsOneWidget);
      expect(find.text('No notes yet'), findsNothing);
    });

    testWidgets('edits a note by tapping the card', (tester) async {
      final repository = FakeRepository()..noteStore.add(note());
      await pumpScreen(tester, const NotesScreen(), repository);

      await tester.tap(find.text('Groceries'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'),
        'Groceries (week 2)',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(repository.noteStore.single.title, 'Groceries (week 2)');
      expect(find.text('Groceries (week 2)'), findsOneWidget);
    });

    testWidgets('archives a note and finds it under the Archived filter',
        (tester) async {
      final repository = FakeRepository()..noteStore.add(note());
      await pumpScreen(tester, const NotesScreen(), repository);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Archive'));
      await tester.pumpAndSettle();

      expect(repository.noteStore.single.archived, isTrue);
      expect(find.text('No notes yet'), findsOneWidget);

      await tester.tap(find.text('Archived'));
      await tester.pumpAndSettle();
      expect(find.text('Groceries'), findsOneWidget);
    });

    testWidgets('deletes a note after confirmation', (tester) async {
      final repository = FakeRepository()..noteStore.add(note());
      await pumpScreen(tester, const NotesScreen(), repository);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(repository.noteStore, isEmpty);
      expect(find.text('No notes yet'), findsOneWidget);
    });

    testWidgets('surfaces read failures', (tester) async {
      final repository = FakeRepository()..failReads = true;
      await pumpScreen(tester, const NotesScreen(), repository);

      expect(find.byType(ErrorStateView), findsOneWidget);
      expect(find.textContaining('read failed'), findsOneWidget);
    });
  });
}
