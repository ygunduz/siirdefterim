import 'package:firebase_auth/firebase_auth.dart';

class StateModel{
  bool isLoading;
  FirebaseUser user;
  bool isLoggedIn;
  bool showAds;
  bool sendDaily;

  StateModel({
    this.isLoading = false,
    this.user,
    this.isLoggedIn = false,
    this.showAds = true,
    this.sendDaily = true
  });
}
