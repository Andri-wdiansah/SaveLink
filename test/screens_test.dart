import 'package:flutter_test/flutter_test.dart';
import 'package:savelink/features/home/home_screen.dart';
import 'package:savelink/shared/widgets/state_views.dart';

import 'support/fake_repository.dart';
import 'support/fixtures.dart';

void main() {
  group('Home screen', () {
    testWidgets('renders meaningful content with an empty database',
        (tester) async {
      await pumpScreen(tester, const HomeScreen(), FakeRepository());

      expect(find.text('SaveLink'), findsOneWidget);
      expect(find.text('Your library is empty'), findsOneWidget);
      expect(find.text('Quick actions'), findsOneWidget);
      expect(find.text('Everything is stored offline on this device.'),
          findsOneWidget);
      // Three zeroed stat tiles.
      expect(find.text('0'), findsNWidgets(3));
    });

    testWidgets('shows counts and recent items once data exists',
        (tester) async {
      final repository = FakeRepository()
        ..linkStore.addAll([link(id: 1), link(id: 2, title: 'Riverpod docs')])
        ..noteStore.add(note())
        ..collectionStore.add(collection());

      await pumpScreen(tester, const HomeScreen(), repository);

      expect(find.text('Recent links'), findsOneWidget);
      expect(find.text('Flutter docs'), findsOneWidget);
      expect(find.text('Riverpod docs'), findsOneWidget);
      expect(find.text('Recent notes'), findsOneWidget);
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('Your library is empty'), findsNothing);
      // Stat tile counts (section headers repeat them, hence findsWidgets).
      expect(find.text('2'), findsWidgets);
      expect(find.text('1'), findsWidgets);
    });

    testWidgets('shows a loading indicator while the query is running',
        (tester) async {
      final repository = FakeRepository()
        ..readDelay = const Duration(milliseconds: 300);

      useTallViewport(tester);
      await tester.pumpWidget(wrapScreen(const HomeScreen(), repository));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(LoadingView), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.byType(LoadingView), findsNothing);
      expect(find.text('Your library is empty'), findsOneWidget);
    });

    testWidgets('surfaces database errors with a retry action', (tester) async {
      final repository = FakeRepository()..failReads = true;

      await pumpScreen(tester, const HomeScreen(), repository);

      expect(find.byType(ErrorStateView), findsOneWidget);
      expect(find.textContaining('read failed'), findsOneWidget);

      repository.failReads = false;
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorStateView), findsNothing);
      expect(find.text('Your library is empty'), findsOneWidget);
    });
  });
}
