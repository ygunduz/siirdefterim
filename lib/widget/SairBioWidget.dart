import 'package:flutter/material.dart';

class SairBioWidget extends StatelessWidget {
  final String bio;

  const SairBioWidget({Key key, @required this.bio}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
              child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(bio, style: TextStyle(fontSize: 16)))),
        )
      ],
    );
  }
}
