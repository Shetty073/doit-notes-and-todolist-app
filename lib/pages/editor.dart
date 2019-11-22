import 'package:doit/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:doit/database/note.dart';
import 'package:share/share.dart';

class Editor extends StatefulWidget {
  Editor({Key key}) : super(key: key);

  @override
  _EditorState createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  // flags
  static bool newnote = true;

  // for checklist
  static bool listAdded = false;

  // note was last edited on
  static DateTime lastediteddate = DateTime.now();

  // For storing date of last edit
  static var formatter = DateFormat.yMMMMd("en_US");
  static var dateLastEdit = formatter.format(lastediteddate);

  // for displaying time
//  static var formatterHourMin = new DateFormat('jm');
//  static var dateTimeLastEdit = formatterHourMin.format(lastediteddate);

  // variables for TextField
  String title = "";
  String body = "";
  String list;
  int fav;
  String last_edit = dateLastEdit;

//  String listToString = "";

  // variables for _addtofav
  IconData favIcon = Icons.favorite_border;
  bool addtofav = false;
  String favTooltip = "Add to favorites";

  void _addtofav() {
    setState(() {
      addtofav = addtofav ? false : true;
      favIcon = addtofav ? Icons.favorite : Icons.favorite_border;
      favTooltip = "Remove from favorites";
    });
  }

  void _saveandgoback() async {
//    var listToString = json.encode(listFlt);

//    listAdded = false;
    title = _titletextcontroller.text;
    body = listAdded ? null : _bodytextcontroller.text;
    list = listAdded ? json.encode(listFlt) : null;
    fav = addtofav ? 1 : 0;
    last_edit = last_edit;

    Map<String, dynamic> insertNoteData = {
      "title": title,
      "body": body,
      "list": list,
      "fav": fav,
      "last_edit": last_edit
    };

    // check if note is empty. if yes then discard it
    if (!listAdded) {
      if ((title.isEmpty && body.isEmpty) || (title == " " && body == " ")) {
        Navigator.pop(context);
        listAdded = false;
        listFlt.clear();
      } else {
        DatabaseHelper.saveNote(insertNoteData);
        Navigator.pop(context);
        listAdded = false;
        listFlt.clear();
      }
    } else {
      if ((title.isEmpty && listFlt.length == 0) ||
          (title == " " && listFlt.length == 0)) {
        Navigator.pop(context);
        listAdded = false;
        listFlt.clear();
      } else {
        DatabaseHelper.saveNote(insertNoteData);
        Navigator.pop(context);
        listAdded = false;
        listFlt.clear();
      }
    }
  }

  // Controllers for both TextFields
  final _titletextcontroller = TextEditingController();
  final _bodytextcontroller = TextEditingController();

  // Focusnode for textfield(body)
  final focusNode = FocusNode();

  void addList() {
    setState(() {
      listAdded = listAdded ? false : true;
    });
  }

  String convListToString(List<String> ls) {
    String dbEntry = "";
    for (int i = 0; i < ls.length; i++) {
      dbEntry += (ls[i] + "\n");
    }
    return dbEntry;
  }

  // list
  static List<String> listFlt = [];

  // snackbar
  final snackBar = SnackBar(
    content: Text('Note discarded!'),
    duration: Duration(seconds: 3),
  );

  void _settingModalBottomSheet(context, widget) {
    showModalBottomSheet(
      useRootNavigator: false,
      context: context,
      builder: (BuildContext bc) {
        if (widget == 1) {
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: Icon(Icons.check_box),
                    title: listAdded ? Text('Add note') : Text('Add checklist'),
                    onTap: () => {addList(), Navigator.pop(context)}),
//                  ListTile(
//                    leading: Icon(Icons.image),
//                    title: Text('Add reminder'),
//                    onTap: () => {},
//                  ),
              ],
            ),
          );
        } else {
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.share),
                  title: Text('Share'),
                  onTap: () => {
                    // share this note
                    title = _titletextcontroller.text,
                    body = listAdded ? "" : _bodytextcontroller.text,
                    list = listAdded ? json.encode(listFlt) : "",
                    Share.share("$title\n$body\n$list"),
                  },
                ),
                ListTile(
                  leading: Icon(Icons.cancel),
                  title: Text('Discard'),
                  onTap: () => {
                    Navigator.pop(context),
                    Navigator.pop(context),
                    // snackbar
                    Scaffold.of(context).showSnackBar(snackBar),
                  },
                ),
              ],
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              SystemChannels.textInput.invokeMethod('TextInput.hide');
              _saveandgoback();
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                favIcon,
              ),
              tooltip: favTooltip,
              onPressed: _addtofav,
            ),
          ],
        ),
        body: Center(
          child: Container(
            padding: EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 5.0),
            child: listAdded
                ? Column(
                    children: <Widget>[
                      TextField(
                        controller: _titletextcontroller,
                        maxLength: 90,
                        maxLines: 1,
                        keyboardType: TextInputType.text,
                        autocorrect: true,
                        textCapitalization: TextCapitalization.sentences,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                        decoration: InputDecoration.collapsed(
                          hintText: "Title",
                        ),
                        buildCounter: (BuildContext context,
                                {int currentLength,
                                int maxLength,
                                bool isFocused}) =>
                            null,
                        textInputAction: TextInputAction.next,
//                onChanged: (text) {
//                  // on title edit change
//                },
                        onEditingComplete: () {
                          // on title edit complete
                          FocusScope.of(context).unfocus();
                          SystemChannels.textInput
                              .invokeMethod('TextInput.hide');
                          FocusScope.of(context).requestFocus(focusNode);
                        },
                      ),
                      TextField(
                        focusNode: focusNode,
                        controller: _bodytextcontroller,
                        maxLength: 90,
                        maxLines: 1,
                        keyboardType: TextInputType.text,
                        autocorrect: true,
                        textCapitalization: TextCapitalization.sentences,
                        autofocus: newnote,
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                            hintText: "Item " + (listFlt.length + 1).toString(),
                            border: InputBorder.none,
                            suffixIcon: IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    FocusScope.of(context).unfocus();
                                    SystemChannels.textInput
                                        .invokeMethod('TextInput.hide');
                                    listFlt.add(_bodytextcontroller.text);
                                    WidgetsBinding.instance
                                        .addPostFrameCallback(
                                            (_) => _bodytextcontroller.clear());
                                    FocusScope.of(context)
                                        .requestFocus(focusNode);
                                  });
                                })),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (value) {
                          FocusScope.of(context).unfocus();
                          SystemChannels.textInput
                              .invokeMethod('TextInput.hide');
                          listFlt.add(_bodytextcontroller.text);
                          WidgetsBinding.instance.addPostFrameCallback(
                              (_) => _bodytextcontroller.clear());
                          FocusScope.of(context).requestFocus(focusNode);
                        },
                        buildCounter: (BuildContext context,
                                {int currentLength,
                                int maxLength,
                                bool isFocused}) =>
                            null,
//                onChanged: (text) {
//                  // on note edit change
//                },
                        onEditingComplete: () {
                          // on note edit complete
                          FocusScope.of(context).unfocus();
                          SystemChannels.textInput
                              .invokeMethod('TextInput.hide');
                        },
                      ),
                      (listFlt.length > 0)
                          ? ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: listFlt.length,
                              itemBuilder: (context, index) {
                                final item = listFlt[index];
                                return Dismissible(
                                  key: Key(item),
                                  onDismissed: (direction) {
                                    setState(() {
                                      listFlt.removeAt(index);
                                    });
                                  },
                                  child: Card(
                                    child: ListTile(title: Text('$item')),
                                    elevation: 0.0,
                                    shape: RoundedRectangleBorder(
                                      side: new BorderSide(
                                          color: Colors.grey, width: 0.5),
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                  ),
                                );
                              },
                            )
                          : Container(),
                    ],
                  )
                : ListView(
                    children: <Widget>[
                      TextField(
                        controller: _titletextcontroller,
                        maxLength: 999,
                        keyboardType: TextInputType.text,
                        autocorrect: true,
                        textCapitalization: TextCapitalization.sentences,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                        decoration: InputDecoration.collapsed(
                          hintText: "Title",
                        ),
                        buildCounter: (BuildContext context,
                                {int currentLength,
                                int maxLength,
                                bool isFocused}) =>
                            null,
                        textInputAction: TextInputAction.next,
//                onChanged: (text) {
//                  // on title edit change
//                },
                        onEditingComplete: () {
                          // on title edit complete
                          FocusScope.of(context).unfocus();
                          SystemChannels.textInput
                              .invokeMethod('TextInput.hide');
                          FocusScope.of(context).requestFocus(focusNode);
                        },
                      ),
                      TextField(
                        focusNode: focusNode,
                        controller: _bodytextcontroller,
                        maxLength: 19999,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        autocorrect: true,
                        textCapitalization: TextCapitalization.sentences,
                        autofocus: newnote,
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          hintText: "Title",
                          border: InputBorder.none,
                        ),
                        buildCounter: (BuildContext context,
                                {int currentLength,
                                int maxLength,
                                bool isFocused}) =>
                            null,
//                onChanged: (text) {
//                  // on note edit change
//                },
                        onEditingComplete: () {
                          // on note edit complete
                          FocusScope.of(context).unfocus();
                          SystemChannels.textInput
                              .invokeMethod('TextInput.hide');
                        },
                      ),
                    ],
                  ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          elevation: 0.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                  icon: Icon(
                    Icons.border_inner,
                  ),
                  onPressed: () {
                    _settingModalBottomSheet(context, 1);
                  }),
              Text("Edited " + last_edit),
              IconButton(
                icon: Icon(
                  Icons.more_vert,
                ),
                onPressed: () {
                  _settingModalBottomSheet(context, 2);
                },
              ),
            ],
          ),
        ),
      ),
      onWillPop: () {
        _saveandgoback();
      },
    );
  }
}
