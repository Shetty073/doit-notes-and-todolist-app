import 'package:flutter/material.dart';
import 'package:doit/pages/homepage.dart';

void main() => runApp(MyApp());

// Theme color
Color themeColor = Colors.green;

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doit',
      theme: ThemeData(
        primarySwatch: themeColor,
      ),
      home: MyHomePage(title: 'Doit'),
    );
  }
}
