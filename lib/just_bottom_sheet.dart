library just_bottom_sheet;

import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:just_bottom_sheet/drag_zone_position.dart';
import 'package:just_bottom_sheet/just_bottom_sheet_drag_zone.dart';

import 'just_bottom_sheet_configuration.dart';
import 'just_bottom_sheet_route.dart';

class JustBottomSheetPage extends StatefulWidget {
  const JustBottomSheetPage({
    required this.configuration,
    required this.dragZoneConfiguration,
    Key? key,
  }) : super(key: key);

  final JustBottomSheetPageConfiguration configuration;
  final JustBottomSheetDragZoneConfiguration dragZoneConfiguration;

  @override
  _JustBottomSheetPageState createState() => _JustBottomSheetPageState();
}

class _JustBottomSheetPageState extends State<JustBottomSheetPage>
    with TickerProviderStateMixin {
  bool isDragging = false;
  bool isClampingScroll = false;
  bool shouldPop = false;
  bool willPop = false;

  bool isPointerDown = false;

  double targetYOffset = 0;
  double previousYOffset = 0;
  double scrollPosition = 0;

  final double velocityToClose = 1500;

  void handleDragUpdates({required double offset, required double delta}) {
    if (offset <= -20) {
      previousYOffset = -20;
      return;
    }

    if ((offset > targetYOffset && delta > 0)) {
      shouldPop = true;
    } else {
      shouldPop = false;
    }
    setState(() {
      previousYOffset = targetYOffset;
      targetYOffset = offset;
    });
  }

  bool isVelocityEnoughToPop(double velocity) {
    return velocity >= velocityToClose;
  }

  void onDragZoneDragStart(DragStartDetails details) {
    targetYOffset = 0;
    previousYOffset = 0;
    isDragging = true;
  }

  void onDragZoneDragEnd(DragEndDetails details) {
    isDragging = false;
    bool shouldPop = this.shouldPop;

    final velocity = details.primaryVelocity ?? 0;

    shouldPop = shouldPop && isVelocityEnoughToPop(velocity) ||
        targetYOffset >= widget.configuration.height / 2;

    if (shouldPop && !willPop) {
      willPop = true;
      Navigator.of(context).pop();
      return;
    } else {
      setState(() {
        targetYOffset = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final height = mediaQuery.size.height;
    final offsetCompensation = height - widget.configuration.height;
    final width = mediaQuery.size.width;
    final topSafeAreaPadding = mediaQuery.padding.top;
    final additionalTopPadding = widget.configuration.additionalTopPadding;
    final totalTopPadding = topSafeAreaPadding + additionalTopPadding;

    const double handlerContainerHeight = 32;
    const handlerPadding = EdgeInsets.all(8);
    const double handlerHeight = 8;

    Widget backgroundChild = Builder(
      builder: (context) {
        return Container(
          color: Theme.of(context).canvasColor,
          child: widget.dragZoneConfiguration.dragZonePosition ==
                  DragZonePosition.inside
              ? JustBottomSheetDragZone(
                  dragZoneConfiguration: widget.dragZoneConfiguration.copyWith(
                    backgroundColor:
                        widget.configuration.backgroundImageFilter == null
                            ? widget.dragZoneConfiguration.backgroundColor
                            : Colors.transparent,
                  ),
                  onDragStart: onDragZoneDragStart,
                  onDragUpdate: (details) {
                    final newYOffset = details.globalPosition.dy -
                        totalTopPadding -
                        offsetCompensation -
                        handlerPadding.top -
                        handlerHeight / 2;

                    handleDragUpdates(
                      offset: newYOffset,
                      delta: details.delta.dy,
                    );
                  },
                  onDragEnd: onDragZoneDragEnd,
                  child: widget.dragZoneConfiguration.child,
                )
              : null,
        );
      },
    );

    final backgroundImageFilter = widget.configuration.backgroundImageFilter;
    if (backgroundImageFilter != null) {
      backgroundChild = BackdropFilter(
        filter: backgroundImageFilter,
        child: backgroundChild,
      );
    }

    final Widget backgroundBody = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.dragZoneConfiguration.dragZonePosition ==
            DragZonePosition.outside)
          JustBottomSheetDragZone(
            dragZoneConfiguration: widget.dragZoneConfiguration.copyWith(
              backgroundColor: Colors.transparent,
            ),
            onDragStart: onDragZoneDragStart,
            onDragUpdate: (details) {
              final newYOffset = details.globalPosition.dy -
                  totalTopPadding -
                  offsetCompensation -
                  handlerPadding.top -
                  handlerHeight / 2;

              handleDragUpdates(
                offset: newYOffset,
                delta: details.delta.dy,
              );
            },
            onDragEnd: onDragZoneDragEnd,
            child: widget.dragZoneConfiguration.child,
          ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(widget.configuration.cornerRadius ?? 16),
              topRight:
                  Radius.circular(widget.configuration.cornerRadius ?? 16),
            ),
            child: backgroundChild,
          ),
        ),
      ],
    );

    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: widget.configuration.backgroundColor,
      ),
      child: Stack(
        children: [
          TweenAnimationBuilder<double>(
            duration: isDragging || scrollPosition < 0
                ? Duration.zero
                : const Duration(milliseconds: 250),
            curve: Curves.linearToEaseOut,
            tween: Tween<double>(
              begin: previousYOffset,
              end: targetYOffset,
            ),
            builder: (context, value, child) {
              double height = widget.configuration.height - totalTopPadding;

              if (targetYOffset <= 0) {
                height = height + value * -1;
              } else {
                height = height - value;
              }

              return Positioned(
                bottom: 0,
                child: SizedBox(
                  width: width,
                  height: max(0, height),
                  child: child!,
                ),
              );
            },
            child: backgroundBody,
          ),
          TweenAnimationBuilder<double>(
            duration:
                isDragging ? Duration.zero : const Duration(milliseconds: 250),
            curve: Curves.linearToEaseOut,
            tween: Tween<double>(
              begin: widget.configuration.height -
                  totalTopPadding -
                  handlerContainerHeight -
                  (scrollPosition < 0 ? 0 : previousYOffset),
              end: widget.configuration.height -
                  totalTopPadding -
                  handlerContainerHeight -
                  (scrollPosition < 0 ? 0 : targetYOffset),
            ),
            builder: (context, value, child) {
              return Positioned(
                bottom: 0,
                child: SizedBox(
                  key: const Key("ScrollZone"),
                  width: width,
                  height: max(0, value),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Listener(
                          onPointerDown: (_) {
                            isPointerDown = true;
                          },
                          onPointerUp: (_) {
                            isPointerDown = false;
                            if (willPop) {
                              Navigator.of(context).pop();
                            }
                          },
                          child: NotificationListener<ScrollUpdateNotification>(
                            onNotification: (details) {
                              if (!widget.configuration.closeOnScroll) {
                                return false;
                              }
                              final delta =
                                  details.dragDetails?.primaryDelta?.abs() ?? 0;
                              if (details.metrics.pixels <= 0) {
                                if (delta > 30 && !willPop && isPointerDown) {
                                  willPop = true;
                                }
                                scrollPosition = details.metrics.pixels;
                                handleDragUpdates(
                                  offset: scrollPosition * -1,
                                  delta: -1,
                                );
                              } else {
                                willPop = false;
                                if (targetYOffset != 0) {
                                  handleDragUpdates(
                                    offset: 0,
                                    delta: 1,
                                  );
                                }
                                scrollPosition = details.metrics.pixels;
                              }
                              return false;
                            },
                            child: ScrollConfiguration(
                              behavior: const ScrollBehavior().copyWith(
                                physics: BouncingScrollPhysics(
                                  parent: isDragging
                                      ? const NeverScrollableScrollPhysics()
                                      : const AlwaysScrollableScrollPhysics(),
                                ),
                              ),
                              child: widget.configuration.builder(context),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            child: backgroundBody,
          ),
        ],
      ),
    );
  }
}

Future<T?> showJustBottomSheet<T>({
  required BuildContext context,
  required JustBottomSheetPageConfiguration configuration,
  JustBottomSheetDragZoneConfiguration dragZoneConfiguration =
      const JustBottomSheetDragZoneConfiguration(),
}) {
  return Navigator.of(context).push<T>(
    JustBottomSheetRoute(
        configuration: configuration,
        dragZoneConfiguration: dragZoneConfiguration),
  );
}
