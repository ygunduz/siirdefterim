import 'package:flutter/material.dart';
import 'FavoritesList.dart';

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favoriler'),
      ),
      body: FavoritesList()
    );
  }
}