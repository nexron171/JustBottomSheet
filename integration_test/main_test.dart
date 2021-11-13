import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:just_bottom_sheet/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('tap on the floating action button to open bottom sheet',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final Finder fab = find.byTooltip('Increment');

      await tester.tap(fab);

      await tester.pumpAndSettle();

      var draggableZone = find.byKey(const ValueKey("DraggableZone"));
      await tester.fling(draggableZone, const Offset(50, 100), 200);
      await tester.pumpAndSettle();
      await tester.ensureVisible(draggableZone);

      await Future.delayed(const Duration(seconds: 1));
      await tester.fling(draggableZone, const Offset(50, 100), 800);
      await tester.pumpAndSettle();

      await tester.ensureVisible(fab);
    });
  });
}
