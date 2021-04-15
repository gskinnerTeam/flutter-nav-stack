import 'package:example/basic_demo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nav_stack/nav_stack.dart';

class HelloWorldDemo extends StatefulWidget {
  @override
  _HelloWorldDemoState createState() => _HelloWorldDemoState();
}

late NavStackController _controller;

class _HelloWorldDemoState extends State<HelloWorldDemo> {
  GlobalKey<NavStackController> navKey = GlobalKey();

  NavStackController get navStack => navKey.currentState!;
  @override
  void initState() {
    super.initState();
    RawKeyboard.instance.addListener((value) {
      if (value is RawKeyDownEvent) {
        if (value.logicalKey == LogicalKeyboardKey.digit1) _controller.path = "/login";
        if (value.logicalKey == LogicalKeyboardKey.digit2) _controller.path = "/profile";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return NavStack(
      stackBuilder: (context, controller) {
        _controller = controller;
        return PathStack(
          routes: {
            ["/"]: Container().buildStackRoute(onBeforeEnter: (_) {
              controller.redirect("/login");
              return true;
            }),
            ["/login"]: LoginScreen().buildStackRoute(),
            ["/profile"]: ProfileScreen().buildStackRoute(),
          },
        );
      },
    );
  }
}

class _TabScaffold extends StatelessWidget {
  const _TabScaffold(this.labels, {Key? key, required this.child}) : super(key: key);
  final List<String> labels;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: child),
        Row(
          children: [
            Expanded(
              child: TextButton(child: Text(labels[0]), onPressed: () => NavStack.of(context).path = labels[0]),
            ),
            Expanded(
              child: TextButton(child: Text(labels[1]), onPressed: () => NavStack.of(context).path = labels[1]),
            ),
          ],
        ),
      ],
    );
  }
}
