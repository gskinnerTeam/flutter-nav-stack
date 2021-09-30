import 'package:flutter/material.dart';
import 'package:nav_stack/no_animation_delegate.dart';

import 'nav_stack.dart';

class NavStackRouteParser extends RouteInformationParser<String> {
  @override
  Future<String> parseRouteInformation(
          RouteInformation routeInformation) async =>
      routeInformation.location ?? "";

  @override
  RouteInformation? restoreRouteInformation(String path) =>
      RouteInformation(location: path);
}

GlobalKey<NavigatorState> _navKey = GlobalKey();

class NavStackDelegate extends RouterDelegate<String>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<String> {
  final NavStackController stackController;
  NavStackDelegate(this.stackController) {
    // When controller changes it's value, this will trigger a rebuild
    this.stackController.addListener(notifyListeners);
  }

  @override
  GlobalKey<NavigatorState> navigatorKey = _navKey;

  @override
  String? get currentConfiguration => stackController.path;

  late String _prevPath = stackController.path;

  /// Returns a Navigator with a single page.
  /// Wraps the page in a PathStackPathProvider so the top-most PathStack can grab the current route path.
  /// Calls NavigatorState.widget.stackBuilder to build the page contents.
  @override
  Widget build(BuildContext _) {
    _recordHistoryEntry(stackController.path);
    return Material(
      child: Navigator(
        key: navigatorKey,
        transitionDelegate: NoAnimationTransitionDelegate(),
        pages: [
          MaterialPage(
            // Create a context that can access the Navigator above, so the stackBuilder() delegate can show dialogs, overlays etc
            child: Builder(builder: (context) {
              return PathStackPathProvider(
                path: stackController.path,
                //Added in PathStack
                unknownPath: stackController.widget.onUnknownPath ?? "",
                child: stackController.widget
                    .stackBuilder(context, stackController),
              );
            }),
          ),
        ],
        onPopPage: (_, __) => false,
      ),
    );
  }

  // TODO: Should have some support for going up instead of back here. maybe `NavStack.onWillPop(controller)` delegate,
  //  or should it be on the RouteBuilder instead?
  @override
  Future<bool> popRoute() async => stackController.goBack();

  @override
  Future<void> setInitialRoutePath(String initialPath) {
    if (initialPath == "/")
      initialPath = stackController.widget.initialPath ?? initialPath;
    return super.setInitialRoutePath(initialPath);
  }

  @override
  Future<void> setNewRoutePath(String path) async =>
      stackController.path = path;

  void _recordHistoryEntry(String path) {
    if (path != _prevPath) {
      stackController.history.add(path);
    }
    _prevPath = path;
  }
}
