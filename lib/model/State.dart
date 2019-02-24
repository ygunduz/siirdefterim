import 'package:firebase_auth/firebase_auth.dart';
import 'SairModel.dart';
import 'SiirModel.dart';

class StateModel{
  bool isLoading;
  FirebaseUser user;
  SiirModel siir;
  SairModel sair;


  StateModel({
    this.isLoading = false,
    this.user,
  });
}
