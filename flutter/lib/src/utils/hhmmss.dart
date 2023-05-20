import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'dart:math' as math;

import 'package:sdb_trainer/providers/themeMode.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/repository/workout_repository.dart';
import 'package:sdb_trainer/src/utils/util.dart';

class TimeInputField extends StatefulWidget {
  int duration;
  int rindex;
  int pindex;
  int index;
  TimeInputField(
      {Key? key,
      required this.duration,
      required this.rindex,
      required this.pindex,
      required this.index})
      : super(key: key);

  @override
  _TimeInputFieldState createState() => _TimeInputFieldState();
}

class _TimeInputFieldState extends State<TimeInputField> {
  List<TextEditingController> timectrllist = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController()
  ];

  var _workoutdataProvider;
  var _userdataProvider;
  var _themeProvider;

  @override
  void initState() {
    String stringed = widget.duration.toString();
    print(stringed);
    for (int i = 0; i < 6 - stringed.length; i++) {
      timectrllist[i].text = '0';
    }
    for (int i = 0; i < stringed.length; i++) {
      timectrllist[6 - i - 1].text = stringed[stringed.length - 1 - i];
    }
    super.initState();
  }

  void _editWorkoutwCheck() async {
    WorkoutEdit(
            id: _workoutdataProvider.workoutdata.id,
            user_email: _userdataProvider.userdata.email,
            routinedatas: _workoutdataProvider.workoutdata.routinedatas)
        .editWorkout()
        .then((data) =>
            data["user_email"] != null ? null : showToast("입력을 확인해주세요"));
  }

  @override
  Widget build(BuildContext context) {
    _workoutdataProvider =
        Provider.of<WorkoutdataProvider>(context, listen: false);
    _userdataProvider = Provider.of<UserdataProvider>(context, listen: false);
    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    void gather() {
      String complete =
          (timectrllist[0].text == "" ? '0' : timectrllist[0].text) +
              (timectrllist[1].text == "" ? '0' : timectrllist[1].text) +
              (timectrllist[2].text == "" ? '0' : timectrllist[2].text) +
              (timectrllist[3].text == "" ? '0' : timectrllist[3].text) +
              (timectrllist[4].text == "" ? '0' : timectrllist[4].text) +
              (timectrllist[5].text == "" ? '0' : timectrllist[5].text);
      print(int.parse(complete));
      _workoutdataProvider.repscheck(
          widget.rindex, widget.pindex, widget.index, int.parse(complete));
    }

    return Row(
      children: [
        Flexible(
          child: TextFormField(
            controller: timectrllist[0],
            keyboardType: TextInputType.numberWithOptions(decimal: false),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Theme.of(context).primaryColorLight,
                fontSize: 20 * _themeProvider.userFontSize / 0.8),
            decoration: InputDecoration(
                hintText: '0',
                hintStyle:
                    TextStyle(color: Theme.of(context).primaryColorLight)),
            inputFormatters: [
              new LengthLimitingTextInputFormatter(1),
            ],
            onChanged: (text) {
              gather();
              if (text.length > 0) {
                FocusScope.of(context).nextFocus();
              }
            },
          ),
        ),
        Flexible(
          child: TextFormField(
            controller: timectrllist[1],
            keyboardType: TextInputType.numberWithOptions(decimal: false),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Theme.of(context).primaryColorLight,
                fontSize: 20 * _themeProvider.userFontSize / 0.8),
            decoration: InputDecoration(
                hintText: '0',
                hintStyle:
                    TextStyle(color: Theme.of(context).primaryColorLight)),
            inputFormatters: [
              new LengthLimitingTextInputFormatter(1),
            ],
            onChanged: (text) {
              gather();
              if (text.length == 1) {
                FocusScope.of(context).nextFocus();
              }
            },
          ),
        ),
        Text(
          ':',
          style: TextStyle(
              color: Theme.of(context).primaryColorDark,
              fontSize: 20 * _themeProvider.userFontSize / 0.8),
        ),
        Flexible(
          child: TextFormField(
            controller: timectrllist[2],
            keyboardType: TextInputType.numberWithOptions(decimal: false),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Theme.of(context).primaryColorLight,
                fontSize: 20 * _themeProvider.userFontSize / 0.8),
            decoration: InputDecoration(
                hintText: '0',
                hintStyle:
                    TextStyle(color: Theme.of(context).primaryColorLight)),
            inputFormatters: [
              new LengthLimitingTextInputFormatter(1),
            ],
            onChanged: (text) {
              gather();
              if (text.length == 1) {
                FocusScope.of(context).nextFocus();
              }
            },
          ),
        ),
        Flexible(
          child: TextFormField(
            controller: timectrllist[3],
            keyboardType: TextInputType.numberWithOptions(decimal: false),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Theme.of(context).primaryColorLight,
                fontSize: 20 * _themeProvider.userFontSize / 0.8),
            decoration: InputDecoration(
                hintText: '0',
                hintStyle:
                    TextStyle(color: Theme.of(context).primaryColorLight)),
            inputFormatters: [
              new LengthLimitingTextInputFormatter(1),
            ],
            onChanged: (text) {
              gather();
              if (text.length == 1) {
                FocusScope.of(context).nextFocus();
              }
            },
          ),
        ),
        Text(
          ':',
          style: TextStyle(
              color: Theme.of(context).primaryColorDark,
              fontSize: 20 * _themeProvider.userFontSize / 0.8),
        ),
        Flexible(
          child: TextFormField(
            controller: timectrllist[4],
            keyboardType: TextInputType.numberWithOptions(decimal: false),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Theme.of(context).primaryColorLight,
                fontSize: 20 * _themeProvider.userFontSize / 0.8),
            decoration: InputDecoration(
                hintText: '0',
                hintStyle:
                    TextStyle(color: Theme.of(context).primaryColorLight)),
            inputFormatters: [
              new LengthLimitingTextInputFormatter(1),
            ],
            onChanged: (text) {
              gather();
              if (text.length == 1) {
                FocusScope.of(context).nextFocus();
              }
            },
          ),
        ),
        Flexible(
          child: TextFormField(
            controller: timectrllist[5],
            keyboardType: TextInputType.numberWithOptions(decimal: false),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Theme.of(context).primaryColorLight,
                fontSize: 20 * _themeProvider.userFontSize / 0.8),
            decoration: InputDecoration(
                hintText: '0',
                hintStyle:
                    TextStyle(color: Theme.of(context).primaryColorLight)),
            inputFormatters: [
              new LengthLimitingTextInputFormatter(1),
            ],
            onChanged: (text) {
              gather();
              if (text.length == 1) {
                FocusScope.of(context).nextFocus();
              }
            },
          ),
        ),
      ],
    );
  }
}

class TimeTextInputFormatter extends TextInputFormatter {
  var _exp;
  TimeTextInputFormatter() {
    _exp = RegExp(r'^[0-9:]+$');
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (_exp.hasMatch(newValue.text)) {
      TextSelection newSelection = newValue.selection;

      String value = newValue.text;
      String newText;

      String leftChunk = '';
      String rightChunk = '';

      if (value.length >= 8) {
        if (value.substring(0, 7) == '00:00:0') {
          leftChunk = '00:00:';
          rightChunk = value.substring(leftChunk.length + 1, value.length);
        } else if (value.substring(0, 6) == '00:00:') {
          leftChunk = '00:0';
          rightChunk = value.substring(6, 7) + ":" + value.substring(7);
        } else if (value.substring(0, 4) == '00:0') {
          leftChunk = '00:';
          rightChunk = value.substring(4, 5) +
              value.substring(6, 7) +
              ":" +
              value.substring(7);
        } else if (value.substring(0, 3) == '00:') {
          leftChunk = '0';
          rightChunk = value.substring(3, 4) +
              ":" +
              value.substring(4, 5) +
              value.substring(6, 7) +
              ":" +
              value.substring(7, 8) +
              value.substring(8);
        } else {
          leftChunk = '';
          rightChunk = value.substring(1, 2) +
              value.substring(3, 4) +
              ":" +
              value.substring(4, 5) +
              value.substring(6, 7) +
              ":" +
              value.substring(7);
        }
      } else if (value.length == 7) {
        if (value.substring(0, 7) == '00:00:0') {
          leftChunk = '';
          rightChunk = '';
        } else if (value.substring(0, 6) == '00:00:') {
          leftChunk = '00:00:0';
          rightChunk = value.substring(6, 7);
        } else if (value.substring(0, 1) == '0') {
          leftChunk = '00:';
          rightChunk = value.substring(1, 2) +
              value.substring(3, 4) +
              ":" +
              value.substring(4, 5) +
              value.substring(6, 7);
        } else {
          leftChunk = '';
          rightChunk = value.substring(1, 2) +
              value.substring(3, 4) +
              ":" +
              value.substring(4, 5) +
              value.substring(6, 7) +
              ":" +
              value.substring(7);
        }
      } else {
        leftChunk = '00:00:0';
        rightChunk = value;
      }

      if (oldValue.text.isNotEmpty && oldValue.text.substring(0, 1) != '0') {
        if (value.length > 7) {
          return oldValue;
        } else {
          leftChunk = '0';
          rightChunk = value.substring(0, 1) +
              ":" +
              value.substring(1, 2) +
              value.substring(3, 4) +
              ":" +
              value.substring(4, 5) +
              value.substring(6, 7);
        }
      }

      newText = leftChunk + rightChunk;

      newSelection = newValue.selection.copyWith(
        baseOffset: math.min(newText.length, newText.length),
        extentOffset: math.min(newText.length, newText.length),
      );

      return TextEditingValue(
        text: newText,
        selection: newSelection,
        composing: TextRange.empty,
      );
    }

    return oldValue;
  }

  @override
  void dispose() {
    print('dispose');
    super.dispose();
  }

  @override
  void deactivate() {
    print('deactivate');
    super.deactivate();
  }
}
