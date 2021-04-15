library nav_stack;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path_stack/path_stack.dart';
import 'routing.dart';
export 'package:path_stack/path_stack.dart';

/*
TODO:
  * Build a demo that does some sort of dynamic user-flow:
      [/signup/:step(d+)] : builder(_, args) => SignupFlowPage(step: args['steps'])
  * Build some example that can update
  * Test popUntil, etc
  * Test dialogs inside of StackRouteBuilder
  * Add hook to handle custom BackBtnPressed handler
  * Redirect handler should be able to redirect on the fly... but there might be an issue with recursion? Theoretically redirect chains could go forever...
    * Simple enough to test... what should happen here? Bail after some max number of redirects?
  * NavStack could have a true onBeforeChange handler, as oppossed to PathStack which is coupled directly to .path
  * Create some sort of AppPath.builder method? Or many methods???
 */

class NavStack extends StatefulWidget {
  const NavStack({Key? key, this.onPathChanging, this.appBuilder, required this.stackBuilder, this.initialPath})
      : super(key: key);

  /// Called whenever the current path has changed
  final void Function(String value)? onPathChanging;

  /// Determines what the initial path should be (if the OS has not provided one)
  final String? initialPath;

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

  Map<String, String> _args = {};
  String get args => _path;

  List<String> history = [];

  NavStackRouteParser _parser = NavStackRouteParser();
  late NavStackDelegate _delegate = NavStackDelegate(this);

  @override
  Widget build(BuildContext context) {
    // Allow descendants to look up this controller
    return _InheritedNavStackController(
      state: this,
      // Returns a MaterialApp, with the Delegate as the top level component.
      // The Delegate will call the widget.stackBuilder() inside of the Navigator
      child: widget.appBuilder?.call(_delegate, _parser) ??
          MaterialApp.router(routeInformationParser: _parser, routerDelegate: _delegate),
    );
  }

  /// Steps back one level in the NavStack history
  bool goBack() {
    if (history.length > 1) {
      String prevPath = history[history.length - 2];
      history..removeLast()..removeLast(); // remove last 2 history entries
      path = prevPath; // switch, adding a new history entry
      return true;
    }
    return false;
  }

  /// Go back in history and grab the first route that does not match the provided route.
  /// Used in this demo to close all of the details pages you might have in your history stack
  void popMatching(String value, {bool exactMatch = false}) {
    int index = history.lastIndexWhere((element) => exactMatch ? element != value : element.contains(value) == false);
    List<String> newHistory = List.from(history)..removeRange(index + 1, history.length);
    path = newHistory.last;
    //TODO: Is it an issue that routeChanged handlers will fire before history stack is finalized? Would it be better to have something like ignoreNext?
    history = newHistory;
  }

  /// Pop all pages until we find a match
  void popUntil(String value, {bool exactMatch = false}) {
    int index = history.lastIndexWhere((element) => exactMatch ? element == value : element.contains(value));
    List<String> newHistory = List.from(history)..removeRange(index + 1, history.length);
    path = newHistory.last;
    history = newHistory;
  }

  /// Changes path without creating a new entry stack
  void replacePath(String value) {
    history.removeLast();
    path = value;
  }

  /// Removes all history except the current
  void clearHistory() => history = List.from([history.last]);

  /// Meant to be used from with [onBeforeUpdate] inside of [StackRouteBuilder],
  /// Changes path in the next frame to avoid errors when building mid-build.
  void redirect(String path, {VoidCallback? onComplete}) async => scheduleMicrotask(() {
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
