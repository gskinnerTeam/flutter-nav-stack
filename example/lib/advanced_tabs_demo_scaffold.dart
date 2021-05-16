import 'package:example/advanced_tabs_demo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nav_stack/nav_stack.dart';

import 'advanced_tabs_buttons.dart';
import 'advanced_tabs_demo_pages.dart';

/// Scaffolds
class MainScaffold extends StatefulWidget {
  final Widget child;
  final String currentPath;
  final VoidCallback onComposePressed;
  const MainScaffold(
      {Key? key,
      required this.child,
      required this.currentPath,
      required this.onComposePressed})
      : super(key: key);

  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Stack(
      children: [
        BackBtn(),
        Padding(
          padding: const EdgeInsets.all(8.0).copyWith(top: kIsWeb ? 0 : 40),
          child: Column(
            children: [
              // show a pretend url bar when not on web, for easier testing
              if (kIsWeb == false) ...[
                Container(
                  padding: EdgeInsets.all(12),
                  color: Colors.grey.shade200,
                  width: double.infinity,
                  child: Text("https://myflutterapp/${widget.currentPath}",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ],
              Expanded(child: widget.child),
              Row(children: [
                NavBtn("home", target: AppPaths.tabsCategory + HomePage.path),
                NavBtn("settings",
                    // TODO: Would be nice to remember the previous tab position. best option is to hoist state?
                    target: AppPaths.tabsCategory +
                        AppPaths.settings +
                        ProfileSettings.path,
                    // Using an alias, so the btn knows to highlight on this portion of the path
                    selectionAlias: AppPaths.tabsCategory + AppPaths.settings),
                NavBtn("inbox",
                    // TODO: Would be nice to remember the previous tab position. best option is to hoist state?
                    target: AppPaths.tabsCategory +
                        AppPaths.inbox +
                        InboxPage.friendsPath,
                    // Using an alias, so the btn knows to highlight on this portion of the path
                    selectionAlias: AppPaths.tabsCategory + AppPaths.inbox),
              ]),
            ],
          ),
        ),
        Positioned(
          bottom: 80,
          right: 12,
          child: FloatingActionButton(
              onPressed: widget.onComposePressed, child: Icon(Icons.add)),
        )
      ],
    ));
  }
}

class SettingsScaffold extends StatefulWidget {
  final Widget child;

  const SettingsScaffold({Key? key, required this.child}) : super(key: key);

  @override
  _SettingsScaffoldState createState() => _SettingsScaffoldState();
}

class _SettingsScaffoldState extends State<SettingsScaffold> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(children: [
        Row(
          children: [
            NavBtn("profile",
                target:
                    "${AppPaths.tabsCategory}${AppPaths.settings}${ProfileSettings.path}"),
            NavBtn("alerts",
                target:
                    "${AppPaths.tabsCategory}${AppPaths.settings}${AlertSettings.path}"),
            NavBtn("Billing",
                target:
                    "${AppPaths.tabsCategory}${AppPaths.settings}${BillingSettings.path}"),
          ],
        ),
        Expanded(child: widget.child),
      ]),
    );
  }
}

class InboxScaffold extends StatefulWidget {
  final Widget child;

  const InboxScaffold({Key? key, required this.child}) : super(key: key);

  @override
  _InboxScaffoldState createState() => _InboxScaffoldState();
}

class _InboxScaffoldState extends State<InboxScaffold> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(children: [
        Row(
          children: [
            // TODO: Create some sort of AppPath.builder method? Or many methods???
            NavBtn("friends",
                target:
                    "${AppPaths.tabsCategory}${AppPaths.inbox}${InboxPage.friendsPath}"),
            NavBtn("unread",
                target:
                    "${AppPaths.tabsCategory}${AppPaths.inbox}${InboxPage.unreadPath}"),
            NavBtn("archived",
                target:
                    "${AppPaths.tabsCategory}${AppPaths.inbox}${InboxPage.archivedPath}"),
          ],
        ),
        Expanded(child: widget.child),
      ]),
    );
  }
}
