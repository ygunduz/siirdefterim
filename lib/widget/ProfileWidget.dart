import 'package:flutter/material.dart';

class ProfileWidget extends StatelessWidget {
  final String username;
  final String userEmail;
  final String photoUrl;

  ProfileWidget(this.username, this.userEmail, this.photoUrl);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      width: size.width - 10,
      height: 80,
      color: Colors.black12,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
              width: 60,
              height: 60,
              child: SizedBox(
                width: 60,
                height: 60,
              ),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(this.photoUrl)
                  )
              )
          ),
          SizedBox(
            height: 60,
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(this.username , style: Theme.of(context).textTheme.title),
                Text(this.userEmail , style: Theme.of(context).textTheme.subtitle)
              ],
            )
          )
        ],
      ),
    );
  }
}
