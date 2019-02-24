import 'package:flutter/material.dart';
import '../StateWidget.dart';
import '../widget/GoogleSignInButton.dart';
import '../widget/ProfileWidget.dart';
import '../model/State.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    StateModel appState = StateWidget.of(context).state;
    return Scaffold(
      appBar: AppBar(
        title: Text('Kullanıcı Girişi'),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 5),
        child: _buildBody(appState)
      ),
    );
  }

  Widget _buildBody(StateModel appState){
    Size size = MediaQuery.of(context).size;

    if(!appState.isLoggedIn){
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ButtonTheme(
            minWidth: size.width - 10,
            child: GoogleSignInButton(
              // Passing function callback as constructor argument:
              onPressed: () => StateWidget.of(context).signInWithGoogle()
            )
          )
        ],
      );
    }
    else{
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ProfileWidget(appState.user.displayName , appState.user.email , appState.user.photoUrl),
          ButtonTheme(
            minWidth: size.width - 10,
            textTheme: ButtonTextTheme.primary,
            child: RaisedButton(
                onPressed: (){
                  print('logout');
                } ,
                child: Text('Çıkış Yap')
            )
          )
        ],
      );
    }
  }
}
