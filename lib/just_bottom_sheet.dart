library just_bottom_sheet;

import 'package:flutter/material.dart';

Future<T?> showJustBottomSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  required ScrollController scrollController,
  bool closeOnScroll = false,
  Color? backgroundColor,
  Color? handleBarColor,
  double? cornerRadius,
}) {
  return Navigator.of(context).push<T>(
    JustBottomSheetRoute(
      builder: builder,
      scrollController: scrollController,
      closeOnScroll: closeOnScroll,
      backgroundColor: backgroundColor,
      handleBarColor: handleBarColor,
      cornerRadius: cornerRadius,
    ),
  );
}

class JustBottomSheetRoute<T> extends ModalRoute<T> {
  JustBottomSheetRoute({
    required this.builder,
    required this.scrollController,
    this.closeOnScroll = false,
    this.backgroundColor,
    this.handleBarColor,
    this.cornerRadius,
  }) : super();

  final Widget Function(BuildContext) builder;
  final ScrollController scrollController;
  final bool closeOnScroll;
  final Color? backgroundColor;
  final Color? handleBarColor;
  final double? cornerRadius;

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
      height: MediaQuery.of(context).size.height,
      builder: builder,
      scrollController: scrollController,
      closeOnScroll: closeOnScroll,
      backgroundColor: backgroundColor,
      handleBarColor: handleBarColor,
      cornerRadius: cornerRadius,
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

class JustBottomSheetPage extends StatefulWidget {
  const JustBottomSheetPage({
    required this.height,
    required this.builder,
    required this.scrollController,
    this.closeOnScroll = false,
    this.backgroundColor,
    this.handleBarColor,
    this.cornerRadius,
    Key? key,
  }) : super(key: key);

  final double height;
  final bool closeOnScroll;
  final Widget Function(BuildContext) builder;
  final ScrollController scrollController;
  final Color? backgroundColor;
  final Color? handleBarColor;
  final double? cornerRadius;

  @override
  _JustBottomSheetPageState createState() => _JustBottomSheetPageState();
}

class _ScrollMetrics {
  const _ScrollMetrics(this.timeStamp, this.pixels);

  final int timeStamp;
  final double pixels;
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

  final double scrollDistanceTolerance = 20;
  final double velocityToClose = 1500;

  List<_ScrollMetrics> scrollMetrics = [];
  int lastScrollTimeStamp = 0;

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

  double getScrollVelocityFromPixels(double pixels) {
    final currentTimeStamp = DateTime.now().millisecondsSinceEpoch;
    final duration = currentTimeStamp - lastScrollTimeStamp;
    lastScrollTimeStamp = currentTimeStamp;
    if (duration == 0) {
      return 0;
    }

    final distance = (pixels - scrollPosition) * -1;
    if (distance < scrollDistanceTolerance) {
      return 0;
    }

    final velocity = distance / (duration / 1000);
    return velocity;
  }

  bool isVelocityEnoughToPop(double velocity) {
    return velocity >= velocityToClose;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final topSafeAreaPadding = mediaQuery.padding.top;
    const additionalTopPadding = 32;
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
              topLeft: Radius.circular(widget.cornerRadius ?? 16),
              topRight: Radius.circular(widget.cornerRadius ?? 16),
            ),
            child: Container(
              color: widget.backgroundColor ?? Theme.of(context).canvasColor,
              child: GestureDetector(
                onVerticalDragStart: (details) {
                  targetYOffset = 0;
                  previousYOffset = 0;
                  isDragging = true;
                },
                onVerticalDragUpdate: (details) {
                  final newYOffset = details.globalPosition.dy -
                      totalTopPadding -
                      handlerPadding.top -
                      handlerHeight / 2;

                  handleDragUpdates(
                      offset: newYOffset, delta: details.delta.dy);
                },
                onVerticalDragEnd: (details) {
                  isDragging = false;
                  bool shouldPop = this.shouldPop;

                  final velocity = details.primaryVelocity ?? 0;

                  shouldPop = shouldPop && isVelocityEnoughToPop(velocity) ||
                      targetYOffset >= widget.height / 2;

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
                          color: widget.backgroundColor ??
                              Theme.of(context).canvasColor,
                        ),
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              height: handlerHeight,
                              width: 50,
                              color: widget.handleBarColor ?? Colors.grey,
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
            double height = widget.height - totalTopPadding;

            if (targetYOffset <= 0) {
              height = height + value * -1;
            } else {
              height = height - value;
            }

            return Positioned(
              bottom: 0,
              child: SizedBox(
                width: width,
                height: height,
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
            begin: widget.height -
                totalTopPadding -
                handlerContainerHeight -
                (scrollPosition < 0 ? 0 : previousYOffset),
            end: widget.height -
                totalTopPadding -
                handlerContainerHeight -
                (scrollPosition < 0 ? 0 : targetYOffset),
          ),
          builder: (context, value, child) {
            return Positioned(
              bottom: 0,
              child: SizedBox(
                key: const Key("ScrollBox"),
                width: width,
                height: value,
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
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (scroll) {
                            if (!widget.closeOnScroll) {
                              return false;
                            }
                            final velocity = getScrollVelocityFromPixels(
                                scroll.metrics.pixels);
                            if (scroll.metrics.pixels <= 0) {
                              if (isVelocityEnoughToPop(velocity) &&
                                  !willPop &&
                                  isPointerDown) {
                                willPop = true;
                                // Navigator.of(context).pop();
                              }
                              scrollPosition = scroll.metrics.pixels;
                              handleDragUpdates(
                                offset: scrollPosition * -1,
                                delta: -1,
                              );
                            } else {
                              if (targetYOffset != 0) {
                                handleDragUpdates(
                                  offset: 0,
                                  delta: 1,
                                );
                              }
                              scrollPosition = scroll.metrics.pixels;
                            }
                            return false;
                          },
                          child: ScrollConfiguration(
                            behavior: const ScrollBehavior().copyWith(
                              physics: const BouncingScrollPhysics(),
                            ),
                            child: widget.builder(context),
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
