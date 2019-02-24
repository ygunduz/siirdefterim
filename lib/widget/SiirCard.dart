import 'package:flutter/material.dart';
import '../model/SiirModel.dart';

typedef OnTileTap = void Function();

class SiirCard extends StatelessWidget {
  final SiirModel siir;
  final int index;
  final BuildContext _context;
  final OnTileTap onTileTap;


  SiirCard(this.siir,this.index, this._context , { @required this.onTileTap })
    : assert(onTileTap != null);

  Widget get siirCard {
    return SizedBox(
        height: 70,
        width: MediaQuery.of(_context).size.width - 60,
        child: InkWell(
            onTap: (){
              onTileTap();
            },
            child: Container(
                height: 70,
                child: Card(
                  color: Colors.white70,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 8.0,
                      bottom: 8.0,
                      left: 64.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Text(siir.title, style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ),
                ))));
  }

  Widget get siirImage {
    int mIndex = index + 1;
    return Container(
        width: 60.0,
        height: 60.0,
        decoration:
            BoxDecoration(shape: BoxShape.circle, color: Colors.blueGrey),
        child: Center(
            child: Text('$mIndex',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white))));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
      child: Container(
        height: 70.0,
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 25.0,
              child: siirCard,
            ),
            Positioned(top: 5.5, child: siirImage),
          ],
        ),
      ),
    );
  }
}
