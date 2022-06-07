import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:just_bottom_sheet/drag_zone_position.dart';
import 'package:just_bottom_sheet/just_bottom_sheet.dart';
import 'package:just_bottom_sheet/just_bottom_sheet_configuration.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JustBottomSheet Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        backgroundColor: Colors.white,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: const MyHomePage(title: 'JustBottomSheet Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Image.asset("assets/images/flutter.png"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showJustBottomSheet(
            context: context,
            dragZoneConfiguration: JustBottomSheetDragZoneConfiguration(
              dragZonePosition: DragZonePosition.outside,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  height: 4,
                  width: 30,
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.grey[300]
                      : Colors.white,
                ),
              ),
            ),
            configuration: JustBottomSheetPageConfiguration(
              height: MediaQuery.of(context).size.height,
              builder: (context) {
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  controller: scrollController,
                  itemBuilder: (context, row) {
                    if (row == 5) {
                      return const _NestedPageView();
                    }
                    return Material(
                      color: Colors.transparent,
                      child: ListTile(
                        title: Text("Row #$row"),
                      ),
                    );
                  },
                  itemCount: 25,
                );
              },
              scrollController: scrollController,
              closeOnScroll: true,
              cornerRadius: 16,
              backgroundColor: Theme.of(context).canvasColor.withOpacity(0.5),
              backgroundImageFilter: ImageFilter.blur(
                sigmaX: 30,
                sigmaY: 30,
              ),
            ),
          );
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _NestedPageView extends StatefulWidget {
  const _NestedPageView({Key? key}) : super(key: key);

  @override
  State<_NestedPageView> createState() => _NestedPageViewState();
}

class _NestedPageViewState extends State<_NestedPageView> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: SizedBox(
        height: 300,
        child: PageView(
          children: [
            Container(
              width: 300,
              color: Colors.green,
              child: const Center(
                child: Text("green"),
              ),
            ),
            Container(
              width: 300,
              color: Colors.red,
              child: const Center(
                child: Text("red"),
              ),
            ),
            Container(
              width: 300,
              color: Colors.orange,
              child: const Center(
                child: Text("orange"),
              ),
            ),
            Container(
              width: 300,
              color: Colors.amber,
              child: const Center(
                child: Text("amber"),
              ),
            ),
            Container(
              width: 300,
              color: Colors.cyan,
              child: const Center(
                child: Text("cyan"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
