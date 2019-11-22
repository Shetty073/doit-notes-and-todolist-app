import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  void _saveandgoback() async {
    Navigator.pop(context);
  }

  _launchGitHubURL() async {
    const url = 'https://github.com/Shetty073/doit-notes-and-todolist-app';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchProfileURL() async {
    const url = 'https://github.com/Shetty073';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }


  // About dialog box
  void _showAboutDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            title: Text(
              "Doit:  notes and todolist app",
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
            content: Text(
              "Author: Ashish H. Shetty\n\nGitHub: https://github.com/Shetty073/doit-notes-and-todolist-app",
              style: TextStyle(
                fontSize: 15.0,
              ),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  _launchGitHubURL();
                  Navigator.pop(context);
                },
                child: Text(
                    "OPEN LINK",
                  style: TextStyle(
                    fontSize: 15.0,
                  ),
                ),
              ),
              FlatButton(
                onPressed: () {
                  _launchProfileURL();
                  Navigator.pop(context);
                },
                child: Text(
                  "AUTHORS PROFILE",
                  style: TextStyle(
                    fontSize: 15.0,
                  ),
                ),
              ),
            ],
//            backgroundColor: widget.bodyForegroundColor,
          );
        });
  }

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
      ),
      body: ListView(
        children: <Widget>[
          Container(
            padding:
                EdgeInsets.only(left: 2.0, top: 5.0, right: 2.0, bottom: 0.0),
            child: ListTile(
              onTap: () {
                _showAboutDialog();
              },
              leading: Icon(Icons.info),
              title: Text("About app"),
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
          Container(
            padding:
            EdgeInsets.only(left: 2.0, top: 5.0, right: 2.0, bottom: 0.0),
            alignment: Alignment.center,
            child: Text(
              "***more features coming soon***",
              style: TextStyle(
                fontSize: 10.0,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
