import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/SairModel.dart';
import '../widget/SairBioWidget.dart';
import '../widget/SiirList.dart';

class SairDetailPage extends StatefulWidget {
  SairDetailPage({Key key, @required this.sair}) : super(key: key);

  final SairModel sair;

  @override
  _SairDetailPageState createState() => _SairDetailPageState();
}

class _SairDetailPageState extends State<SairDetailPage>
    with SingleTickerProviderStateMixin {
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();
  final double _appBarHeight = 250.0;
  SairModel _sair;
  String _imageName;
  List<Widget> _children = [];

  TabController _tabController;
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    this._sair = widget.sair;
    _imageName = 'assets/images/${_sair.slug}.jpg';
    _tabController = new TabController(length: 2, vsync: this);
    _children = [
      SiirList(_sair),
      SairBioWidget(bio: _sair.bio)
    ];
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.blueGrey,
          platform: Theme.of(context).platform,
          fontFamily: 'Nunito-Regular'
        ),
        child: Scaffold(
          key: _scaffoldKey,
          body: NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  expandedHeight: _appBarHeight,
                  floating: false,
                  pinned: true,
                  forceElevated: innerBoxIsScrolled,
                  flexibleSpace: FlexibleSpaceBar(
                      title: Text(_sair.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                          )
                      ),
                      background: Hero(
                        child: Image.asset(_imageName, fit: BoxFit.cover),
                        tag: _imageName,
                      )
                    )
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(TabBar(
                    indicatorColor: Colors.white,
                    tabs: [
                      Tab(
                        text: "Şiirleri",
                        //icon: Icon(Icons.border_color),
                      ),
                      Tab(
                        text: "Hayatı",
                        //icon: Icon(Icons.subject),
                      )
                    ],
                    controller: _tabController,
                  )),
                )
              ];
            },
            body: TabBarView(children: _children, controller: _tabController),
          ),
        ));
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      color: Colors.blueGrey,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
