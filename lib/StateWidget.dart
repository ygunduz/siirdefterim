import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:siirdefterim/model/SettingsModel.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import './model/State.dart';
import './util/Auth.dart';
import './util/Store.dart';
import './util/DBHelper.dart';

class StateWidget extends StatefulWidget {
  final StateModel state;

  final Widget child;

  StateWidget({
    @required this.child,
    this.state,
  });

  // Returns data of the nearest widget _StateDataWidget

  // in the widget tree.

  static _StateWidgetState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_StateDataWidget)
            as _StateDataWidget)
        .data;
  }

  @override
  _StateWidgetState createState() => new _StateWidgetState();
}

class _StateWidgetState extends State<StateWidget> {
  StateModel state;

  GoogleSignInAccount googleAccount;

  final GoogleSignIn googleSignIn = new GoogleSignIn();

  @override
  void initState() {
    super.initState();

    if (widget.state != null) {
      state = widget.state;
    } else {
      state = new StateModel(isLoading: true , isLoggedIn: false);

      initUser();
      initSettings();
    }
  }

  Future<Null> initSettings() async {
    DatabaseHelper db = DatabaseHelper();
    SettingsModel settings = await db.getSettings();
    setState(() {
      state.sendDaily = settings.sendDaily == 1 ? true : false;
      state.showAds = settings.showAds == 1 ? true : false;
    });
    _subUnsubTopic();
  }

  Future<Null> changeAdsSettings() async {
    DatabaseHelper db = DatabaseHelper();
    int newAdSettings = state.showAds ? 0 : 1;
    int result = await db.setShowAds(newAdSettings);
    if(result > 0){
      setState(() {
        state.showAds = !state.showAds;
      });
    }
  }

  Future<Null> changeSendDailySettings() async {
    DatabaseHelper db = DatabaseHelper();
    int newSendDailySettings = state.sendDaily ? 0 : 1;
    int result = await db.setSendDaily(newSendDailySettings);
    if(result > 0){
      setState(() {
        state.sendDaily = !state.sendDaily;
      });
      _subUnsubTopic();
    }
  }

  Future<Null> initUser() async {
    googleAccount = await getSignedInAccount(googleSignIn);

    if (googleAccount == null) {
      setState(() {
        state.isLoading = false;
        state.isLoggedIn = false;
      });
    } else {
      await signInWithGoogle();
    }
  }

  Future<Null> signInWithGoogle() async {
    if (googleAccount == null) {
      // Start the sign-in process:

      googleAccount = await googleSignIn.signIn();
    }

    FirebaseUser firebaseUser = await signIntoFirebase(googleAccount);

    setState(() {
      state.isLoading = false;
      state.isLoggedIn = true;
      state.user = firebaseUser;
    });

    getFavoritesAndUpdateDatabase();
  }

  Future<Null> signOutFromGoogle() async {
    await FirebaseAuth.instance.signOut();
    googleAccount = await googleSignIn.signOut();
    DatabaseHelper _db = DatabaseHelper();
    await _db.setIsFirstLogin(1);

    setState(() {
      state.isLoggedIn = false;
      state.user = null;
      state.isLoading = false;
    });
  }

  void getFavoritesAndUpdateDatabase() async{
    DatabaseHelper _db = DatabaseHelper();
    int isFirstLogin = await _db.getIsFirstLogin();

    if(state.isLoggedIn && isFirstLogin == 1){
      List<String> lstFavorites = await getFavorites(state.user.uid);
      await _db.updateFavorites(lstFavorites);

      _db.getFavorites().then((favorites){
        List<String> fvList = favorites.map((item) => item['id'].toString()).toList();
        updateFavorites(state.user.uid, fvList);
      });

      await _db.setIsFirstLogin(0);
    }
    else if(state.isLoggedIn && isFirstLogin == 0){
      _db.getFavorites().then((favorites){
        List<String> fvList = favorites.map((item) => item['id'].toString()).toList();
        updateFavorites(state.user.uid, fvList);
      });
    }
  }

  void _subUnsubTopic(){
    FirebaseMessaging messaging = FirebaseMessaging();
    if(state.sendDaily){
      messaging.subscribeToTopic('daily');
      print('sub');
    }else{
      messaging.unsubscribeFromTopic('daily');
      print('unsub');
    }
  }

  @override
  Widget build(BuildContext context) {
    return new _StateDataWidget(
      data: this,
      child: widget.child,
    );
  }
}

class _StateDataWidget extends InheritedWidget {
  final _StateWidgetState data;

  _StateDataWidget({
    Key key,
    @required Widget child,
    @required this.data,
  }) : super(key: key, child: child);

  // Rebuild the widgets that inherit from this widget

  // on every rebuild of _StateDataWidget:

  @override
  bool updateShouldNotify(_StateDataWidget old) => true;
}
