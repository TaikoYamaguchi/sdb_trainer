import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sdb_trainer/providers/notification.dart';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/themeMode.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:async';
import 'package:html/parser.dart';

import 'package:sdb_trainer/src/model/notification.dart' as notimodel;



class NotificationHtmlEditor extends StatefulWidget {
  NotificationHtmlEditor({Key? key}) : super(key: key);

  @override
  _NotificationHtmlEditorState createState() => _NotificationHtmlEditorState();
}

class _NotificationHtmlEditorState extends State<NotificationHtmlEditor> {
  var _userProvider;
  var _notificationprovider;
  var _themeProvider;
  List<XFile> imglist = [];

  final _scrollController = ScrollController();
  String result = '';
  HtmlEditorController htmlcontroller = HtmlEditorController();
  TextEditingController _notiNameCtrl = TextEditingController(text: "");

  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    _notificationprovider = Provider.of<NotificationdataProvider>(context, listen: false);
    return Consumer<PopProvider>(builder: (Builder, provider, child) {
      bool _popable = provider.isprostacking;
      _popable == false
          ? null
          : [
        provider.profilestackdown(),
        provider.propopoff(),
        Future.delayed(Duration.zero, () async {
          Navigator.of(context).pop();
        })
      ];
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: _appbarWidget(),
        body: _HtmlEditorWidget(),
      );
    });
  }

  PreferredSizeWidget _appbarWidget() {
    var _btnDisabled = false;
    return PreferredSize(
        preferredSize: const Size.fromHeight(40.0), // here the desired height
        child: AppBar(
          elevation: 0.0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_outlined),
            color: Theme.of(context).primaryColorLight,
            onPressed: () {
              _btnDisabled == true
                  ? null
                  : [
                Navigator.of(context).pop(),
                _btnDisabled = true,
              ];
            },
          ),
          title: Text(
            "공지사항",
            textScaleFactor: 1.5,
            style: TextStyle(color: Theme.of(context).primaryColorLight),
          ),
          backgroundColor: Theme.of(context).canvasColor,
        ));
  }

  Widget _titleWidget() {
    return MediaQuery(
      data: const MediaQueryData(textScaleFactor: 1.5),
      child: TextField(
        onChanged: (value) {

        },
        style: TextStyle(color: Theme.of(context).primaryColorLight, ),
        textAlign: TextAlign.start,
        controller: _notiNameCtrl,
        decoration: InputDecoration(
            filled: true,
            enabledBorder: UnderlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                  color: Colors.white, width: 1),
            ),
            focusedBorder: UnderlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                  color: Theme.of(context).primaryColor, width: 3),
            ),
            ),
      ),
    );
  }



  Widget _HtmlEditorWidget(){
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Title:",
                    textScaleFactor: 1.5,
                    style: TextStyle(
                        color: Theme.of(context).primaryColorLight,
                        fontWeight: FontWeight.bold)),
                Expanded(child: _titleWidget())
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Contents:",
                  textScaleFactor: 1.5,
                  style: TextStyle(
                      color: Theme.of(context).primaryColorLight,
                      fontWeight: FontWeight.bold)
              ),
            ),

            SizedBox(
              height: 5,
            ),

            HtmlEditor(
              controller: htmlcontroller,

              htmlEditorOptions: HtmlEditorOptions(
                hint: 'Your text here...',
                darkMode: _themeProvider.userThemeDark == "dark" ? true : false,
                shouldEnsureVisible: true,
                //initialText: "<p>text content initial, if any</p>",
              ),
              htmlToolbarOptions: HtmlToolbarOptions(
                toolbarPosition: ToolbarPosition.aboveEditor, //by default
                toolbarType: ToolbarType.nativeScrollable, //by default
                buttonColor: Theme.of(context).primaryColorLight,

                onButtonPressed:
                    (ButtonType type, bool? status, Function? updateStatus) {
//              print(
//                  "button '${describeEnum(type)}' pressed, the current selected status is $status");
                  return true;
                },
                onDropdownChanged: (DropdownType type, dynamic changed,
                    Function(dynamic)? updateSelectedItem) {
//              print(
//                  "dropdown '${describeEnum(type)}' changed to $changed");
                  return true;
                },
                mediaLinkInsertInterceptor:
                    (String url, InsertFileType type) {
                  print(url);
                  return true;
                },

                mediaUploadInterceptor:
                    (PlatformFile file, InsertFileType type) async {
                  imglist.add(XFile(file.path!)) ;

                  print(file.size); //size in bytes
                  print(file.extension); //file extension (eg jpeg or mp4)
                  return true;
                },
              ),

              otherOptions: OtherOptions(height: 400,decoration: BoxDecoration(border: Border.all(color: Theme.of(context).primaryColorDark))),
              callbacks: Callbacks(onBeforeCommand: (String? currentHtml) {
                print('html before change is $currentHtml');
              }, onChangeContent: (String? changed) {
                print('content changed to $changed');
              }, onChangeCodeview: (String? changed) {
                print('code changed to $changed');
              }, onChangeSelection: (EditorSettings settings) {
                print('parent element is ${settings.parentElement}');
                print('font name is ${settings.fontName}');
              }, onDialogShown: () {
                print('dialog shown');
              }, onEnter: () {
                print('enter/return pressed');
              }, onFocus: () {
                print('editor focused');
              }, onBlur: () {
                print('editor unfocused');
              }, onBlurCodeview: () {
                print('codeview either focused or unfocused');
              }, onInit: () {
                print('init');
              },
                  //this is commented because it overrides the default Summernote handlers
                  /*onImageLinkInsert: (String? url) {
                        print(url ?? "unknown url");
                      },
                      onImageUpload: (FileUpload file) async {
                        print(file.name);
                        print(file.size);
                        print(file.type);
                        print(file.base64);
                      },*/
                  onImageUploadError: (FileUpload? file, String? base64Str,
                      UploadError error) {
//                print(describeEnum(error));
                    print(base64Str ?? '');
                    if (file != null) {
                      print(file.name);
                      print(file.size);
                      print(file.type);
                    }
                  }, onKeyDown: (int? keyCode) {
                    print('$keyCode key downed');
//                print(
//                    'current character count: ${controller.characterCount}');
                  }, onKeyUp: (int? keyCode) {
                    print('$keyCode key released');
                  }, onMouseDown: () {
                    print('mouse downed');
                  }, onMouseUp: () {
                    print('mouse released');
                  }, onNavigationRequestMobile: (String url) {
                    print(url);
                    return NavigationActionPolicy.ALLOW;
                  }, onPaste: () {
                    print('pasted into editor');
                  }, onScroll: () {
                    print('editor scrolled');
                  }),
              plugins: [
                SummernoteAtMention(
                    getSuggestionsMobile: (String value) {
                      var mentions = <String>['test1', 'test2', 'test3'];
                      return mentions
                          .where((element) => element.contains(value))
                          .toList();
                    },
                    mentionsWeb: ['test1', 'test2', 'test3'],
                    onSelect: (String value) {
                      print(value);
                    }),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.blueGrey),
                    onPressed: () {
                      htmlcontroller.undo();
                    },
                    child:
                    Text('Undo', style: TextStyle(color: Colors.white)),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.blueGrey),
                    onPressed: () {
                      htmlcontroller.clear();
                    },
                    child:
                    Text('Reset', style: TextStyle(color: Colors.white)),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor:
                        Theme.of(context).colorScheme.secondary),
                    onPressed: () async {
                      var txt = await htmlcontroller.getText();
                      var afterparse = parse(txt);

                      if (txt.contains('src=\"data:')) {
                        for (int i=0; i < afterparse.getElementsByTagName("img").length; ++i){
                          afterparse.getElementsByTagName("img")[i].replaceWith(parseFragment("""<img src="${i}">"""));

                        }
                        //String sa =afterparse.getElementsByTagName("img")[0].children;
                        print(afterparse.getElementsByTagName("img")[0].attributes["src"]);
                      }



                      notimodel.Notification noti = notimodel.Notification(title: _notiNameCtrl.text, content: notimodel.Content(html: afterparse.outerHtml), images: [], ispopup: true);
                      _notificationprovider.postdata(noti, imglist);





                      /*

                       */
                      setState(() {
                        result = txt;
                      });
                    },
                    child: Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor:
                        Theme.of(context).colorScheme.secondary),
                    onPressed: () {
                      htmlcontroller.redo();
                    },
                    child: Text(
                      'Redo',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            /*
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(result),
            ),

             */
          ],
        ),
      ),
    );
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
