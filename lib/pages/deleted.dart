import 'package:doit/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:doit/database/note.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Deleted extends StatefulWidget {
  Deleted({Key key}) : super(key: key);

  @override
  _DeletedState createState() => _DeletedState();
}

class _DeletedState extends State<Deleted> {
  void _saveandgoback() async {
    Navigator.pop(context);
  }

  // snackbar
  final restoreSnackBar = SnackBar(
    content: Text("Note restroed"),
    duration: Duration(seconds: 3),
  );
  final snackBar = SnackBar(
    content: Text('Note deleted permanently'),
    duration: Duration(seconds: 3),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
              Icons.delete_forever,
            ),
            tooltip: "Empty bin",
            onPressed: () {
              setState(() {
                DatabaseHelper.permaDeleteAllNotes();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder(
          future: DatabaseHelper.getDeletedNotes(),
          builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              final notes = snapshot.data;
              return notes == null
                  ? Container()
                  : ListView.builder(
                      itemCount: notes.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          child: Slidable(
                            actionPane: SlidableDrawerActionPane(),
                            actionExtentRatio: 0.25,
                            child: ListTile(
                              onTap: () {
                                // what happens on tapping card
                              },
                              // Change Icon() to Image() after database is implemented
                              leading: (notes[index]["list"] == null)
                                  ? Icon(Icons.note)
                                  : Icon(Icons.check_box),
                              title: Text(
                                (notes[index]["title"] == null)
                                    ? ""
                                    : notes[index]["title"],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.5,
                                ),
                              ),
                              subtitle: Text(
                                (notes[index]["body"] == null)
                                    ? ""
                                    : notes[index]["body"],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            actions: <Widget>[
                              IconSlideAction(
                                caption: 'Restore',
                                color: themeColor,
                                icon: Icons.archive,
                                onTap: () {
                                  setState(() {
                                    // archive
                                    Map<String, dynamic> currNote = {
                                      "id": notes[index]["id"],
                                      "title": notes[index]["title"],
                                      "body": notes[index]["body"],
                                      "list": notes[index]["list"],
                                      "fav": notes[index]["fav"],
                                      "last_edit": notes[index]["list_edit"]
                                    };
                                    DatabaseHelper.saveNote(currNote);
                                    DatabaseHelper.restoreNote(
                                        notes[index]["id"]);

                                    // snackbar
                                    Scaffold.of(context)
                                        .showSnackBar(restoreSnackBar);
                                  });
                                },
                              ),
                            ],
                            secondaryActions: <Widget>[
                              IconSlideAction(
                                caption: 'Forever',
                                color: Colors.red,
                                icon: Icons.delete_forever,
                                onTap: () {
                                  setState(() {
                                    DatabaseHelper.deleteNoteFromDeleted(
                                        notes[index]["id"]);

                                    // snackbar
                                    Scaffold.of(context).showSnackBar(snackBar);
                                  });
                                },
                              ),
                            ],
                          ),
                          elevation: 0.0,
                          shape: RoundedRectangleBorder(
                            side:
                                new BorderSide(color: Colors.grey, width: 0.5),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        );
                      });
            }
            return Center(child: CircularProgressIndicator());
          }),
    );
  }
}
