import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import '../StateWidget.dart';
import '../widget/GridListWidget.dart';
import '../util/DBHelper.dart';
import '../model/SiirModel.dart';
import '../model/SairModel.dart';
import '../model/State.dart';
import 'SairDetailPage.dart';
import 'SiirDetailPage.dart';
import 'FavoritesPage.dart';
import '../widget/AvatarImageButton.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'LoginPage.dart';
import 'package:android_intent/android_intent.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _SearchViewDelegate _delegate = _SearchViewDelegate();
  DatabaseHelper _db = DatabaseHelper();

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  BannerAd _bannerAd = BannerAd(
      size: AdSize.banner,
      //adUnitId: BannerAd.testAdUnitId
      adUnitId: 'ca-app-pub-2668472791924496/5976151848'
  );

  @override
  void dispose(){
    super.dispose();
    _bannerAd.dispose();
  }

  @override
  void initState() {
    super.initState();
    firebaseCloudMessaging_Listeners();
  }

  void firebaseCloudMessaging_Listeners() {
    _firebaseMessaging.getToken().then((token){
      print('Token : $token');
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async{

      },
      onResume: (Map<String, dynamic> message) async{
        _messageAction(message);
      },
      onLaunch: (Map<String, dynamic> message) async{
        _messageAction(message);
      },
    );
  }

  void _messageAction(Map<String, dynamic> message) async{
    String type = message['data']['type'];
    if(type.compareTo('poem') == 0){
      String poemID = message['data']['poem_id'];

      SiirModel siir = await _db.getSiir(int.parse(poemID));
      SairModel sair = await _db.getSair(siir.sairID);
      siir.sairID = sair.id;
      siir.sairName = sair.name;
      siir.sairSlug = sair.slug;

      List<Map<String, dynamic>> lst = List();
      lst.add(siir.toMap());

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SiirDetailPage(siir, sair ,0 , lst )),
      );
    }
    if(type.compareTo('app') == 0){
      String appID = message['data']['app_id'];
      String url = 'market://details?id=$appID';
      AndroidIntent intent = AndroidIntent(
        action: 'action_view',
        data: url
      );
      await intent.launch();
    }
  }

  @override
  Widget build(BuildContext context) {
    StateModel appState =  StateWidget.of(context).state;
    if(appState.showAds){
      _bannerAd..load()..show();
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Şiir Defterim'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.more_vert) ,
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LoginPage()),
                );
              }
          )
        ],
      ),
      body: GridListWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.shuffle),
        onPressed: _loadRandromSiirler,
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 4.0,
        color: Colors.grey,
        child: Container(
          height: appState.showAds ? 90 : 50,
          width: MediaQuery.of(context).size.width,
          child: new Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () async {
                  await showSearch<String>(
                    context: context,
                    delegate: _delegate,
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.star_border),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FavoritesPage()),
                  );
                },
              )
            ],
          ),
        )
      ),
    );
  }

  void _loadRandromSiirler(){
    _db.getRandom(50).then((result) {
      SiirModel siirModel = SiirModel.fromMap(result[0]);
      SairModel sairModel = SairModel.fromMap(result[0]);

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SiirDetailPage(siirModel, sairModel ,0, result)),
      );
    });
  }
}

class _SearchViewDelegate extends SearchDelegate<String> {
  DatabaseHelper _db = DatabaseHelper();

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Geri',
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query == null || query.length < 3) {
      return Center(
        child: Text(
          '"$query"\n En Az Üç Karakter Giriniz',
          textAlign: TextAlign.center,
        ),
      );
    }

    return FutureBuilder<List>(
      future: _db.search(query),
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
              List<Map<String, dynamic>> siirList = snapshot.data[1];
              List<Map<String, dynamic>> sairList = snapshot.data[0];

              StateModel appState = StateWidget.of(context).state;
              if(!appState.showAds){
                return buildSairSearchResult(sairList, siirList);
              }else{
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: buildSairSearchResult(sairList, siirList)
                    ),
                    Container(height: 50,width: 50)
                  ],
                );
              }
            }
        }
      },
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
        tooltip: 'Temizle',
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      )
    ];
  }

  Widget buildSairSearchResult(List<Map<String, dynamic>> _sairResult,
      List<Map<String, dynamic>> _siirResult) {
    if (_sairResult != null && _siirResult != null) {
      return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            if (_sairResult.length < 1) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
                      child: Text('Şairler', style: TextStyle(fontSize: 20))),
                  Center(
                      child: Text('Sonuç Bulunamadı',
                          style: TextStyle(fontSize: 24)))
                ],
              );
            }
            // return the header
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
                    child: Text('Şairler', style: TextStyle(fontSize: 20)))
              ],
            );
          }
          index -= 1;

          if (_sairResult.length > index) {
            SairModel sairModel = SairModel.fromMap(_sairResult[index]);
            return ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SairDetailPage(sair: sairModel),
                    ),
                  );
                },
                leading: AvatarImageButton(
                  width: 40.0,
                  height: 40.0,
                  image: AssetImage('assets/images/${sairModel.slug}.jpg'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SairDetailPage(sair: sairModel),
                      ),
                    );
                  },
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(sairModel.name, style: TextStyle(fontSize: 18))
                  ],
                ));
          }

          if (index == _sairResult.length) {
            if (_siirResult.length < 1) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
                      child: Text('Şiirler', style: TextStyle(fontSize: 20))),
                  Center(
                      child: Text('Sonuç Bulunamadı',
                          style: TextStyle(fontSize: 24)))
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
                    child: Text('Şiirler', style: TextStyle(fontSize: 20)))
              ],
            );
          }

          index = index - (_sairResult.length + 1);
          if (_siirResult.length > index) {
            SiirModel siirModel = SiirModel.fromMap(_siirResult[index]);
            return ListTile(
                onTap: () {
                  SairModel sm = SairModel.fromMap(_siirResult[index]);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SiirDetailPage(siirModel, sm , index, _siirResult)),
                  );
                },
                leading: AvatarImageButton(
                  width: 40.0,
                  height: 40.0,
                  image: AssetImage('assets/images/${siirModel.sairSlug}.jpg'),
                  onTap: () {
                    _db.getSairBySlug(siirModel.sairSlug).then((result) {
                      if (result != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  SairDetailPage(sair: result)),
                        );
                      }
                    });
                  },
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(siirModel.title, style: TextStyle(fontSize: 18)),
                    Text('${siirModel.sairName}',
                        style: TextStyle(
                            fontSize: 14, fontStyle: FontStyle.italic))
                  ],
                ));
          }
        },
        itemCount: _sairResult.length + _siirResult.length + 2,
      );
    }
    //hiçbir zaman gelmeyecek
    return null;
  }
}
