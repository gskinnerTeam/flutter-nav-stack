import 'package:example/basic_demo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nav_stack/nav_stack.dart';

class HelloWorldDemo extends StatefulWidget {
  @override
  _HelloWorldDemoState createState() => _HelloWorldDemoState();
}

class _HelloWorldDemoState extends State<HelloWorldDemo> {
  GlobalKey<NavStackController> navKey = GlobalKey();
  NavStackController get navStack => navKey.currentState!;
  @override
  void initState() {
    super.initState();
    RawKeyboard.instance.addListener((value) {
      if (value is RawKeyDownEvent) {
        if (value.logicalKey == LogicalKeyboardKey.digit1) NavStack.of(context).path = "/home";
        if (value.logicalKey == LogicalKeyboardKey.digit2) NavStack.of(context).path = "/profile";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return NavStack(
      appBuilder: (router, delegate) => MaterialApp.router(
        routeInformationParser: delegate,
        routerDelegate: router,
        debugShowCheckedModeBanner: false,
      ),
      stackBuilder: (context, controller) => PathStack(
        path: controller.path,
        // Use scaffold builder to wrap all our pages in a tab-menu
        scaffoldBuilder: (_, stack) => _TabScaffold(["/home", "/profile"], child: stack),
        routes: {
          // Alias "/" will catch the default path and send it to /home
          ["/home", "/"]: LoginScreen().buildStackRoute(),
          ["/profile"]: ProfileScreen().buildStackRoute(),
        },
      ),
    );
  }
}

class _TabScaffold extends StatelessWidget {
  const _TabScaffold(this.labels, {Key? key, required this.child}) : super(key: key);
  final List<String> labels;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: TextButton(child: Text("home"), onPressed: () => NavStack.of(context).path = "/home")),
        Expanded(child: TextButton(child: Text("profile"), onPressed: () => NavStack.of(context).path = "/profile")),
      ],
    );
  }
}
