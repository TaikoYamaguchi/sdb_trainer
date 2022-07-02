import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/navigators/exercise_navi.dart';
import 'package:sdb_trainer/navigators/profile_navi.dart';
import 'package:sdb_trainer/pages/exercise.dart';
import 'package:sdb_trainer/pages/home.dart';
import 'package:sdb_trainer/pages/login.dart';
import 'package:sdb_trainer/pages/signup.dart';
import 'package:sdb_trainer/pages/profile.dart';
import 'package:sdb_trainer/pages/feed.dart';
import 'package:sdb_trainer/providers/bodystate.dart';
import 'package:sdb_trainer/providers/routinetime.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/loginState.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'dart:math' as math;

import 'statics.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  var _routinetimeProvider;
  var _workoutdataProvider;
  var _bodyStater;
  var _loginState;
  int _currentIndex = 0;
  var _userdataProvider;

  BottomNavigationBarItem _bottomNavigationBarItem(
      String iconName, String label) {
    return BottomNavigationBarItem(
      icon: SvgPicture.asset("assets/svg/${iconName}_off.svg"),
      activeIcon: SvgPicture.asset("assets/svg/${iconName}_on.svg"),
      label: label,
    );
  }



  Widget _bottomNavigationBarwidget() {
    return BottomNavigationBar(
      backgroundColor: Color(0xFF212121),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.white,
      selectedFontSize: 20,
      unselectedItemColor: Color(0xFF717171),
      unselectedFontSize: 20,
      onTap: (int index) {
        print(index);
        setState(() {
          _bodyStater.change(index);
        });
      },
      currentIndex: _bodyStater.bodystate,
      items: [
        _bottomNavigationBarItem("home", "홈"),
        _bottomNavigationBarItem("dumbel", "운동"),
        _bottomNavigationBarItem("feed", "피드"),
        _bottomNavigationBarItem("calendar", "기록"),
        _bottomNavigationBarItem("profile", "프로필"),
      ],
    );
  }

  Widget _bodyWidget() {
    switch (_bodyStater.bodystate) {
      case 0:
        return Home();

      case 1:
        return TabNavigator();

      case 2:
        return Feed();

      case 3:
        return Calendar();

      case 4:
        return TabNavigator();
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    _bodyStater = Provider.of<BodyStater>(context, listen: true);
    _loginState = Provider.of<LoginPageProvider>(context);
    _userdataProvider = Provider.of<UserdataProvider>(context, listen: false);
    _userdataProvider.getUsersFriendsAll();
    _workoutdataProvider =
        Provider.of<WorkoutdataProvider>(context, listen: false);
    _workoutdataProvider.getdata();
    _routinetimeProvider =
        Provider.of<RoutineTimeProvider>(context, listen: false);
    return Scaffold(
      body: _loginState.isLogin
          ? IndexedStack(
          index: _bodyStater.bodystate,
          children: <Widget>[
              Home(),
              TabNavigator(),
              Feed(),
              Calendar(),
              TabProfileNavigator()
            ])
          : _loginState.isSignUp
              ? SignUpPage()
              : LoginPage()
      ,
      floatingActionButton: (_routinetimeProvider.isstarted && _bodyStater.bodystate != 1)
          ? ExpandableFab(
        distance: 105,
        children: [
          SizedBox(
              width: 100,
              height: 40,
              child: FlatButton(
                  color: Colors.blue,
                  textColor: Colors.white,
                  disabledColor: Color.fromRGBO(246, 58, 64, 20),
                  disabledTextColor: Colors.black,
                  padding: EdgeInsets.all(8.0),
                  splashColor: Colors.blueAccent,
                  onPressed: () {
                    _routinetimeProvider.restcheck();
                  },
                  child: Consumer<RoutineTimeProvider>(
                    builder: (builder, provider, child) {
                      return Text(provider.userest ?provider.timeron.toString() :provider.routineTime.toString());
                    }
                  ))),
          ActionButton(onPressed: null, icon: Icon(Icons.stop),)
        ],)
          : null
      ,

      bottomNavigationBar:
          _loginState.isLogin ? _bottomNavigationBarwidget() : null,
    );
  }
}

@immutable
class ExpandableFab extends StatefulWidget {

  const ExpandableFab({Key? key, this.initialOpen,
    required this.distance,
    required this.children,}) : super(key: key);

  final bool? initialOpen;
  final double distance;
  final List<Widget> children;

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin{
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;



  @override
  void initState() {
    super.initState();
    _open = widget.initialOpen ?? false;
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          _buildTapToCloseFab(),
          ..._buildExpandingActionButtons(),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;
    final step = widget.distance ;
    for (var i = 0, distances = 50.0;
    i < count;
    i++, distances += step) {
      children.add(
        _ExpandingActionButton(
          directionInDegrees: 0,
          maxDistance: distances,
          progress: _expandAnimation,
          child: widget.children[i],
        ),
      );
    }
    return children;
  }

  Widget _buildTapToCloseFab() {
    return SizedBox(
      width: 56.0,
      height: 56.0,
      child: Center(
        child: Material(
          shape: CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4.0,
          child: InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.close,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: _open,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _open ? 0.7 : 1.0,
          _open ? 0.7 : 1.0,
          1.0,
        ),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _open ? 0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: FloatingActionButton(
            onPressed: (){
              print('open');
              _toggle();
              },
            child: Consumer<RoutineTimeProvider>(
              builder: (builder, provider, child) {
                return Text(provider.userest ?provider.timeron.toString() :provider.routineTime.toString());
              }
            ),
          ),
        ),
      ),
    );
  }

}

@immutable
class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
  });

  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          directionInDegrees ,
          progress.value * maxDistance,
        );
        return Positioned(
          right: 4.0 + offset.dx,
          bottom: 8 + offset.dy,
          child: Transform.rotate(
            angle: (1.0 - progress.value) * math.pi / 2,
            child: child!,
          ),
        );
      },
      child: FadeTransition(
        opacity: progress,
        child: child,
      ),
    );
  }
}

@immutable
class ActionButton extends StatelessWidget {
  const ActionButton({
    Key? key,
    this.onPressed,
    required this.icon,
  }) : super(key: key);

  final VoidCallback? onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 40,
      height: 40,
      child: Center(
        child: Material(

          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          color: theme.colorScheme.secondary,
          elevation: 4.0,
          child: IconButton(
            iconSize: 20,
            onPressed: onPressed,
            icon: icon,
            color: theme.colorScheme.onSecondary,
          ),
        ),
      ),
    );
  }
}


