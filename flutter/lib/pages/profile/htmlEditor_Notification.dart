import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:sdb_trainer/providers/notification.dart';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:async';



class NotificationHtmlEditor extends StatefulWidget {
  NotificationHtmlEditor({Key? key}) : super(key: key);

  @override
  _NotificationHtmlEditorState createState() => _NotificationHtmlEditorState();
}

class _NotificationHtmlEditorState extends State<NotificationHtmlEditor> {
  var _userProvider;
  var _notificationprovider;
  final _scrollController = ScrollController();
  String result = '';
  HtmlEditorController htmlcontroller = HtmlEditorController();
  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    _notificationprovider = Provider.of<NotificationdataProvider>(context, listen: false);
    _onRefresh();
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

  Future<void> _onRefresh() {
    print("here?");
    setState(() {
      _notificationprovider.getdata();
    });
    return Future<void>.value();
  }

  Widget _HtmlEditorWidget(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        HtmlEditor(
          controller: htmlcontroller,
          htmlEditorOptions: HtmlEditorOptions(
            hint: 'Your text here...',
            shouldEnsureVisible: true,
            //initialText: "<p>text content initial, if any</p>",
          ),
          htmlToolbarOptions: HtmlToolbarOptions(
            toolbarPosition: ToolbarPosition.aboveEditor, //by default
            toolbarType: ToolbarType.nativeScrollable, //by default
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
              print(file.name); //filename
              print(file.size); //size in bytes
              print(file.extension); //file extension (eg jpeg or mp4)
              return true;
            },
          ),
          otherOptions: OtherOptions(height: 550),
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
                  if (txt.contains('src=\"data:')) {
                    txt =
                    '<text removed due to base-64 data, displaying the text could cause the app to crash>';
                  }
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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(result),
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
                  htmlcontroller.disable();
                },
                child: Text('Disable',
                    style: TextStyle(color: Colors.white)),
              ),
              SizedBox(
                width: 16,
              ),
              TextButton(
                style: TextButton.styleFrom(
                    backgroundColor:
                    Theme.of(context).colorScheme.secondary),
                onPressed: () async {
                  htmlcontroller.enable();
                },
                child: Text(
                  'Enable',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                    backgroundColor:
                    Theme.of(context).colorScheme.secondary),
                onPressed: () {
                  htmlcontroller.insertText('Google');
                },
                child: Text('Insert Text',
                    style: TextStyle(color: Colors.white)),
              ),
              SizedBox(
                width: 16,
              ),
              TextButton(
                style: TextButton.styleFrom(
                    backgroundColor:
                    Theme.of(context).colorScheme.secondary),
                onPressed: () {
                  htmlcontroller.insertHtml(
                      '''<p style="color: blue">Google in blue</p>''');
                },
                child: Text('Insert HTML',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                    backgroundColor:
                    Theme.of(context).colorScheme.secondary),
                onPressed: () async {
                  htmlcontroller.insertLink(
                      'Google linked', 'https://google.com', true);
                },
                child: Text(
                  'Insert Link',
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
                  htmlcontroller.insertNetworkImage(
                      'https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_92x30dp.png',
                      filename: 'Google network image');
                },
                child: Text(
                  'Insert network image',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: Colors.blueGrey),
                onPressed: () {
                  htmlcontroller.addNotification(
                      'Info notification', NotificationType.info);
                },
                child:
                Text('Info', style: TextStyle(color: Colors.white)),
              ),
              SizedBox(
                width: 16,
              ),
              TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: Colors.blueGrey),
                onPressed: () {
                  htmlcontroller.addNotification(
                      'Warning notification', NotificationType.warning);
                },
                child: Text('Warning',
                    style: TextStyle(color: Colors.white)),
              ),
              SizedBox(
                width: 16,
              ),
              TextButton(
                style: TextButton.styleFrom(
                    backgroundColor:
                    Theme.of(context).colorScheme.secondary),
                onPressed: () async {
                  htmlcontroller.addNotification(
                      'Success notification', NotificationType.success);
                },
                child: Text(
                  'Success',
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
                  htmlcontroller.addNotification(
                      'Danger notification', NotificationType.danger);
                },
                child: Text(
                  'Danger',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: Colors.blueGrey),
                onPressed: () {
                  htmlcontroller.addNotification('Plaintext notification',
                      NotificationType.plaintext);
                },
                child: Text('Plaintext',
                    style: TextStyle(color: Colors.white)),
              ),
              SizedBox(
                width: 16,
              ),
              TextButton(
                style: TextButton.styleFrom(
                    backgroundColor:
                    Theme.of(context).colorScheme.secondary),
                onPressed: () async {
                  htmlcontroller.removeNotification();
                },
                child: Text(
                  'Remove',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
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
