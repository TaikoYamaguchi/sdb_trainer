import 'dart:async';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gif/flutter_gif.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:sdb_trainer/pages/exercise/exercise_done.dart';
import 'package:sdb_trainer/pages/search/exercise_guide.dart';

class ExerciseGuideBottomModal {
  void exguide(int eindex, BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              color: Theme.of(context).canvasColor,
            ),
            child: Column(
              children: [
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    color: Theme.of(context).canvasColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  child: Container(
                    height: 6.0,
                    width: 80.0,
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColorDark,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8.0))),
                  ),
                ),
                Expanded(
                  child: ExerciseGuide(
                    eindex: eindex,
                    isroutine: true,
                  ),
                ),
              ],
            ));
      },
    );
  }
}
