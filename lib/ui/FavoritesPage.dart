import 'package:flutter/material.dart';
import '../StateWidget.dart';
import '../widget/FavoritesList.dart';
import '../model/State.dart';

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favoriler'),
      ),
      body: FavoritesList(),
      bottomNavigationBar: _buildAdsContainer(context),
    );
  }

  Widget _buildAdsContainer(BuildContext context){
    StateModel appState = StateWidget.of(context).state;
    if(appState.showAds){
      return Container(
        height: 50,
        width: MediaQuery.of(context).size.width,
      );
    }
    else{
      return Container(width: 0,height: 0);
    }
  }
}