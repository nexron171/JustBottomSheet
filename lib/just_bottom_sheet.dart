library just_bottom_sheet;

import 'dart:math';

import 'package:flutter/material.dart';

Future<T?> showJustBottomSheet<T>({
  required BuildContext context,
  required JustBottomSheetPageConfiguration configuration,
}) {
  return Navigator.of(context).push<T>(
    JustBottomSheetRoute(configuration: configuration),
  );
}

class JustBottomSheetRoute<T> extends ModalRoute<T> {
  JustBottomSheetRoute({
    required this.configuration,
  }) : super();

  final JustBottomSheetPageConfiguration configuration;

  @override
  Color? get barrierColor => Colors.black.withOpacity(0.5);

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return JustBottomSheetPage(
      configuration: configuration,
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    var begin = const Offset(0, 1);
    var end = Offset.zero;
    var tween =
        Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeOut));
    var offsetAnimation = animation.drive(tween);

    return SlideTransition(
      position: offsetAnimation,
      child: child,
    );
  }

  @override
  bool get maintainState => false;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 250);
}

class JustBottomSheetPageConfiguration {
  const JustBottomSheetPageConfiguration({
    required this.height,
    required this.builder,
    required this.scrollController,
    this.dragZonePosition = DragZonePosition.inside,
    this.closeOnScroll = false,
    this.additionalTopPadding = 32,
    this.backgroundColor,
    this.handleBarColor,
    this.cornerRadius,
  });

  final double height;
  final bool closeOnScroll;
  final Widget Function(BuildContext) builder;
  final ScrollController scrollController;
  final DragZonePosition dragZonePosition;
  final double additionalTopPadding;
  final Color? backgroundColor;
  final Color? handleBarColor;
  final double? cornerRadius;
}

class JustBottomSheetPage extends StatefulWidget {
  const JustBottomSheetPage({
    required this.configuration,
    Key? key,
  }) : super(key: key);

  final JustBottomSheetPageConfiguration configuration;

  @override
  _JustBottomSheetPageState createState() => _JustBottomSheetPageState();
}

enum DragZonePosition { inside, outside }

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

    final Widget backgroundBody = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(widget.configuration.cornerRadius ?? 16),
              topRight:
                  Radius.circular(widget.configuration.cornerRadius ?? 16),
            ),
            child: Container(
              color: widget.configuration.backgroundColor ??
                  Theme.of(context).canvasColor,
              child: GestureDetector(
                onVerticalDragStart: (details) {
                  targetYOffset = 0;
                  previousYOffset = 0;
                  isDragging = true;
                },
                onVerticalDragUpdate: (details) {
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
                onVerticalDragEnd: (details) {
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
                },
                child: Column(
                  children: [
                    SizedBox(
                      key: const Key("DraggableZone"),
                      height: handlerContainerHeight,
                      width: width,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: widget.configuration.backgroundColor ??
                              Theme.of(context).canvasColor,
                        ),
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              height: handlerHeight,
                              width: 50,
                              color: widget.configuration.handleBarColor ??
                                  Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );

    return Stack(
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
                              physics: const BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics()),
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
    );
  }
}
