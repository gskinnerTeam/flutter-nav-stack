library nav_stack;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path_stack/path_stack.dart';
import 'routing.dart';
export 'package:path_stack/path_stack.dart';

/*
TODO:
  * NavStackController.of()
  * history stack
  * goBackMethod
  * path =
  * popUntil
  * popMatching
  * popAll
  * add hook to handle custom BackBtnPressed handler
 */

class NavStack extends StatefulWidget {
  const NavStack({Key? key, this.onPathChanging, this.appBuilder, required this.stackBuilder}) : super(key: key);

  /// Called whenever the current path has changed
  final void Function(String value)? onPathChanging;

  /// Caller should invoke MaterialApp.router, and use the provided delegate & router, adding any
  /// other custom options they need to the MaterialApp.
  final MaterialApp Function(RouterDelegate<String> delegate, RouteInformationParser<String> parser)? appBuilder;

  /// Must return a PathStack widget
  final PathStack Function(BuildContext context, NavStackController controller) stackBuilder;

  @override
  NavStackController createState() => NavStackController();

  static NavStackController of(BuildContext context) =>
      (context.dependOnInheritedWidgetOfExactType<_InheritedNavStackController>() as _InheritedNavStackController)
          .state;
}

class NavStackController extends State<NavStack> with ChangeNotifier {
  String _path = "/";
  String get path => _path;
  set path(String value) {
    widget.onPathChanging?.call(value);
    _path = value;
    notifyListeners();
  }

  NavStackRouteParser _parser = NavStackRouteParser();
  late NavStackDelegate _delegate = NavStackDelegate(this);

  @override
  Widget build(BuildContext context) {
    // Returns a materialApp, with the Delegate as the top level component.
    // The Delegate will call the widget.stackBuilder() inside of the Navigator
    return _InheritedNavStackController(
      state: this,
      child: widget.appBuilder?.call(_delegate, _parser) ??
          MaterialApp.router(routeInformationParser: _parser, routerDelegate: _delegate),
    );
  }

  //TODO, add history stack:
  /// Steps back one level in the NavStack history
  bool goBack() => false;

  /// Meant to be used from with [onBeforeUpdate] inside of [StackRouteBuilder],
  /// Changes path in the next frame to avoid errors when building mid-build.
  void redirect(String path, VoidCallback? onComplete) async => scheduleMicrotask(() {
        this.path = path;
        onComplete?.call();
      });
}

class _InheritedNavStackController extends InheritedWidget {
  _InheritedNavStackController({Key? key, required Widget child, required this.state}) : super(key: key, child: child);
  final NavStackController state;
  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;
}
