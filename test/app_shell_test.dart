import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savelink/app.dart';
import 'package:savelink/data/providers/app_providers.dart';

import 'support/fake_repository.dart';
import 'support/fixtures.dart';

/// End-to-end shell test: the bottom navigation must show real content for all
/// four tabs (this is the regression that produced a blank Home screen).
Future<void> _tapTab(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text(label),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('bottom navigation renders every tab with content',
      (tester) async {
    useTallViewport(tester);
    final repository = FakeRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appRepositoryProvider.overrideWithValue(repository)],
        child: const SaveLinkApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Home tab
    expect(find.text('SaveLink'), findsOneWidget);
    expect(find.text('Your library is empty'), findsOneWidget);

    // Links tab
    await _tapTab(tester, 'Links');
    expect(find.text('No links saved yet'), findsOneWidget);

    // Notes tab
    await _tapTab(tester, 'Notes');
    expect(find.text('No notes yet'), findsOneWidget);

    // Collections tab
    await _tapTab(tester, 'Collections');
    expect(find.text('No collections yet'), findsOneWidget);

    // Back to Home, still rendering content.
    await _tapTab(tester, 'Home');
    expect(find.text('Your library is empty'), findsOneWidget);
  });

  testWidgets('data created in one tab is visible in the others',
      (tester) async {
    useTallViewport(tester);
    final repository = FakeRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appRepositoryProvider.overrideWithValue(repository)],
        child: const SaveLinkApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Create a link from the Links tab.
    await _tapTab(tester, 'Links');
    await tester.tap(find.text('New link'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'URL'),
      'https://flutter.dev',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title'),
      'Flutter home',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(repository.linkStore, hasLength(1));

    // Home reflects the new data immediately.
    await _tapTab(tester, 'Home');
    expect(find.text('Flutter home'), findsOneWidget);
    expect(find.text('Your library is empty'), findsNothing);
  });
}
