import 'package:doit/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:doit/database/note.dart';
import 'package:share/share.dart';

class EditNote extends StatefulWidget {
  final int noteId;
  final String oTitle;
  final String oBody;
  final String oList;
  final int oFav;
  final String oLastEdit;

  EditNote(
      {Key key,
      this.noteId,
      this.oTitle,
      this.oBody,
      this.oList,
      this.oFav,
      this.oLastEdit})
      : super(key: key);

  @override
  _EditNoteState createState() => _EditNoteState();
}

class _EditNoteState extends State<EditNote> {
  @override
  EditNote get widget => super.widget;

  bool newnote = false;
  bool listAdded;
  var lastediteddate = DateTime.now(); // Not sure bout this one
  var formatter = new DateFormat.yMMMMd("en_US");
  var dateLastEdit;
  var formatterHourMin = new DateFormat('jm');
  var dateTimeLastEdit;

  // variables for TextField
  int noteid;
  String title;
  String body;
  String list;
  int fav;
  String last_edit;
  String last_edit_time;

  //List
  static List<dynamic> listFlt;

  // variables for _addtofav
  IconData favIcon;
  bool addtofav;
  String favTooltip;

  // Controllers for both TextFields
  final _titletextcontroller = TextEditingController();
  final _bodytextcontroller = TextEditingController();

  // initState is automatically called when this Widget is added to the widget tree
  // so we initialize all required flags and data inside it
  void initState() {
    listFlt = (widget.oList == null) ? [] : json.decode(widget.oList);
    addtofav = (widget.oFav == 1) ? true : false;
    favTooltip = addtofav ? "Remove from favorites" : "Add to favorites";
    favIcon = addtofav ? Icons.favorite : Icons.favorite_border;
    _titletextcontroller.text = widget.oTitle;
    _bodytextcontroller.text = widget.oBody;
    listAdded = (widget.oList != null);
    dateTimeLastEdit = widget.oLastEdit;
    super.initState();
  }

  // __addtofav
  void _addtofav() {
    setState(() {
      addtofav = addtofav ? false : true;
      favIcon = addtofav ? Icons.favorite : Icons.favorite_border;
      favTooltip = addtofav ? "Remove from favorites" : "Add to favorites";
    });
  }

  void _saveandgoback() async {
    noteid = widget.noteId;
    last_edit = formatter.format(lastediteddate);
    title = _titletextcontroller.text;
    body = listAdded ? null : _bodytextcontroller.text;
    list = listAdded ? json.encode(listFlt) : null;
    fav = addtofav ? 1 : 0;

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
        DatabaseHelper.updateNote(insertNoteData, widget.noteId);
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
        DatabaseHelper.updateNote(insertNoteData, widget.noteId);
        Navigator.pop(context);
        listAdded = false;
        listFlt.clear();
      }
    }
  }

  // Focusnode for textfield(body)
  final focusNode = FocusNode();

  // add list flag
  void addList() {
    setState(() {
      listAdded = listAdded ? false : true;
    });
  }

  // snackbar
  final snackBar = SnackBar(
    content: Text('Note deleted'),
    duration: Duration(seconds: 3),
  );

  // Bottom modal
  void _settingModalBottomSheet(context, widgetno) {
    showModalBottomSheet(
        useRootNavigator: false,
        context: context,
        builder: (BuildContext bc) {
          if (widgetno == 1) {
            return Container(
              child: Wrap(
                children: <Widget>[
                  ListTile(
                      leading: Icon(Icons.check_box),
                      title:
                          listAdded ? Text('Add note') : Text('Add checklist'),
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
                      Navigator.pop(context),
                      title = _titletextcontroller.text,
                      body = listAdded ? "" : _bodytextcontroller.text,
                      list = listAdded ? json.encode(listFlt) : "",
                      Share.share("$title\n$body\n$list"),
                    },
                  ),
                  Container(
                    color: Colors.red,
                    child: FlatButton(
                      padding: EdgeInsets.all(0.0),
                      child: ListTile(
                        leading: Icon(
                          Icons.delete_sweep,
                          color: Colors.white,
                        ),
                        title: Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          // delete
                          Map<String, dynamic> currNote = {
                            "id": widget.noteId,
                            "title": widget.oTitle,
                            "body": widget.oBody,
                            "list": widget.oList,
                            "fav": widget.oFav,
                            "last_edit": widget.oLastEdit,
                          };
                          DatabaseHelper.addToDelete(currNote);
                          DatabaseHelper.deleteNote(widget.noteId);
                          Navigator.pop(context);
                          Navigator.pop(context);

                          // snackbar
                          Scaffold.of(context).showSnackBar(snackBar);
                        });
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        });
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
              Text(((dateTimeLastEdit == null)
                  ? ""
                  : "Edited " + dateTimeLastEdit)),
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
