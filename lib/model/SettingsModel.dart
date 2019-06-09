class SettingsModel {
  int _theme;
  int _fontSize;
  int _showAds;
  int _sendDaily;

  SettingsModel(this._theme, this._fontSize , this._showAds , this._sendDaily);

  SettingsModel.map(dynamic obj) {
    this._theme = obj['theme'];
    this._fontSize = obj['font_size'];
    this._showAds = obj['show_ads'];
    this._sendDaily = obj['send_daily'];
  }

  int get theme => _theme;
  int get fontSize => _fontSize;
  int get sendDaily => _sendDaily;
  int get showAds => _showAds;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['theme'] = _theme;
    map['font_size'] = _fontSize;
    map['show_ads'] = _showAds;
    map['send_daily'] = _sendDaily;
    return map;
  }

  SettingsModel.fromMap(Map<String, dynamic> map) {
    this._theme = map['theme'];
    this._fontSize = map['font_size'];
    this._sendDaily = map['send_daily'];
    this._showAds = map['show_ads'];
  }
}