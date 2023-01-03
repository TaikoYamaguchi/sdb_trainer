import 'package:flutter/material.dart';
import 'package:sdb_trainer/pages/exSearch.dart';

class SearchNavigatorRoutes {
  static const String root = '/';
  static const String detail = '/detail';
}

class SearchNavigator extends StatefulWidget {
  const SearchNavigator({Key? key}) : super(key: key);

  @override
  State<SearchNavigator> createState() => SearchNavigatorState();
}

class SearchNavigatorState extends State<SearchNavigator> {
  GlobalKey<NavigatorState> exKey = GlobalKey<NavigatorState>();

  void _push(BuildContext context) {
    var routeBuilders = _routeBuilders(context);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                routeBuilders[SearchNavigatorRoutes.detail]!(context)));
  }

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context) {
    return {
      SearchNavigatorRoutes.root: (context) => ExSearch(),
    };
  }

  @override
  Widget build(BuildContext context) {
    var routeBuilders = _routeBuilders(context);
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Navigator(
          initialRoute: SearchNavigatorRoutes.root,
          onGenerateRoute: (routeSettings) {
            return MaterialPageRoute(
                builder: (context) =>
                    routeBuilders[routeSettings.name]!(context));
          }),
    );
  }
}
