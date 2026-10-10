import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savelink/features/search/search_screen.dart';
import 'package:savelink/shared/widgets/state_views.dart';

import 'support/fake_repository.dart';
import 'support/fixtures.dart';

Future<void> _search(WidgetTester tester, String query) async {
  await tester.enterText(find.byType(TextField), query);
  // The screen debounces input by 250ms before hitting the database.
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pumpAndSettle();
}

void main() {
  group('Search screen', () {
    testWidgets('prompts for a query before searching', (tester) async {
      await pumpScreen(tester, const SearchScreen(), FakeRepository());

      expect(find.text('Search your library'), findsOneWidget);
    });

    testWidgets('returns matching links and notes from the repository',
        (tester) async {
      final repository = FakeRepository()
        ..linkStore.add(link(title: 'Flutter docs', tags: 'flutter'))
        ..noteStore.add(note(title: 'Groceries', content: 'Milk, eggs'));

      await pumpScreen(tester, const SearchScreen(), repository);

      await _search(tester, 'flutter');

      expect(find.text('Flutter docs'), findsOneWidget);
      expect(find.text('Groceries'), findsNothing);

      await _search(tester, 'milk');

      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('Flutter docs'), findsNothing);
    });

    testWidgets('shows a no-matches state for unknown queries', (tester) async {
      final repository = FakeRepository()..linkStore.add(link());
      await pumpScreen(tester, const SearchScreen(), repository);

      await _search(tester, 'zzzz-nothing');

      expect(find.text('No matches'), findsOneWidget);
    });

    testWidgets('surfaces search failures', (tester) async {
      final repository = FakeRepository()..failReads = true;
      await pumpScreen(tester, const SearchScreen(), repository);

      await _search(tester, 'flutter');

      expect(find.byType(ErrorStateView), findsOneWidget);
      expect(find.textContaining('read failed'), findsOneWidget);
    });
  });
}
