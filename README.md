# nav_stack

A simple but powerful path-based routing system, based on MaterialApp.router (Nav 2.0). It has browser / deeplink support and maintains a history stack as new routes are added.

Internally `NavStack` uses an `IndexedStack` to maintain a stateful list of routes which are defined declaratively and bound to the current `MaterialApp.router` path. It also provides a flexible imperative API for changing the path and modifying the history stack.

## 🔨 Installation
```yaml
dependencies:
  nav_stack: ^0.0.1
```

### ⚙ Import

```dart
import 'package:nav_stack/nav_stack.dart';
```

## 🕹️ Basic Usage

### Hello NavStack
`NavStack` wraps `MaterialApp`, so you can include it as the root-element in your App:
```dart
void main() {
  runApp(
    MaterialApp.router(
      routeInformationParser: NavStackParser(),
      routerDelegate: NavStackDelegate(
        // Declare your full tree of page routes,
        // PathStack is a component that will automatically figure out what to show for the current navigation path
        onGenerateStack: (context, nav) => PathStack(
          routes: {
            ["/"]: HomeScreen().toStackRoute(),
            ["/messages"]: MessagesScreen().toStackRoute(),
            ["/profile"]: ProfileScreen().toStackRoute(),
          },
        ),
      ),
    ),
  );
}
```

Change path using a simple api:

```dart
void showPage1() => NavStack.of(context).path = "/page1";
void showSubPage2() => NavStack.of(context).path = "/page3/subPage2";
```

This might not look like much, but  there is a lot going on here.
* This is fully bound to the browser path,
* It will also receive deep-link start up values on any platform,
* It provides a `controller` which you can use to easily change the global path at any time,
* All routes are persistent, maintaining their state as you navigate between them (optional)

#### buildStackRoute() vs StackRouteBuilder?
Each entry in the `PathStack` requires a `StackRouteBuilder()` but to increase readability, we have added a `.buildStackRoute()` extension method on all Widgets. The only difference between the two, is that the full `StackRouteBuilder` allows you to inject args directly into your view using it's `builder` method.

When your view does not require args, then the extensions tend to be more readable:
```
// These calls are identical
["/login"]: LoginScreen().buildStackRoute(),
VS
["/login"]: StackRouteBuilder(builder: (_, __) => LoginScreen()),
```

### Customizing MaterialApp

`NavStack` creates a default `MaterialApp.router` internally, but you can provide a custom one if you need to modify the settings. Just use the `appBuilder` and pass along the provided `parser` and `delegate` instances:
```dart
runApp(NavStack(
  appBuilder: (delegate, parser) => MaterialApp.router(
    routeInformationParser: parser,
    routerDelegate: delegate,
    debugShowCheckedModeBanner: false,
  ),
  stackBuilder: ...)
```

**Note:** Do not wrap a second `MaterialApp` around `NavStack` or you will break all browser support and deep-linking.

#### Nesting
One of the key features of this package is that it has top-level support for wrapping child routes in a shared widget (aka 'nesting'). To supply a custom Scaffold around all child routes use the `scaffoldBuilder`. For example, a classic 'Tab Style' app could look like:
```dart
runApp(NavStack(
  stackBuilder: (context, controller) => PathStack(
    // Use scaffold builder to wrap all our pages in a stateful tab-menu
    scaffoldBuilder: (_, stack) => _TabScaffold(["/home", "/profile"], child: stack),
    routes: {
      ["/home"]: LoginScreen().buildStackRoute(),
      ["/profile"]: ProfileScreen().buildStackRoute(),
})));
...
class _TabScaffold extends StatelessWidget {
  ...
  Widget build(BuildContext context) {
    return Column(
      children: [
        // The current route
        Expanded(child: child),
        // A row of btns that call `NavStack.of(context).path = value` when pressed
        Row(children: [ Expanded(child: TextButton(...)), Expanded(child: TextButton(...)) ]),
      ]);}
}
```

Additionally, you can nest  `PathStack` widgets to create sub-sections. Each with their own scaffold. For example here we wrap a nested-scaffold around all routes in the "/settings/" section of our app:
```dart
runApp(NavStack(
  stackBuilder: (context, controller) {
    return PathStack(
      scaffoldBuilder: (_, stack) => OuterTabScaffold(stack),
      routes: {
        ["/login", "/"]: LoginScreen().buildStackRoute(),
        // Nest a 2nd PathStack so all settings pages can share a secondary tab menu
        ["/settings/"]: PathStack(
          scaffoldBuilder: (_, stack) => InnerTabScaffold(stack),
          routes: {
            ["profile"]: ProfileScreen().buildStackRoute(),
            ["alerts"]: AlertsScreen().buildStackRoute(),
          },
        ).buildStackRoute(),
},);},));
```

#### Path Parsing Rules:

There are a number of rules that determine how paths are routed:

* Routes with no trailing slash must an exact match:
  * eg, `/details` matches only `/details` not `/details/`, `/details/12` or `/details/?id=12`
  * a special case is made for `/` which is always an exact match
* Routes with a trailing slash, will accept a suffix,
  * eg, `/details/` matches any of `/details/`, `/details/12`, `/details/id=12&foo=99` etc
  * this allows endless levels of nesting and relative routes
* If route has multiple paths, only the first one will be considered for the suffix check
    * eg, `["/details", "/details/"]` requires exact match on either path
    * eg, `["/details/", "/details"]` allows suffix on either path

### Defining path and query-string arguments

Both path-based (`/billing/88/99`) or query-string (`/billing/?foo=88&bar=99`) args are supported.

In order to parse the args before they enter your view, you can use the `StackRouteBuilder()`.
Consuming path-based args looks like:
```
["billing/:foo/:bar"]:
    StackRouteBuilder(builder: (_, args) => BillingPage(foo: args["foo"], bar: args["bar"])),
```

Consuming query-string args looks like:
```
["billing/"]:
    StackRouteBuilder(builder: (_, args) => BillingPage(id: "${args["foo"]}_${args["bar"]}")),
```

If you would like to access the args from within your view, and parse them there, you can just do:
```
NavStack.of(context).args;
```

For more information on how paths are parsed check out https://pub.dev/packages/path_to_regexp.
To play with different routing schemes, you can use this demo: https://path-to-regexp.web.app/

### Imperative API

`NavStack` offers a strong imperative API for interacting with your navigation state.

* `NavStackController` can be looked up at anytime with `NavStack.of(context)`
* `navStack.path` to change the global routing path
* `navStack.history` to access the history of path entries so far, you can modify and re-assign this list as needed
* `navStack.goBack()` to go back one level in the history
* `navStack.popUntil()`, `navStack.popMatching()`, `navStack.replacePath()` etc

### Keeping it Old School

Importantly, you can still make full use of the old `Navigator.push()`, `showDialog`, `showBottomSheet` APIs, just be aware that none of these routes will be reflected in the navigation path. This can be quite handy for user-flows that do not necessarily need to be bound to browser history.

**Important:** The entire `NavStack` exists within a single `PageRoute`. This means that calls to `Navigator.of(context).pop()` from within the `NavStack` children will be ignored. However, you can still use `.pop()` them from within Dialogs, BottomSheets or full-screen PageRoutes triggered with `Navigator.push()`.

## 🕹 Advanced Usage
In addition to basic nesting and routing, `NavStack` supports advanced features including Aliases, Regular Expressions and Route Guards.

#### Regular Expressions
One powerful aspect of the path-base args is you can append Regular Expressions to the match.
* eg, a route of `/user/:foo(\d+)` will match '/user/12' but not '/user/alice'
* Don't worry if you don't know Regular Expressions, they are optional, and best used for advanced use cases

For more details on this parsing, check out the `PathToRegExp` docs:
https://pub.dev/packages/path_to_regexp

#### Aliases

Each route entry can have multiple paths allowing it to match any of them. For example, we can setup a route to match both `/home` and `/`:
```
["/home", "/"]: LoginScreen().buildStackRoute(),
```
Or a route that accepts optional named params:
```
["/messages/", "/messages/:messageId"]: // matches both "/messages/" and "messages/99"
    StackRouteBuilder(builder: (_, args) => MessageView(args["messageId"] ?? "")
```

#### Route Guards

Guards allow you to intercept a navigation event on a per-route basis. Commonly used to prevent deep-links into unauthorized app sections.

To do this you can use the `StackRouteBuilder.onBeforeEnter` callback to run your own custom logic, and decide whether to block the change.

For example, this guard will redirect to `LoginScreen` and show a warning dialog (but you can do whatever you want):
```dart
// You can use either the `buildStackRoute` or `StackRouteBuilder` to add guards
["/admin"]: AdminPanel().buildStackRoute(onBeforeEnter: (_, __) => guardAuthSection()),
["/admin"]: StackRouteBuilder(builder: (_, __) => AdminPanel(), onBeforeEnter: (_, __) => guardAuthSection() )
...
bool guardAuthSection() {
  if (!appModel.isLoggedIn){
   // Schedule a redirect next frame
   NavStack.of(context).redirect("/login", () => showAuthWarningDialog(context));
   return false; // If we return false, the original route will not be entered.
  }
  return true;
}
```
Since guards are just functions, you can easily re-use them across routes, and they can also be applied to entire sections by nesting a `PathStack` component.

#### Putting it Together
Here's a a more complete example showing nested stacks, and an entire section that requires the user to be logged in. Otherwise they are redirected to `/login`:
```dart
bool isLoggedIn = false;

return NavStack(
  stackBuilder: (context, controller) {
    return PathStack(
      scaffoldBuilder: (_, stack) => _MyScaffold(stack),
      routes: {
        ["/login", "/"]: LoginScreen().buildStackRoute(),
        ["/in/"]: PathStack(
          routes: {
            ["profile/:profileId"]:
                StackRouteBuilder(builder: (_, args) => ProfileScreen(profileId: args["profileId"] ?? "")),
            ["settings"]: SettingsScreen().buildStackRoute(),
          },
        ).buildStackRoute(onBeforeEnter: (_) {
          if (!isLoggedIn) controller.redirect("/login", () => showAuthWarning(context));
          return isLoggedIn; // If we return false, the route will not be entered.
        }),
      },
    );
  },
);
...
void handleLoginPressed() => NavStack.of(context).path = "/login";
void showProfile() => NavStack.of(context).path = "/in/profile/23"; // Blocked
void showSettings() => NavStack.of(context).path = "/in/settings"; // Blocked
```

Note: String literals (`"/home"`) are used here for brevity and clarity. In real usage, it is recommended you give each page it's own path property like `HomePage.path` or `LoginScreen.path`. This makes it much easier to construct and share links from other sections in your app: `controller.path = "${SettingsPage.path}{ProfilePage.path}$profileId"`

There are many other options you can provide to the `PathStack`, including `unknownPathBuilder`, `transitionBuilder` and, `basePath`. For an exhaustive list, check out this example:
* https://github.com/gskinnerTeam/flutter_path_stack/blob/master/example/lib/full_api_example.dart
* https://github.com/gskinnerTeam/flutter_path_stack/blob/master/example/lib/simple_tab_example.dart
* https://github.com/gskinnerTeam/flutter_path_stack/blob/master/example/lib/advanced_tab_example.dart

## 🐞 Bugs/Requests

If you encounter any problems please open an issue. If you feel the library is missing a feature, please raise a ticket on Github and we'll look into it. Pull request are welcome.

## 📃 License

MIT License
