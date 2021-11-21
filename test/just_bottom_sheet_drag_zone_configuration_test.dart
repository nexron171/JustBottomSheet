import 'package:flutter_test/flutter_test.dart';
import 'package:just_bottom_sheet/drag_zone_position.dart';
import 'package:just_bottom_sheet/just_bottom_sheet_configuration.dart';
import 'package:flutter/material.dart';

void main() {
  test('Drag zone config should be copied with new values', () {
    const JustBottomSheetDragZoneConfiguration config =
        JustBottomSheetDragZoneConfiguration(
      backgroundColor: Colors.white,
      dragZonePosition: DragZonePosition.inside,
      height: 100,
      width: 100,
      child: SizedBox(),
    );

    expect(config.backgroundColor, Colors.white);
    expect(config.dragZonePosition, DragZonePosition.inside);
    expect(config.height, 100);
    expect(config.width, 100);
    expect(config.child, isInstanceOf<SizedBox>());

    JustBottomSheetDragZoneConfiguration newConfig = config.copyWith(
      backgroundColor: Colors.red,
      dragZonePosition: DragZonePosition.outside,
      height: 200,
      width: 200,
      child: const Text(""),
    );

    expect(newConfig.backgroundColor, Colors.red);
    expect(newConfig.dragZonePosition, DragZonePosition.outside);
    expect(newConfig.height, 200);
    expect(newConfig.width, 200);
    expect(newConfig.child, isInstanceOf<Text>());

    newConfig = config.copyWith();

    expect(newConfig.backgroundColor, config.backgroundColor);
    expect(newConfig.dragZonePosition, config.dragZonePosition);
    expect(newConfig.height, config.height);
    expect(newConfig.width, config.width);
    expect(newConfig.child, isInstanceOf<SizedBox>());
  });
}
