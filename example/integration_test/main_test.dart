import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:just_bottom_sheet/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('tap on the floating action button to open bottom sheet', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      final fab = await _openBottomSheet(tester);

      final draggableZone = find.byKey(const Key("DraggableZone"));
      expect(fab.hitTestable(), findsNothing, reason: "FAB should be invisible");
      expect(draggableZone, findsOneWidget, reason: "Bottom sheet should be opened");
    });

    testWidgets('fling on draggable zone to close bottom sheet', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      final fab = await _openBottomSheet(tester);

      final draggableZone = find.byKey(const Key("DraggableZone"));
      expect(fab.hitTestable(), findsNothing, reason: "FAB should be invisible");
      expect(draggableZone, findsOneWidget, reason: "Bottom sheet should be opened");

      await tester.fling(draggableZone, const Offset(0, 50), 500);
      await tester.pumpAndSettle();
      expect(draggableZone.hitTestable(), findsOneWidget);

      await tester.fling(draggableZone, const Offset(0, 50), 1500);
      await tester.pumpAndSettle();

      expect(fab.hitTestable(), findsOneWidget, reason: "FAB should be visible");
    });

    testWidgets('fling on scroll to close bottom sheet', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      final fab = await _openBottomSheet(tester);

      final scrollableZone = find.byKey(const Key("ScrollBox"));
      expect(fab.hitTestable(), findsNothing, reason: "FAB should be invisible");
      expect(scrollableZone, findsOneWidget, reason: "Bottom sheet should be opened");

      await tester.timedDrag(scrollableZone, const Offset(0, 200), const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      expect(scrollableZone.hitTestable(), findsOneWidget);

      await tester.timedDrag(scrollableZone, const Offset(0, 200), const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(fab.hitTestable(), findsOneWidget, reason: "FAB should be visible");
    });
  });
}

Future<Finder> _openBottomSheet(WidgetTester tester) async {
  final Finder fab = find.byTooltip('Increment');

  await tester.tap(fab);
  await tester.pumpAndSettle();

  return fab;
}
