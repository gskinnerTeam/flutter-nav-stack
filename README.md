<img src="http://screens.gskinner.com/shawn/example_g9GiSnHDVp.png" alt="" />

# nav_stack

A simple but powerful path-based navigation router with full web-browser and deeplink support.

`NavStack` maintains a stateful list of routes which you define declaratively while providing a powerful imperitive API for controlling your navigation history stack.

## 🔨 Installation
```yaml
dependencies:
  nav_stack: ^0.0.1
```

### ⚙ Import

```dart
import 'package:nav_stack/nav_stack.dart';
```

## 🕹️ Usage
When it comes to declaring your routes, `NavStack` uses `PathStack` under the hood. There is a wide variety of routing configutations you can create, and they are explained in some detail here:  https://pub.dev/packages/path_stack.

`NavStack` builds on top of `PathStack` by connecting it's `.path` property it to `MaterialApp.router` and supplying a strong imperitive controller. This creates a turn-key navigation router that is very simple and expressive, but also powerful and flexible.

### Hello NavStack
In it's simplest form, it might look something like:
```dart
return NavStack(
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
```

This might not look like much, but  there is a lot going on here.
* This is fully bound to the browser path,
* It will also receive deeplink start up values on any platform,
* It provides a `controller` which you can use to easily change the global path at any time,
* All routes are persistent, maintaining their state as you navigate between them (optional)
* A persistent scaffold wraps all children, and it is also stateful

Note: String literals are used here for brevity. In real usage, it is recommended you give each page it's own path property like `HomePage.path` or `LoginScreen.path`. This makes it much easier to construct and share links from other sections in your app.

### Nested Routes and Guards
Other features like nested routes, and route guards are also supported. In this example there is a protected section, that requires the user to be logged in. Otherwise they are redirected to `/home`:
```dart
return NavStack(
  stackBuilder: (context, controller) {
    return PathStack(
      path: controller.path,
      scaffoldBuilder: (_, stack) => _MyScaffold(stack),
      routes: {
        [LoginScreen.path, "/"]: LoginScreen().buildStackRoute(),
        ["/in/"]: PathStack(
          path: controller.path,
          routes: {
            ["/in/${ProfileScreen.path}:id"]: ProfileScreen().buildStackRoute(),
            ["/in/${SettingsScreen.path}"]: SettingsScreen().buildStackRoute(),
          },
        ).buildStackRoute(onBeforeEnter: (_) {
          if (!isConnected) controller.redirect("/login", () => showAuthWarning(context));
          return isConnected; // returning false here will stop the page from changing
        }),
      },
    );
  },
);
```

There are many other options you can provide to the `PathStack`, including `unknownPathBuilder`, `transitionBuilder` and, `basePath`. For an exhaustive list, check out this example:
* https://github.com/gskinnerTeam/flutter_path_stack/blob/master/example/lib/full_api_example.dart

### Defining paths and arguments
Both path-based or query-string args are supported by `PathStack` under the hood. For more information on the routing rules and options check out the docs in the `PathStack` package: https://pub.dev/packages/path_stack#defining-paths

As a quick refresher, consuming path-based args (`/billing/88/99`) looks like:
```
["billing/:foo/:bar"]:
    StackRouteBuilder(builder: (_, args) => BillingPage(id: "${args["foo"]}_${args["bar"]}")),
```

Consuming query-string args (`/billing/?foo=88&bar=99`) looks like:
```
["billing/"]:
    StackRouteBuilder(builder: (_, args) => BillingPage(id: "${args["foo"]}_${args["bar"]}")),
```


For a some more complex code examples of path structure you can check here:
* https://github.com/gskinnerTeam/flutter_path_stack/blob/master/example/lib/simple_tab_example.dart
* https://github.com/gskinnerTeam/flutter_path_stack/blob/master/example/lib/advanced_tab_example.dart

### Imperitive API

`NavStack` offers a strong imperitive API for interacting with your navigation state.

* `NavStackController` can be looked up at anytime with `NavStack.of(context)`
* `navStack.path` to change the global routing path
* `navStack.history` to access the history of path entries so far, you can modify and re-assign this list as needed
* `navStack.goBack()` to go back one level in the history
* `navStack.popUntil()`, `navStack.popMatching()`, `navStack.replacePath()` etc

Additionally, you can still make full use of the old `Navigator.push()` API, and `showDialog`, `showBottomSheet` etc, just be aware that none of these things will be reflected in the navigation path. For example, you can not deeplink directly to a dialog or a bottom sheet.

**Important:** Any calls to `Navigator.of(context).pop()` from within the `NavStack` children will be ignored. However, you can still use them from within Dialogs, BottomSheets or full-screen PageRoutes triggered with `Navigator.push()`. If you'd like to `pop()` something that is a descendant of `NavStack` just use `NavStack.of(context).goBack()`.

### MaterialApp.router()

`NavStack` creates a default `MaterialApp.router` internally, but you can provide a custom one if you need to modify the settings. Just use the `appBuilder` and pass along the provided `router` and `delegate` instances:
```
return NavStack(
  appBuilder: (router, delegate) => MaterialApp.router(
    routeInformationParser: delegate,
    routerDelegate: router,
    debugShowCheckedModeBanner: false,
  ),
  entries: { ... }
```

**Note:** Do not wrap a second `MaterialApp` around `NavStack` or you will break all browser support and deeplinking.

## 🐞 Bugs/Requests

If you encounter any problems please open an issue. If you feel the library is missing a feature, please raise a ticket on Github and we'll look into it. Pull request are welcome.

## 📃 License

MIT License
