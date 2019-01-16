import 'package:flutter/material.dart';
import '../util/DBHelper.dart';
import '../model/SairModel.dart';
import 'SairDetailPage.dart';

typedef BannerTapCallback = void Function(Photo photo);

class Photo {
  Photo({
    this.id,
    this.assetName,
    this.title,
    this.caption,
    this.isFavorite = false,
  });

  final String assetName;
  final String title;
  final String caption;
  final int id;

  bool isFavorite;

  String get tag => assetName; // Assuming that all asset names are unique.

  bool get isValid =>
      assetName != null &&
      title != null &&
      caption != null &&
      id != null &&
      isFavorite != null;
}

class _GridTitleText extends StatelessWidget {
  const _GridTitleText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(text , style: TextStyle(fontFamily: 'Nunito-Regular')),
    );
  }
}

class GridPhotoItem extends StatelessWidget {
  GridPhotoItem({Key key, @required this.photo, @required this.onBannerTap})
      : assert(photo != null && photo.isValid),
        assert(onBannerTap != null),
        super(key: key);

  final Photo photo;
  final BannerTapCallback
      onBannerTap; // User taps on the photo's header or footer.

  @override
  Widget build(BuildContext context) {
    final Widget image = GestureDetector(
        onTap: () { onBannerTap(photo); },
        child: Hero(
            key: Key(photo.assetName),
            tag: photo.tag,
            child: Image.asset(
              photo.assetName,
              fit: BoxFit.cover,
            )));

    return GridTile(
      footer: GestureDetector(
        onTap: () {
          onBannerTap(photo);
        },
        child: GridTileBar(
          backgroundColor: Colors.black45,
          title: _GridTitleText(photo.title),
          subtitle: _GridTitleText(photo.caption),
        ),
      ),
      child: image,
    );
  }
}

class GridListWidget extends StatefulWidget {
  const GridListWidget({Key key}) : super(key: key);

  @override
  _GridListWidgetState createState() => _GridListWidgetState();
}

class _GridListWidgetState extends State<GridListWidget> {
  List<Photo> photos = new List();
  DatabaseHelper db = new DatabaseHelper();

  @override
  void initState() {
    super.initState();

    db.getAllSairler().then((sairler) {
      setState(() {
        sairler.forEach((sair) {
          SairModel sm = SairModel.fromMap(sair);
          final String slug = sm.slug;
          final int count = sm.siirCount;
          Photo photo = new Photo(
            assetName: 'assets/images/$slug.jpg',
            title: sm.name,
            caption: '$count Şiir',
            isFavorite: false,
            id: sm.id
          );
          photos.add(photo);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Column(
      children: <Widget>[
        Expanded(
          child: SafeArea(
            top: false,
            bottom: false,
            child: GridView.count(
              crossAxisCount: (orientation == Orientation.portrait) ? 2 : 3,
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
              padding: const EdgeInsets.all(4.0),
              childAspectRatio:
                  (orientation == Orientation.portrait) ? 1.0 : 1.3,
              children: photos.map<Widget>((Photo photo) {
                return GridPhotoItem(
                    photo: photo,
                    onBannerTap: (Photo photo) {
                      db.getSair(photo.id).then((sm){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SairDetailPage(sair : sm),
                          ),
                        );
                      });
                    });
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
