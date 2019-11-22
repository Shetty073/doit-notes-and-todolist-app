import 'package:doit/pages/deleted.dart';
import 'package:flutter/material.dart';
import 'package:doit/animate.dart';
import 'package:doit/pages/editor.dart';
import 'package:doit/database/note.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:doit/main.dart';
import 'package:doit/pages/editnote.dart';
import 'package:doit/pages/archived.dart';
import 'package:doit/pages/settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:url_launcher/url_launcher.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // search bar clear button color
  Color _clearbuttoncolor = Colors.green;

  IconData favIcon = Icons.favorite_border;
  bool sortbyfav = false;
  String favtooltip = "Show favorited notes";

  void _sortbyfav() {
    setState(() {
      sortbyfav = sortbyfav ? false : true;
      favIcon = sortbyfav ? Icons.favorite : Icons.favorite_border;
      favtooltip = (favtooltip == "Show favorited notes")
          ? "Show all notes"
          : "Show favorited notes";
    });
  }

  final TextEditingController _textController = new TextEditingController();

  final focusNode = FocusNode();

  // snackbar
  final archiveSnackBar = SnackBar(
    content: Text("Note archived"),
    duration: Duration(seconds: 3),
  );
  final snackBar = SnackBar(
    content: Text('Note deleted'),
    duration: Duration(seconds: 3),
  );
  final noFavSnackBar = SnackBar(
    content: Text("No favorite notes found"),
    duration: Duration(seconds: 3),
  );

  String qry = "";

  // Firebase notifications regarding app updates
  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  // launhc update url
  _launchUpdateURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: ListTile(
              title: Text(message['notification']['title']),
              subtitle: Text(message['notification']['body']),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('OPEN LINK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _launchUpdateURL(message['notification']['body']);
                },
              ),
            ],
          ),
        );
      },
      onResume: (Map<String, dynamic> message) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: ListTile(
              title: Text(message['notification']['title']),
              subtitle: Text(message['notification']['body']),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('OPEN LINK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _launchUpdateURL(message['notification']['body']);
                },
              ),
            ],
          ),
        );
      },
      onLaunch: (Map<String, dynamic> message) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: ListTile(
              title: Text(message['notification']['title']),
              subtitle: Text(message['notification']['body']),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('OPEN LINK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _launchUpdateURL(message['notification']['body']);
                },
              ),
            ],
          ),
        );
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.getToken().then((token) {
      print(token);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          focusNode: focusNode,
          controller: _textController,
          keyboardType: TextInputType.text,
          autocorrect: true,
          textCapitalization: TextCapitalization.sentences,
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 18,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: "Search your notes",
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: Colors.white60,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.clear,
                color: _clearbuttoncolor,
              ),
              onPressed: () {
                if (_clearbuttoncolor != themeColor) {
                  setState(() {
                    _clearbuttoncolor = themeColor;
                  });
                }
                FocusScope.of(context).requestFocus(new FocusNode());
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _textController.clear());
                qry = "";
              },
            ),
          ),
          onChanged: (text) async {
            setState(() {
              // on title edit change
              // first make the clear button visible
              if (_clearbuttoncolor != Colors.white) {
                _clearbuttoncolor = Colors.white;
              }
            });

            setState(() {
              // search function here
              if (text.isEmpty) {
                return;
              }
              qry = text;
            });

            setState(() {});
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              favIcon,
            ),
            tooltip: favtooltip,
            onPressed: _sortbyfav,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/images/logo-drawer.png'),
                    backgroundColor: Colors.white,
                    minRadius: 20,
                    maxRadius: 30,
                  ),
                  SizedBox(
                    width: 15.0,
                  ),
                  Text(
                    'Doit',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              decoration: BoxDecoration(
                color: themeColor,
              ),
            ),
            ListTile(
              leading: Icon(Icons.archive),
              title: Text('Archive'),
              onTap: () {
                // Show archived notes
                Navigator.push(context, FadeRoute(page: Archive()));
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Deleted'),
              onTap: () {
                // Show deleted notes
                Navigator.push(context, FadeRoute(page: Deleted()));
              },
            ),
            Divider(
              color: Colors.grey,
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                // Update the state of the app
                Navigator.push(context, FadeRoute(page: SettingsPage()));
              },
            ),
          ],
        ),
      ),
      body: Listener(
        onPointerDown: (details) {
          if (focusNode.hasFocus) {
            FocusScope.of(context).unfocus();
            setState(() {
              _textController.clear();
              qry = "";
              _clearbuttoncolor = themeColor;
            });
          }
        },
        onPointerMove: (details) {
          if (details.delta.dy > 10) {
            FocusScope.of(context).requestFocus(focusNode);
          }
        },
        child: FutureBuilder(
            future: DatabaseHelper.getNotes(qry),
            builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                final notes = snapshot.data;
                return notes == null
                    ? Container()
                    : ListView.builder(
                        itemCount: notes.length,
                        itemBuilder: (BuildContext context, int index) {
                          if (!sortbyfav) {
                            return Card(
                              child: Slidable(
                                actionPane: SlidableDrawerActionPane(),
                                actionExtentRatio: 0.25,
                                child: ListTile(
                                  onTap: () {
                                    // Edit this note
                                    Navigator.push(
                                      context,
                                      FadeRoute(
                                        page: EditNote(
                                          noteId: notes[index]["id"],
                                          oTitle: notes[index]["title"],
                                          oBody: notes[index]["body"],
                                          oList: notes[index]["list"],
                                          oFav: notes[index]["fav"],
                                          oLastEdit: notes[index]["last_edit"],
                                        ),
                                      ),
                                    );
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
                                    caption: 'Archive',
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
                                          "last_edit": notes[index]
                                              ["list_edit"],
                                        };
                                        DatabaseHelper.archiveNote(currNote);
                                        DatabaseHelper.deleteNote(
                                            notes[index]["id"]);

                                        // snackbar
                                        Scaffold.of(context)
                                            .showSnackBar(archiveSnackBar);
                                      });
                                    },
                                  ),
                                ],
                                secondaryActions: <Widget>[
                                  IconSlideAction(
                                    caption: 'Delete',
                                    color: Colors.red,
                                    icon: Icons.delete,
                                    onTap: () {
                                      setState(() {
                                        // delete
                                        Map<String, dynamic> currNote = {
                                          "id": notes[index]["id"],
                                          "title": notes[index]["title"],
                                          "body": notes[index]["body"],
                                          "list": notes[index]["list"],
                                          "fav": notes[index]["fav"],
                                          "last_edit": notes[index]
                                              ["list_edit"],
                                        };

                                        DatabaseHelper.addToDelete(currNote);
                                        DatabaseHelper.deleteNote(
                                            notes[index]["id"]);

                                        // snackbar
                                        Scaffold.of(context)
                                            .showSnackBar(snackBar);
                                      });
                                    },
                                  ),
                                ],
                              ),
                              elevation: 0.0,
                              shape: RoundedRectangleBorder(
                                side: new BorderSide(
                                    color: Colors.grey, width: 0.5),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                            );
                          } else {
                            if (notes[index]["fav"] == 1) {
                              return Card(
                                child: Slidable(
                                  actionPane: SlidableDrawerActionPane(),
                                  actionExtentRatio: 0.25,
                                  child: ListTile(
                                    onTap: () {
                                      // Edit this note
                                      Navigator.push(
                                        context,
                                        FadeRoute(
                                          page: EditNote(
                                            noteId: notes[index]["id"],
                                            oTitle: notes[index]["title"],
                                            oBody: notes[index]["body"],
                                            oList: notes[index]["list"],
                                            oFav: notes[index]["fav"],
                                            oLastEdit: notes[index]
                                                ["last_edit"],
                                          ),
                                        ),
                                      );
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
                                      caption: 'Archive',
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
                                            "last_edit": notes[index]
                                                ["list_edit"],
                                          };
                                          DatabaseHelper.archiveNote(currNote);
                                          DatabaseHelper.deleteNote(
                                              notes[index]["id"]);

                                          // snackbar
                                          Scaffold.of(context)
                                              .showSnackBar(archiveSnackBar);
                                        });
                                      },
                                    ),
                                  ],
                                  secondaryActions: <Widget>[
                                    IconSlideAction(
                                      caption: 'Delete',
                                      color: Colors.red,
                                      icon: Icons.delete,
                                      onTap: () {
                                        setState(() {
                                          // delete
                                          Map<String, dynamic> currNote = {
                                            "id": notes[index]["id"],
                                            "title": notes[index]["title"],
                                            "body": notes[index]["body"],
                                            "list": notes[index]["list"],
                                            "fav": notes[index]["fav"],
                                            "last_edit": notes[index]
                                                ["list_edit"],
                                          };

                                          DatabaseHelper.addToDelete(currNote);
                                          DatabaseHelper.deleteNote(
                                              notes[index]["id"]);

                                          // snackbar
                                          Scaffold.of(context)
                                              .showSnackBar(snackBar);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                elevation: 0.0,
                                shape: RoundedRectangleBorder(
                                  side: new BorderSide(
                                      color: Colors.grey, width: 0.5),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                              );
                            } else {
                              return Container();
                            }
                          }
                        });
              }
              return Center(child: CircularProgressIndicator());
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            FadeRoute(
              page: Editor(),
            ),
          );
        },
        tooltip: 'Add new note',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
