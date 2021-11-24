import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_bottom_sheet/drag_zone_position.dart';

import 'package:just_bottom_sheet/just_bottom_sheet.dart';
import 'package:just_bottom_sheet/just_bottom_sheet_configuration.dart';

void main() {
  const draggableZoneKey = Key("DraggableZone");
  const scrollableZoneKey = Key("ScrollZone");
  group(
    'JustBottomSheet tests',
    () {
      testWidgets(
        "bottom sheet opens up",
        (WidgetTester tester) async {
          await tester.pumpWidget(const _ExampleApp());
          await tester.pumpAndSettle();
          final fab = await _openBottomSheet(tester);

          final draggableZone = find.byKey(draggableZoneKey);
          expect(fab.hitTestable(), findsNothing,
              reason: "FAB should be invisible");
          expect(draggableZone, findsOneWidget,
              reason: "Bottom sheet should be opened");
        },
      );
      testWidgets(
        'fling on draggable zone inside to close bottom sheet',
        (WidgetTester tester) async {
          await tester.pumpWidget(const _ExampleApp());
          await tester.pumpAndSettle();
          final fab = await _openBottomSheet(tester);

          final draggableZone = find.byKey(draggableZoneKey);
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
        'fling on draggable zone outside to close bottom sheet',
        (WidgetTester tester) async {
          await tester.pumpWidget(const _ExampleApp(
            dragZonePosition: DragZonePosition.outside,
          ));
          await tester.pumpAndSettle();
          final fab = await _openBottomSheet(tester);

          final draggableZone = find.byKey(draggableZoneKey);
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
        'drag on scroll to close bottom sheet',
        (WidgetTester tester) async {
          await tester.pumpWidget(const _ExampleApp());
          await tester.pumpAndSettle();
          final fab = await _openBottomSheet(tester);

          final scrollableZone = find.byKey(scrollableZoneKey);
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
      testWidgets(
        'drag on graggable zone to pull up',
        (WidgetTester tester) async {
          await tester.pumpWidget(const _ExampleApp());
          await tester.pumpAndSettle();
          final fab = await _openBottomSheet(tester);

          final dragZone = find.byKey(draggableZoneKey);
          expect(fab.hitTestable(), findsNothing,
              reason: "FAB should be invisible");
          expect(dragZone, findsOneWidget,
              reason: "Bottom sheet should be opened");

          await tester.timedDrag(
            dragZone,
            const Offset(0, -1000),
            const Duration(milliseconds: 100),
          );
          expect(dragZone.hitTestable(), findsOneWidget);
          await tester.pumpAndSettle();
          expect(dragZone.hitTestable(), findsOneWidget);
        },
      );
      testWidgets(
        'drag on scroll up and down repeatedly - should not be closed',
        (WidgetTester tester) async {
          await tester.pumpWidget(const _ExampleApp());
          await tester.pumpAndSettle();
          await _openBottomSheet(tester);

          final scrollableZone = find.byKey(scrollableZoneKey);
          expect(scrollableZone, findsOneWidget,
              reason: "Bottom sheet should be opened");

          await tester.timedDrag(
            scrollableZone,
            const Offset(0, 100),
            const Duration(milliseconds: 200),
          );
          await tester.timedDrag(
            scrollableZone,
            const Offset(0, -200),
            const Duration(milliseconds: 50),
          );
          await tester.timedDrag(
            scrollableZone,
            const Offset(0, 200),
            const Duration(milliseconds: 200),
          );
          await tester.timedDrag(
            scrollableZone,
            const Offset(0, -200),
            const Duration(milliseconds: 50),
          );
          await tester.timedDrag(
            scrollableZone,
            const Offset(0, 200),
            const Duration(milliseconds: 200),
          );
          await tester.timedDrag(
            scrollableZone,
            const Offset(0, -200),
            const Duration(milliseconds: 50),
          );
          await tester.pumpAndSettle();

          expect(scrollableZone, findsOneWidget,
              reason: "Bottom sheet should be opened");
        },
      );
      testWidgets(
        'drag on scroll to close bottom sheet, but it should not close',
        (WidgetTester tester) async {
          await tester.pumpWidget(const _ExampleApp(
            closeOnScroll: false,
          ));
          await tester.pumpAndSettle();
          final fab = await _openBottomSheet(tester);

          final scrollableZone = find.byKey(scrollableZoneKey);
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
            scrollableZone.hitTestable(),
            findsOneWidget,
            reason: "Scroll should be visible",
          );
        },
      );
      testWidgets('using blur causing transparent background for drag zone',
          (WidgetTester tester) async {
        await tester.pumpWidget(const _ExampleApp(
          closeOnScroll: false,
          useBlur: true,
        ));
        await tester.pumpAndSettle();
        await _openBottomSheet(tester);
        final draggableZoneBackground = find.byKey(
          const Key("DraggableZoneBackground"),
        );
        final draggableZoneWidget =
            tester.firstWidget(draggableZoneBackground) as DecoratedBox;
        final decoration = draggableZoneWidget.decoration as BoxDecoration;

        expect(decoration.color, Colors.transparent);
      });
      testWidgets('using blur causing transparent background for drag zone',
          (WidgetTester tester) async {
        await tester.pumpWidget(const _ExampleApp(
          closeOnScroll: false,
          useBlur: true,
        ));
        await tester.pumpAndSettle();
        await _openBottomSheet(tester);
        final draggableZoneBackground = find.byKey(
          const Key("DraggableZoneBackground"),
        );
        final draggableZoneWidget =
            tester.firstWidget(draggableZoneBackground) as DecoratedBox;
        final decoration = draggableZoneWidget.decoration as BoxDecoration;

        expect(decoration.color, Colors.transparent);
      });
      testWidgets('not using blur causing white background for drag zone',
          (WidgetTester tester) async {
        await tester.pumpWidget(const _ExampleApp(
          closeOnScroll: false,
          useBlur: false,
        ));
        await tester.pumpAndSettle();
        await _openBottomSheet(tester);
        final draggableZoneBackground = find.byKey(
          const Key("DraggableZoneBackground"),
        );
        final draggableZoneWidget =
            tester.firstWidget(draggableZoneBackground) as DecoratedBox;
        final decoration = draggableZoneWidget.decoration as BoxDecoration;

        expect(decoration.color, Colors.white, reason: "Color should be white");
      });
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
  const _ExampleApp({
    this.closeOnScroll = true,
    this.useBlur = false,
    this.dragZonePosition = DragZonePosition.inside,
    Key? key,
  }) : super(key: key);

  final bool closeOnScroll;
  final bool useBlur;
  final DragZonePosition dragZonePosition;

  @override
  State<_ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<_ExampleApp> {
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(brightness: Brightness.light),
      home: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("JustBottomSheet Test"),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showJustBottomSheet(
                  context: context,
                  dragZoneConfiguration: JustBottomSheetDragZoneConfiguration(
                    dragZonePosition: widget.dragZonePosition,
                  ),
                  configuration: JustBottomSheetPageConfiguration(
                    closeOnScroll: widget.closeOnScroll,
                    cornerRadius: 32,
                    scrollController: scrollController,
                    height: MediaQuery.of(context).size.height,
                    backgroundImageFilter: widget.useBlur
                        ? ImageFilter.blur(
                            sigmaX: 0,
                            sigmaY: 0,
                          )
                        : null,
                    backgroundColor: Colors.white,
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
                  ));
            },
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
        );
      }),
    );
  }
}
