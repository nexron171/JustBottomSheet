import 'package:flutter/material.dart';

import 'just_bottom_sheet.dart';
import 'just_bottom_sheet_configuration.dart';

class JustBottomSheetRoute<T> extends ModalRoute<T> {
  JustBottomSheetRoute({
    required this.configuration,
    required this.dragZoneConfiguration,
  }) : super();

  final JustBottomSheetPageConfiguration configuration;
  final JustBottomSheetDragZoneConfiguration dragZoneConfiguration;

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
      dragZoneConfiguration: dragZoneConfiguration,
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
