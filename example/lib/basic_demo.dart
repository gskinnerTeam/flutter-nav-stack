import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nav_stack/nav_stack.dart';

class BasicDemo extends StatelessWidget {
  @override
  Widget build(BuildContext _) {
    /// Change this value to test the route guard. When false, you should not be able to access the /in routes.
    bool isConnected = false;
    return NavStack(
      stackBuilder: (context, controller) {
        return PathStack(
          path: controller.path,
          scaffoldBuilder: (_, stack) => _MyScaffold(stack),
          routes: {
            ["/login", "/"]: LoginScreen().buildStackRoute(),
            ["/in/"]: PathStack(
              path: controller.path,
              basePath: "/in/",
              routes: {
                ["profile/:id"]: ProfileScreen().buildStackRoute(),
                ["settings"]: SettingsScreen().buildStackRoute(),
              },
            ).buildStackRoute(onBeforeEnter: (_) {
              if (!isConnected) controller.redirect("/login", () => showAuthWarning(context));
              return isConnected; // If we return false, the route will not be entered.
            }),
          },
        );
      },
    );
  }
}

void showAuthWarning(BuildContext context) {
  showDialog(context: context, builder: (_) => AuthErrorDialog());
}

class AuthErrorDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: GestureDetector(
            onTap: () => Navigator.of(context).pop(), // Pop still works for dialogs!
            child: Container(width: 400, height: 300, color: Colors.purple, child: buildText("No soup for you!!"))));
  }
}

class _MyScaffold extends StatelessWidget {
  _MyScaffold(this.child);
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final navStack = NavStack.of(context);
    Widget buildBtn(String value) =>
        Expanded(child: TextButton(child: Text(value), onPressed: () => navStack.path = value));
    return Scaffold(
      body: Column(
        children: [
          Row(children: [buildBtn("/in/profile/99"), buildBtn("/in/settings")]),
          Flexible(child: child),
        ],
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(child: Text("LoginScreen"));
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(child: Text("ProfileScreen"));
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(child: Text("SettingsScreen"));
}

Text buildText(String value) => Text(value, style: TextStyle(fontSize: 32));
