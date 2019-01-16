class SairModel {
  int _id;
  String _name;
  String _slug;
  int _siirCount;
  String _bio;

  SairModel(this._name, this._slug , this._siirCount, this._bio);

  SairModel.map(dynamic obj) {
    this._id = obj['id'];
    this._name = obj['name'];
    this._slug = obj['slug'];
    this._siirCount = obj['siir_count'];
    this._bio = obj ['bio'];
  }

  int get id => _id;
  String get name => _name;
  String get slug => _slug;
  int get siirCount => _siirCount;
  String get bio => _bio;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (_id != null) {
      map['id'] = _id;
    }
    map['name'] = _name;
    map['slug'] = _slug;
    map['siir_count'] = _siirCount;
    map['bio'] = _bio;
    return map;
  }

  SairModel.fromMap(Map<String, dynamic> map) {
    this._id = map['id'];
    this._name = map['name'];
    this._slug = map['slug'];
    this._siirCount = map['siir_count'];
    this._bio = map['bio'];
  }
}