import 'package:flutter/material.dart';
import '../model/SiirModel.dart';
import '../model/SairModel.dart';
import 'SiirDetailPage.dart';
import 'SiirCard.dart';
import '../util/DBHelper.dart';

class SiirList extends StatefulWidget {
  final SairModel sair;

  SiirList(this.sair);

  @override
  _SiirListState createState() => _SiirListState();
}

class _SiirListState extends State<SiirList> {
  List<Map<String, dynamic>> siirler = new List();
  DatabaseHelper _db = new DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return _buildList(context);
  }

  ListView _buildList(context) {
    return ListView.builder(
      itemCount: siirler.length,
      itemBuilder: (context, int) {
        SiirModel siir = SiirModel.fromMap(siirler[int]);
        return SiirCard(siir, int, context, onTileTap: () {
          _db.getAllSiirlerBySairID(widget.sair.id).then((result){
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SiirDetailPage(
                      SiirModel.fromMap(result[int]), widget.sair, int ,result)),
            );
          });
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    if (this.siirler.length < 1) {
      _db.getAllSiirlerBySairID(widget.sair.id).then((sl) {
        setState(() {
          this.siirler = sl;
        });
      });
    }
  }
}
