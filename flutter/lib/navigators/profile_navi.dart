import 'package:flutter/material.dart';
import 'package:sdb_trainer/pages/profile.dart';

class TabProfileNavigatorRoutes {
  static const String root = '/';
  static const String detail = '/detail';
}

class TabProfileNavigator extends StatelessWidget {
  const TabProfileNavigator({Key? key}) : super(key: key);

  void _push(BuildContext context) {
    var routeBuilders = _routeBuilders(context);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                routeBuilders[TabProfileNavigatorRoutes.detail]!(context)));
  }

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context) {
    return {
      TabProfileNavigatorRoutes.root: (context) => Profile(),
    };
  }

  @override
  Widget build(BuildContext context) {
    var routeBuilders = _routeBuilders(context);

    return Navigator(
        initialRoute: TabProfileNavigatorRoutes.root,
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
              builder: (context) =>
                  routeBuilders[routeSettings.name]!(context));
        });
  }
}
