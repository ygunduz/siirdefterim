class SiirModel {
  int _id;
  String _title;
  String _content;
  int _sairID;
  int _isFavorite;
  String _sairName;
  String _sairSlug;

  SiirModel(this._title, this._content , this._sairID, this._isFavorite ,this._sairName , this._sairSlug);

  SiirModel.map(dynamic obj) {
    this._id = obj['id'];
    this._title = obj['title'];
    this._content = obj['content'];
    this._sairID = obj['sair_id'];
    this._isFavorite = obj ['is_favorite'];
    this._sairName = obj['name'];
    this._sairSlug = obj['slug'];
  }

  int get id => _id;
  String get title => _title;
  String get content => _content;
  int get sairID => _sairID;
  bool get isFavorite => _isFavorite == 1 ? true : false;
  String get sairName => _sairName;
  String get sairSlug => _sairSlug;
  set isFavorite(bool isFavorite) => _isFavorite = isFavorite ? 1 : 0;
  set content(String content) => _content = content;
  set sairID(int val) => _sairID = val;
  set sairName(String val) => _sairName = val;
  set sairSlug(String val) => _sairSlug = val;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (_id != null) {
      map['id'] = _id;
    }
    map['title'] = _title;
    map['content'] = _content;
    map['sair_id'] = _sairID;
    map['is_favorite'] = _isFavorite;
    map['slug'] = _sairSlug;
    map['name'] = _sairName;
    return map;
  }

  SiirModel.fromMap(Map<String, dynamic> map) {
    this._id = map['id'];
    this._title = map['title'];
    this._content = map['content'];
    this._sairID = map['sair_id'];
    this._isFavorite = map['is_favorite'];
    this._sairName = map['name'];
    this._sairSlug = map['slug'];
  }

  static List<int> toIDList(List<Map<String, dynamic>> siirList){
    List<int> ids = new List();
    for (var i = 0; i < siirList.length; i++) {
      ids.add(SiirModel.fromMap(siirList[i]).id);
    }

    return ids;
  }
}