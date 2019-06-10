import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'ui/HomePage.dart';

class App extends StatelessWidget {
  final String title;

  App(this.title);

  @override
  Widget build(BuildContext context) {
    FirebaseAdMob.instance.initialize(
        appId: 'ca-app-pub-2668472791924496~8940446282'
    );

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