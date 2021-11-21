import 'package:flutter/material.dart';
import 'package:just_bottom_sheet/just_bottom_sheet_configuration.dart';

class JustBottomSheetDragZone extends StatelessWidget {
  const JustBottomSheetDragZone({
    required this.dragZoneConfiguration,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    this.child,
    Key? key,
  }) : super(key: key);

  final JustBottomSheetDragZoneConfiguration dragZoneConfiguration;
  final Function(DragStartDetails) onDragStart;
  final Function(DragUpdateDetails) onDragUpdate;
  final Function(DragEndDetails) onDragEnd;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: dragZoneConfiguration.backgroundColor ??
          Theme.of(context).canvasColor,
      child: GestureDetector(
        onVerticalDragStart: onDragStart,
        onVerticalDragUpdate: onDragUpdate,
        onVerticalDragEnd: onDragEnd,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              key: const Key("DraggableZone"),
              height: dragZoneConfiguration.height,
              width: dragZoneConfiguration.width ??
                  MediaQuery.of(context).size.width,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: dragZoneConfiguration.backgroundColor ??
                      Theme.of(context).canvasColor,
                ),
                child: Center(
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
