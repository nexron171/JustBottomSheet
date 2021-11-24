import 'dart:ui';

import 'package:flutter/material.dart';

import 'drag_zone_position.dart';

class JustBottomSheetPageConfiguration {
  const JustBottomSheetPageConfiguration({
    required this.height,
    required this.builder,
    required this.scrollController,
    this.closeOnScroll = false,
    this.additionalTopPadding = 32,
    this.backgroundColor,
    this.cornerRadius,
    this.backgroundImageFilter,
  });

  final double height;
  final bool closeOnScroll;
  final Widget Function(BuildContext) builder;
  final ScrollController scrollController;
  final double additionalTopPadding;
  final Color? backgroundColor;
  final double? cornerRadius;
  final ImageFilter? backgroundImageFilter;
}

class JustBottomSheetDragZoneConfiguration {
  const JustBottomSheetDragZoneConfiguration({
    this.height = 32,
    this.width,
    this.backgroundColor,
    this.dragZonePosition = DragZonePosition.inside,
    this.child,
  });

  final double height;
  final double? width;
  final Color? backgroundColor;
  final DragZonePosition dragZonePosition;
  final Widget? child;

  JustBottomSheetDragZoneConfiguration copyWith({
    double? height,
    double? width,
    Color? backgroundColor,
    DragZonePosition? dragZonePosition,
    Widget? child,
  }) {
    return JustBottomSheetDragZoneConfiguration(
      height: height ?? this.height,
      width: width ?? this.width,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      dragZonePosition: dragZonePosition ?? this.dragZonePosition,
      child: child ?? this.child,
    );
  }
}
