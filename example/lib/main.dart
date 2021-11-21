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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showJustBottomSheet(
            context: context,
            dragZoneConfiguration: JustBottomSheetDragZoneConfiguration(
              dragZonePosition: DragZonePosition.inside,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  height: 8,
                  width: 50,
                  color: Colors.grey,
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
                backgroundColor: Colors.lightGreen),
          );
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
