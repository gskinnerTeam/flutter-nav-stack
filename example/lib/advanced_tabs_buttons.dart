import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nav_stack/nav_stack.dart';

import 'advanced_tabs_demo_pages.dart';

/// This btn reads the global path to figure out if it should be "selected",
/// On pressed, it updates the global path with it's .target value.
/// It wraps Expanded() and is mean to be placed in a Row() widget.
/// All Scaffolds use this button in their tab menus.
class NavBtn extends StatelessWidget {
  final String target;
  final String? selectionAlias;
  final String label;

  const NavBtn(this.label, {Key? key, required this.target, this.selectionAlias}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // We're selected if the current path matches our target, or our alias
    bool isSelected = NavStack.of(context).path.contains(selectionAlias ?? target);
    TextStyle textStyle = TextStyle(fontSize: 22, color: isSelected ? Colors.black : Colors.blue);
    return Expanded(
      child: OutlinedButton(
          onPressed: () => NavStack.of(context).path = target,
          child: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text(label, style: textStyle))),
    );
  }
}

/// This buttons goes back one level in the nav-stack, and auto-hides itself on Web
class BackBtn extends StatelessWidget {
  Widget build(BuildContext context) =>
      kIsWeb ? SizedBox() : OutlinedButton(onPressed: NavStack.of(context).goBack, child: Text("<< Back"));
}

/// This buttons opens the details view and passes it as a parameter like `/details/92`
class OpenDetailsBtn extends StatelessWidget {
  const OpenDetailsBtn({Key? key, required this.child, required this.itemId}) : super(key: key);
  final Widget child;
  final String itemId;

  Widget build(BuildContext context) =>
      TextButton(onPressed: () => NavStack.of(context).path = "${DetailsPage.path}$itemId", child: child);
}

/// This buttons pops all details views, allowing us to jump back to whichever root opened them in the first place
class CloseDetailsBtn extends StatelessWidget {
  Widget build(BuildContext context) =>
      CloseButton(onPressed: () => NavStack.of(context).popMatching(DetailsPage.path));
}
