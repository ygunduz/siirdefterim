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
        title: Text('Kullanıcı Girişi ve Ayarlar'),
      ),
      body: Container(
          padding: EdgeInsets.only(left: 5), child: _buildBody(appState)),
    );
  }

  Widget _buildBody(StateModel appState) {

      return Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Günlük Şiir Bildirimi' , style: TextStyle(fontSize: 18)),
              Switch(
                value: appState.sendDaily, 
                onChanged: (val) => StateWidget.of(context).changeSendDailySettings()
              )
            ],
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Reklam Göster' , style: TextStyle(fontSize: 18)),
              Switch(
                value: appState.showAds,
                onChanged: (val) => _showAdsConfirmDialog(val,context)
              )
            ],
          ),
          SizedBox(height: 10),
          Divider(height: 2),
          _buildBottom(appState)
        ],
      );
  }

  void _showAdsConfirmDialog(bool val , BuildContext ctx) {
    if(!val){
      showDialog(
        context: ctx,
        builder: (BuildContext context) {
          return AlertDialog(
          title: new Text("Bizi desteklemek istemez misiniz?"),
          content: new Text("Uygulamamızda reklamlar rahatsızlık vermeyecek düzeydedir." + 
              " Yine de reklamları kapatmak istiyor musunuz? Reklamları kaldırdığınızda uygulamayı "
              + "yeniden başlatmanız gerekir."),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Hayır"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("Evet"),
              onPressed: () {
                StateWidget.of(ctx).changeAdsSettings();
                Navigator.of(context).pop();
              },
            ),
          ],
          );
        }
      );
    }else{
      StateWidget.of(ctx).changeAdsSettings();
    }
  }

  Widget _buildBottom(StateModel appState) {
    if(appState.isLoggedIn) {
      return  _buildProfileWidget(appState);
    }
    else {
      return _buildLoginButton();
    }
  }

  Widget _buildLoginButton() {
    Size size = MediaQuery.of(context).size;

    return Center(
        child: ButtonTheme(
            minWidth: size.width - 10,
            child: GoogleSignInButton(
                // Passing function callback as constructor argument:
                onPressed: () async =>
                    StateWidget.of(context).signInWithGoogle())));
  }

  Widget _buildProfileWidget(StateModel appState) {
    Size size = MediaQuery.of(context).size;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        ProfileWidget(appState.user.displayName, appState.user.email,
            appState.user.photoUrl),
        ButtonTheme(
            minWidth: size.width - 10,
            textTheme: ButtonTextTheme.primary,
            child: RaisedButton(
                onPressed: () async =>
                    StateWidget.of(context).signOutFromGoogle(),
                child: Text('Çıkış Yap')))
      ],
    );
  }
}
