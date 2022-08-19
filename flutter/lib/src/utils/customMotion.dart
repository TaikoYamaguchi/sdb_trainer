import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class CustomMotion extends StatefulWidget {
  final Function onOpen;
  final Function onClose;
  final Widget motionWidget;

  const CustomMotion(
      {Key? key,
      required this.onOpen,
      required this.onClose,
      required this.motionWidget})
      : super(key: key);

  @override
  _CustomMotionState createState() => _CustomMotionState();
}

class _CustomMotionState extends State<CustomMotion> {
  var controller;
  var myListener;
  bool isClosed = true;

  void animationListener() {
    if ((controller.ratio == 0.8) && widget.onClose != null && !isClosed) {
      isClosed = true;
      widget.onClose();
    }

    if ((controller.ratio == controller.startActionPaneExtentRatio) &&
        widget.onOpen != null &&
        isClosed) {
      isClosed = false;
      widget.onOpen();
      print("dismissss");
      controller.close(duration: const Duration(milliseconds: 3));
    }
  }

  @override
  void dispose() {
    controller.animation.removeListener(myListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    controller = Slidable.of(context);
    myListener = animationListener;

    controller.animation.addListener(myListener);

    return widget.motionWidget;
  }
}
