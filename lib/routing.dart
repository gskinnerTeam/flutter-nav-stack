import 'package:flutter/material.dart';

import 'nav_stack.dart';

class NavStackRouteParser extends RouteInformationParser<String> {
  @override
  Future<String> parseRouteInformation(RouteInformation routeInformation) async => routeInformation.location ?? "";

  @override
  RouteInformation? restoreRouteInformation(String path) => RouteInformation(location: path);
}

class NavStackDelegate extends RouterDelegate<String> with ChangeNotifier, PopNavigatorRouterDelegateMixin<String> {
  final NavStackController stackController;
  NavStackDelegate(this.stackController) {
    // When controller changes it's value, this will trigger a rebuild
    this.stackController.addListener(notifyListeners);
  }

  @override
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  String? get currentConfiguration => stackController.path;

  @override
  Widget build(BuildContext _) {
    return Material(
      child: Navigator(
        key: navigatorKey,
        transitionDelegate: NoAnimationTransitionDelegate(),
        pages: [
          // StackBuilder is wrapped in a MaterialPage and is the only Page ever in the Navigator
          MaterialPage(
            child: Builder(builder: (context) {
              return stackController.widget.stackBuilder(context, stackController);
            }),
          ),
        ],
        onPopPage: (_, __) => false,
      ),
    );
  }

  @override
  // TODO: Should have some support for going up instead of back here.
  // NavStack.onPop(controller) maybe?
  Future<bool> popRoute() async => stackController.goBack();

  @override
  Future<void> setNewRoutePath(String path) async {
    // Update controller which will cause the delegate to rebuilds
    stackController.path = path;
  }
}

// Boilerplate from here: https://api.flutter.dev/flutter/widgets/TransitionDelegate-class.html
class NoAnimationTransitionDelegate extends TransitionDelegate<void> {
  @override
  Iterable<RouteTransitionRecord> resolve({
    required List<RouteTransitionRecord> newPageRouteHistory,
    required Map<RouteTransitionRecord?, RouteTransitionRecord> locationToExitingPageRoute,
    required Map<RouteTransitionRecord?, List<RouteTransitionRecord>> pageRouteToPagelessRoutes,
  }) {
    final List<RouteTransitionRecord> results = <RouteTransitionRecord>[];

    for (final RouteTransitionRecord pageRoute in newPageRouteHistory) {
      if (pageRoute.isWaitingForEnteringDecision) {
        pageRoute.markForAdd();
      }
      results.add(pageRoute);
    }
    for (final RouteTransitionRecord exitingPageRoute in locationToExitingPageRoute.values) {
      if (exitingPageRoute.isWaitingForExitingDecision) {
        exitingPageRoute.markForRemove();
        final List<RouteTransitionRecord>? pagelessRoutes = pageRouteToPagelessRoutes[exitingPageRoute];
        if (pagelessRoutes != null) {
          for (final RouteTransitionRecord pagelessRoute in pagelessRoutes) {
            pagelessRoute.markForRemove();
          }
        }
      }
      results.add(exitingPageRoute);
    }
    return results;
  }
}
