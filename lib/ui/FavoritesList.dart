import 'package:flutter/material.dart';
import '../util/DBHelper.dart';
import '../model/SairModel.dart';
import '../model/SiirModel.dart';
import 'SairDetailPage.dart';
import 'SiirDetailPage.dart';
import 'AvatarImageButton.dart';

class FavoritesList extends StatelessWidget {
  final DatabaseHelper _db = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: FutureBuilder<List>(
            future: _db.getFavorites(),
            builder: (BuildContext ctx, AsyncSnapshot<List> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return Center(child: Text('Arayın...'));
                case ConnectionState.waiting:
                  return Center(
                      child: new SizedBox(
                    height: 50.0,
                    width: 50.0,
                    child: new CircularProgressIndicator(
                      value: null,
                      strokeWidth: 7.0,
                    ),
                  ));
                default:
                  if (snapshot.hasError) {
                    return Center(child: Text('Hata : ${snapshot.error}'));
                  } else {
                    List<Map<String, dynamic>> siirList = snapshot.data;

                    return _buildList(siirList);
                  }
              }
            }));
  }

  Widget _buildList(List<Map<String, dynamic>> siirList) {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        SiirModel siirModel = SiirModel.fromMap(siirList[index]);
        return ListTile(
            onTap: () {
              SairModel sm = SairModel.fromMap(siirList[index]);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SiirDetailPage(siirModel, sm , index ,siirList)),
                );

            },
            leading: AvatarImageButton(
              height: 40.0,
              width: 40.0,
              image: AssetImage('assets/images/${siirModel.sairSlug}.jpg'),
              onTap: () {
                _db.getSairBySlug(siirModel.sairSlug).then((result) {
                  if (result != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SairDetailPage(sair: result)),
                    );
                  }
                });
              },
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(siirModel.title, style: TextStyle(fontSize: 20)),
                Text('${siirModel.sairName}',
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic))
              ],
            ));
      },
      itemCount: siirList.length,
    );
  }
}
