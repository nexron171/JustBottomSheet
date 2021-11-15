import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:just_bottom_sheet/just_bottom_sheet.dart';

void main() {
  group(
    'JustBottomSheet tests',
    () {
      testWidgets(
        "bottom sheet opens up",
        (WidgetTester tester) async {
          await tester.pumpWidget(const _ExampleApp());
          await tester.pumpAndSettle();
          final fab = await _openBottomSheet(tester);

          final draggableZone = find.byKey(const Key("DraggableZone"));
          expect(fab.hitTestable(), findsNothing,
              reason: "FAB should be invisible");
          expect(draggableZone, findsOneWidget,
              reason: "Bottom sheet should be opened");
        },
      );
      testWidgets(
        'fling on draggable zone to close bottom sheet',
        (WidgetTester tester) async {
          await tester.pumpWidget(const _ExampleApp());
          await tester.pumpAndSettle();
          final fab = await _openBottomSheet(tester);

          final draggableZone = find.byKey(const Key("DraggableZone"));
          expect(fab.hitTestable(), findsNothing,
              reason: "FAB should be invisible");
          expect(draggableZone, findsOneWidget,
              reason: "Bottom sheet should be opened");

          await tester.fling(draggableZone, const Offset(0, 50), 500);
          await tester.pumpAndSettle();
          expect(draggableZone.hitTestable(), findsOneWidget);

          await tester.fling(draggableZone, const Offset(0, 50), 1500);
          await tester.pumpAndSettle();

          expect(fab.hitTestable(), findsOneWidget,
              reason: "FAB should be visible");
        },
      );
      testWidgets(
        'fling on scroll to close bottom sheet',
        (WidgetTester tester) async {
          await tester.pumpWidget(const _ExampleApp());
          await tester.pumpAndSettle();
          final fab = await _openBottomSheet(tester);

          final scrollableZone = find.byKey(const Key("ScrollBox"));
          expect(fab.hitTestable(), findsNothing,
              reason: "FAB should be invisible");
          expect(scrollableZone, findsOneWidget,
              reason: "Bottom sheet should be opened");

          await tester.timedDrag(
            scrollableZone,
            const Offset(0, 200),
            const Duration(milliseconds: 500),
          );
          await tester.pumpAndSettle();
          expect(scrollableZone.hitTestable(), findsOneWidget);

          await tester.timedDrag(
            scrollableZone,
            const Offset(0, 200),
            const Duration(milliseconds: 80),
          );
          await tester.pumpAndSettle();

          expect(
            fab.hitTestable(),
            findsOneWidget,
            reason: "FAB should be visible",
          );
        },
      );
    },
  );
}

Future<Finder> _openBottomSheet(WidgetTester tester) async {
  final Finder fab = find.byTooltip('Increment');

  await tester.tap(fab);
  await tester.pumpAndSettle();

  return fab;
}

class _ExampleApp extends StatefulWidget {
  const _ExampleApp({Key? key}) : super(key: key);

  @override
  State<_ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<_ExampleApp> {
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("JustBottomSheet Test"),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showJustBottomSheet(
                context: context,
                closeOnScroll: true,
                cornerRadius: 32,
                scrollController: scrollController,
                builder: (context) {
                  return ListView.builder(
                    controller: scrollController,
                    itemBuilder: (context, row) {
                      return Material(
                        color: Colors.transparent,
                        child: ListTile(
                          title: Text("Row #$row"),
                        ),
                      );
                    },
                    itemCount: 99,
                  );
                },
              );
            },
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
        );
      }),
    );
  }
}
