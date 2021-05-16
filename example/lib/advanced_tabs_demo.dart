import 'package:flutter/material.dart';
import 'package:nav_stack/nav_stack.dart';

import 'advanced_tabs_demo_pages.dart';
import 'advanced_tabs_demo_scaffold.dart';

class AdvancedTabsDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NavStack(
        initialPath: AppPaths.tabsCategory + HomePage.path,
        stackBuilder: (_, controller) {
          void _handleComposePressed() => controller.path = ComposePage.path;
          return PathStack(
            routes: {
              [AppPaths.tabsCategory]: PathStack(
                // Main scaffold is wrapped here
                scaffoldBuilder: (context, stack) => MainScaffold(
                  child: stack,
                  currentPath: NavStack.of(context).path,
                  // Goto /compose when this is pressed
                  onComposePressed: _handleComposePressed,
                ),
                transitionBuilder: (_, stack, animation) =>
                    FadeTransition(opacity: animation, child: stack),
                routes: {
                  // Home
                  [HomePage.path]: HomePage("").buildStackRoute(),
                  // Settings
                  [AppPaths.settings]: PathStack(
                    // Settings scaffold is wrapped here
                    scaffoldBuilder: (_, child) =>
                        SettingsScaffold(child: child),
                    routes: {
                      [ProfileSettings.path]:
                          ProfileSettings("").buildStackRoute(),
                      [AlertSettings.path]: AlertSettings("").buildStackRoute(),
                      [BillingSettings.path]: BillingSettings("")
                          .buildStackRoute(maintainState: false),
                    },
                  ).buildStackRoute(),
                  // Inbox
                  [AppPaths.inbox]: PathStack(
                    scaffoldBuilder: (_, child) => InboxScaffold(child: child),
                    routes: {
                      [InboxPage.friendsPath]:
                          InboxPage(InboxType.friends).buildStackRoute(),
                      [InboxPage.unreadPath]:
                          InboxPage(InboxType.unread).buildStackRoute(),
                      [InboxPage.archivedPath]:
                          InboxPage(InboxType.archived).buildStackRoute(),
                    },
                  ).buildStackRoute(),
                },
              ).buildStackRoute(),

              /// Non stateful full-screen route
              [ComposePage.path]:
                  ComposePage().buildStackRoute(maintainState: false),

              /// Inject itemId param into detailsView
              [DetailsPage.path + ":id"]: StackRouteBuilder(
                maintainState: false,
                builder: (_, args) => DetailsPage(itemId: args["id"]),
              )
            },
          );
        });
  }
}
