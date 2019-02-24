import 'package:firebase_auth/firebase_auth.dart';

class StateModel{
  bool isLoading;
  FirebaseUser user;
  bool isLoggedIn;


  StateModel({
    this.isLoading = false,
    this.user,
    this.isLoggedIn = false
  });
}
