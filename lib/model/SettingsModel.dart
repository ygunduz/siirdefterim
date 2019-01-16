class SettingsModel {
  int _theme;
  int _fontSize;

  SettingsModel(this._theme, this._fontSize);

  SettingsModel.map(dynamic obj) {
    this._theme = obj['theme'];
    this._fontSize = obj['font_size'];
  }

  int get theme => _theme;
  int get fontSize => _fontSize;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['theme'] = _theme;
    map['font_size'] = _fontSize;
    return map;
  }

  SettingsModel.fromMap(Map<String, dynamic> map) {
    this._theme = map['theme'];
    this._fontSize = map['font_size'];
  }
}