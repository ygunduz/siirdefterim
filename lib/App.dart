import 'package:flutter/material.dart';
import 'ui/HomePage.dart';

class App extends StatelessWidget {
  final String title;

  App(this.title);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        fontFamily: 'Nunito-Regular',
      ),
      home: HomePage(),
    );
  }
}