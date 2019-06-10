import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:siirdefterim/StateWidget.dart';
import 'package:siirdefterim/model/State.dart';
import '../model/SiirModel.dart';
import '../model/SairModel.dart';
import '../util/DBHelper.dart';
import '../model/ReadingTheme.dart';
import 'package:share/share.dart';
import '../widget/CustomButton.dart';

class SiirDetailPage extends StatefulWidget {
  final SiirModel siir;
  final SairModel sair;
  final List<Map<String, dynamic>> siirler;
  final int currentPage;

  SiirDetailPage(this.siir, this.sair, this.currentPage, this.siirler);

  _SiirDetailPageState createState() => _SiirDetailPageState();
}

class _SiirDetailPageState extends State<SiirDetailPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DatabaseHelper _db = DatabaseHelper();
  PageController _pageController;
  List<ReadingTheme> themes = [
    ReadingTheme(Colors.orange[100], Colors.grey[800]),
    ReadingTheme(Colors.lightBlue[50], Colors.black),
    ReadingTheme(Colors.black54, Colors.white),
    ReadingTheme(Colors.white, Colors.black),
  ];

  List<Map<String, dynamic>> _siirler = new List();
  SiirModel _siir;
  SairModel _sair;

  int _currentTheme = 0;
  int _fontSize = 16;
  int _currentPage = 0;

  BannerAd _bannerAd = BannerAd(
      size: AdSize.banner, 
      //adUnitId: BannerAd.testAdUnitId
      adUnitId: 'ca-app-pub-2668472791924496/5976151848'
    );

  @override
  void initState() {
    super.initState();
    _db.getSettings().then((settings) {
      setState(() {
        if (null != settings) {
          _currentTheme = settings.theme;
          _fontSize = settings.fontSize;
        }
      });
    });
    _currentPage = widget.currentPage;
    _siirler = widget.siirler;
    _siir = SiirModel.fromMap(_siirler[_currentPage]);
    _sair = SairModel.fromMap(_siirler[_currentPage]);
    _pageController = new PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    super.dispose();
    _bannerAd.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: themes[_currentTheme].backgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          key: _scaffoldKey,
          backgroundColor: themes[_currentTheme].backgroundColor,
          actions: <Widget>[
            IconButton(
              icon: _siir.isFavorite
                  ? Icon(Icons.star, color: themes[_currentTheme].textColor)
                  : Icon(Icons.star_border,
                      color: themes[_currentTheme].textColor),
              onPressed: () {
                _db.updateFavorite(_siir.id).then((result) {
                  if (result > 0) {
                    setState(() {
                      _siir.isFavorite = !_siir.isFavorite;
                      List<Map<String, dynamic>> lst = List();
                      for (int i = 0; i < _siirler.length; i++) {
                        if (_siirler[i]['id'] == _siir.id) {
                          lst.add(_siir.toMap());
                          continue;
                        }
                        lst.add(_siirler[i]);
                      }
                      _siirler = lst;
                    });
                  }
                });
              },
            ),
            IconButton(
                icon: Icon(Icons.share, color: themes[_currentTheme].textColor),
                onPressed: () async {
                  await Share.share(_siir.title +
                      '\n\n' +
                      _siir.content +
                      '\n\n' +
                      _sair.name);
                }),
            IconButton(
                onPressed: () {
                  showModalBottomSheet<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return _buildSettingsModal();
                      });
                },
                icon: Icon(Icons.more_vert,
                    color: themes[_currentTheme].textColor))
          ],
          title: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(_siir.title,
                  style: TextStyle(
                      fontSize: 20, color: themes[_currentTheme].textColor)),
              Text(_sair.name,
                  style: TextStyle(
                      fontSize: 14, color: themes[_currentTheme].textColor))
            ],
          ),
        ),
        body: PageView.builder(
            itemCount: _siirler.length,
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
                _siir = SiirModel.fromMap(_siirler[page]);
                _sair = SairModel.fromMap(_siirler[page]);
              });
            },
            controller: _pageController,
            itemBuilder: (context, position) {
              SiirModel siirModel = SiirModel.fromMap(_siirler[position]);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      child: Container(
                          padding: EdgeInsets.all(20),
                          child: Text(siirModel.content,
                              style: TextStyle(
                                  fontSize: _fontSize.toDouble(),
                                  color: themes[_currentTheme].textColor))),
                    ),
                  ),
                  _buildAds()
                ],
              );
            }));
  }

  Widget _buildAds() {
    StateModel appState = StateWidget.of(context).state;
    Size size = MediaQuery.of(context).size;
    if (appState.showAds) {
      _bannerAd
        ..load()
        ..show(
            anchorOffset: 0,
            // Banner Position
            anchorType: AnchorType.bottom);
      return SizedBox(
          height: 50,
          width: size.width,
          child: Container(
              height: 50,
              width: size.width,
              color: Colors.black12,
          ));
    }
    return SizedBox(height: 0);
  }

  void updateTheme(int newTheme) {
    _db.updateTheme(newTheme).then((result) {
      if (result > 0) {
        setState(() {
          _currentTheme = newTheme;
        });
      }
    });
  }

  void updateFontSize(int fontSize) {
    int temp = _fontSize + (fontSize);
    if (temp > 9 && temp < 25) {
      _db.updateFontSize(temp).then((result) {
        if (result > 0) {
          setState(() {
            _fontSize = temp;
          });
        }
      });
    }
  }

  Widget _buildSettingsModal() {
    bool adsEnabled = StateWidget.of(context).state.showAds;
    double height = adsEnabled ? 250.0 : 200.0;

    return Container(
        height: height,
        padding: EdgeInsets.only(top: 10),
        color: Colors.black12,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text('Temalar', style: TextStyle(fontSize: 20)),
            Divider(),
            _buildThemeMenu(),
            Divider(height: 20.0, indent: 2.0),
            Text('Yazı Boyutu', style: TextStyle(fontSize: 20)),
            Divider(),
            _buildFontSizeMenu()
          ],
        ));
  }

  Widget _buildFontSizeMenu() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          CustomButton(
              height: 40,
              width: 120,
              borderRadius: 8.0,
              color: Colors.white,
              text: 'Büyült',
              textSize: 20,
              textColor: Colors.black,
              onTap: () {
                updateFontSize(1);
              }),
          CustomButton(
              height: 40,
              width: 120,
              borderRadius: 8.0,
              color: Colors.white,
              text: 'Küçült',
              textSize: 20,
              textColor: Colors.black,
              onTap: () {
                updateFontSize(-1);
              })
        ]);
  }

  Widget _buildThemeMenu() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        CustomButton(
          height: 40,
          width: 80,
          borderRadius: 8.0,
          color: themes[0].backgroundColor,
          text: 'Turuncu',
          textColor: themes[0].textColor,
          textSize: 14,
          onTap: () {
            updateTheme(0);
          },
        ),
        CustomButton(
          height: 40,
          width: 80,
          borderRadius: 8.0,
          color: themes[1].backgroundColor,
          text: 'Mavi',
          textColor: themes[1].textColor,
          textSize: 14,
          onTap: () {
            updateTheme(1);
          },
        ),
        CustomButton(
          height: 40,
          width: 80,
          borderRadius: 8.0,
          color: themes[2].backgroundColor,
          text: 'Siyah',
          textColor: themes[2].textColor,
          textSize: 14,
          onTap: () {
            updateTheme(2);
          },
        ),
        CustomButton(
          height: 40,
          width: 80,
          borderRadius: 8.0,
          color: themes[3].backgroundColor,
          text: 'Beyaz',
          textColor: themes[3].textColor,
          textSize: 14,
          onTap: () {
            updateTheme(3);
          },
        )
      ],
    );
  }
}
