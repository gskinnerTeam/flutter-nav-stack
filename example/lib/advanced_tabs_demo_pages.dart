import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nav_stack/nav_stack.dart';

import 'advanced_tabs_buttons.dart';

/// Sample Content Pages
class AppPaths {
  static const String tabsCategory = "tabs/";
  static const String settings = "settings/";
  static const String inbox = "inbox/";
}

class SomeStatefulPage extends StatefulWidget {
  SomeStatefulPage(String title, {Key? key}) : super(key: key) {
    this.title = title;
    print("${this} TITLE = $title");
  }
  late final String title;

  @override
  _SomeStatefulPageState createState() => _SomeStatefulPageState();
}

class _SomeStatefulPageState extends State<SomeStatefulPage> {
  String _filter = "";
  List<String>? items;
  TextEditingController txtController = TextEditingController();
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1), () {
      if (mounted == false) return;
      setState(() => items = List.generate(100, (index) => "Item: $index"));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (items == null) return Center(child: CircularProgressIndicator());
    // Filter Items
    final filteredItems = List.from(items!)
      ..removeWhere((name) => name.toLowerCase().contains(_filter.toLowerCase()) == false);
    return Column(
      children: [
        Row(
          children: [
            Text(widget.title, style: TextStyle(fontSize: 22)),
            Spacer(),
            Text("Search Filter:", style: TextStyle(fontSize: 16)),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                onChanged: (v) {
                  setState(() => _filter = v);
                },
                decoration: InputDecoration(border: OutlineInputBorder()),
              ),
            )),
          ],
        ),
        Expanded(
            child: ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (_, index) {
                  return OpenDetailsBtn(
                    itemId: "$index",
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8.0),
                      color: (index % 2 == 0 ? Colors.grey : Colors.white).withOpacity(.1),
                      child: Row(
                        children: [
                          SizedBox(
                              width: 100,
                              height: 100,
                              child: CachedNetworkImage(
                                  imageUrl: "https://source.unsplash.com/random/50x50?id=${widget.title}$index")),
                          Text(filteredItems[index]),
                        ],
                      ),
                    ),
                  );
                })),
      ],
    );
  }
}

class HomePage extends SomeStatefulPage {
  static const String path = "home";
  HomePage(String suffix) : super("Home Page, $suffix");
}

/// Settings
class ProfileSettings extends SomeStatefulPage {
  static const String path = "profile";
  ProfileSettings(String suffix) : super("Profile, $suffix");
}

class AlertSettings extends SomeStatefulPage {
  static const String path = "alerts";
  AlertSettings(String suffix) : super("Alerts, $suffix");
}

class BillingSettings extends SomeStatefulPage {
  static const String path = "billing";
  BillingSettings(String suffix) : super("Billing, $suffix");
}

/// Messages
enum InboxType { friends, unread, archived }

class InboxPage extends SomeStatefulPage {
  static const String friendsPath = "friends/";
  static const String unreadPath = "unread/";
  static const String archivedPath = "archived/";

  final InboxType pageType;
  InboxPage(this.pageType) : super("$pageType");
}

/// Compose
class ComposePage extends StatefulWidget {
  static const String path = "compose";
  @override
  _ComposePageState createState() => _ComposePageState();
}

class _ComposePageState extends State<ComposePage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BackBtn(),
          Expanded(
              child: Column(
            children: [
              Spacer(),
              Text("New Message:", style: TextStyle(fontSize: 32)),
              TextField(
                  maxLines: 10,
                  decoration: InputDecoration(border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)))),
              Spacer(flex: 3),
            ],
          ))
        ],
      ),
    );
  }
}

/// Details
class DetailsPage extends StatefulWidget {
  static const String path = "details/";

  DetailsPage({required this.itemId}) : super();
  final String? itemId;
  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  // Simulates a list of items loaded from the database.
  // Normally this would be driven by some API call or model that exists above this view.
  // The point of this is to just show how we can create a history-stack from a fullscreen view.
  List<String> items = List.generate(100, (index) => "$index");
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(children: [
            BackBtn(),
            Spacer(),
            CloseDetailsBtn(),
          ]),
          Text("${widget.itemId}", style: TextStyle(fontSize: 32)),
          Row(
            children: [
              OpenDetailsBtn(itemId: getId(-1), child: Text("<< prev item")),
              Spacer(),
              OpenDetailsBtn(itemId: getId(1), child: Text("next item >>")),
            ],
          ),
        ],
      ),
    );
  }

  String getId(int dir) {
    int currentIndex = items.indexOf(widget.itemId!);
    currentIndex += dir;
    if (currentIndex <= 0) {
      currentIndex = items.length - 1;
    } else if (currentIndex > items.length - 1) {
      currentIndex = 0;
    }
    return items[currentIndex];
  }
}
