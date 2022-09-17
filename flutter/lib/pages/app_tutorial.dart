import 'package:flutter/material.dart';
import 'package:tutorial/tutorial.dart';

class app_tutorial extends StatefulWidget {
  const app_tutorial({Key? key}) : super(key: key);

  @override
  State<app_tutorial> createState() => _app_tutorialState();
}

class _app_tutorialState extends State<app_tutorial> {
  final keyMenu = GlobalKey();
  final keyContainer = GlobalKey();
  final keyChat = GlobalKey();

  List<TutorialItem> itens = [];
  @override
  void initState() {
    itens.addAll({
      TutorialItem(
          globalKey: keyMenu,
          touchScreen: true,
          top: 200,
          left: 50,
          children: [
            Text(
              "Ali é nosso menu , você consegue ver varias coisas nele",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            SizedBox(
              height: 100,
            )
          ],
          widgetNext: Text(
            "Toque para continuar",
            style: TextStyle(
              color: Colors.purple,
              fontWeight: FontWeight.bold,
            ),
          ),
          shapeFocus: ShapeFocus.oval),
      TutorialItem(
        globalKey: keyChat,
        touchScreen: true,
        top: 200,
        left: 50,
        children: [
          Text(
            "Qualquer duvida que aparecer , entre no nosso chat , estamos prontos para ajudar",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          SizedBox(
            height: 100,
          )
        ],
        widgetNext: Text(
          "Toque para continuar",
          style: TextStyle(
            color: Colors.purple,
            fontWeight: FontWeight.bold,
          ),
        ),
        shapeFocus: ShapeFocus.oval,
      ),
      TutorialItem(
        globalKey: keyContainer,
        touchScreen: true,
        bottom: 50,
        left: 50,
        children: [
          Text(
            "Nessa sessão você vai ter acesso a todas as  Rasteirinhas",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          SizedBox(
            height: 10,
          )
        ],
        widgetNext: Text(
          "Sair",
          style: TextStyle(
            color: Colors.purple,
            fontWeight: FontWeight.bold,
          ),
        ),
        shapeFocus: ShapeFocus.square,
      ),
    });

    Future.delayed(Duration(microseconds: 200)).then((value) {
      Tutorial.showTutorial(context, itens);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
