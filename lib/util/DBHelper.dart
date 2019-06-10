import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import '../model/SiirModel.dart';
import '../model/SairModel.dart';
import '../model/SettingsModel.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:synchronized/synchronized.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  final int _dbVersion = 2;

  final String tableSairler = 'sairler';
  final String columnId = 'id';
  final String columnName = 'name';
  final String columnSlug = 'slug';
  final String columnSiirCount = 'siir_count';
  final String columnBio = 'bio';
  final String tableSiirler = 'siirler';
  final String columnTitle = 'title';
  final String columnContent = 'content';
  final String columnIsFavorite = 'is_favorite';
  final String columnSairID = 'sair_id';
  final String tableSettings = 'settings';
  final String columnTheme = 'theme';
  final String columnFontSize = 'font_size';
  final String columnSendDaily = 'send_daily';
  final String columnShowAds = 'show_ads';

  static Database _db;
  static Lock lock = Lock();

  DatabaseHelper.internal();

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }

    await lock.synchronized(initDb);

    return _db;
  }

  Future<void> initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'database-v$_dbVersion.db');

    if (_db == null) {
      try {
        _db = await openDatabase(path, readOnly: true);
        if (_db != null) {
          await _db.close();
          _db = await openDatabase(path, readOnly: false);
        }
      } catch (e) {
        print("Error $e");
      }

      if (_db == null) {
        print("Creating new copy from asset");

        ByteData data = await rootBundle.load(join("assets", "database.db"));
        List<int> bytes =
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await new File(path).writeAsBytes(bytes);

        _db = await openDatabase(path, readOnly: false);
      } else {
        print("Opening existing database");
      }
    }
  }

  Future<SettingsModel> getSettings() async {
    var dbClient = await db;
    var result = await dbClient.query(tableSettings, columns: [
      columnTheme,
      columnFontSize,
      columnShowAds,
      columnSendDaily,
    ]);

    if (result.length > 0) {
      return new SettingsModel.fromMap(result.first);
    }

    return null;
  }

  Future<int> updateTheme(int theme) async {
    var dbClient = await db;
    return await dbClient
        .rawUpdate(' update $tableSettings set $columnTheme = ? ', [theme]);
  }

  Future<int> updateFontSize(int fontSize) async {
    var dbClient = await db;
    return await dbClient.rawUpdate(
        'update $tableSettings set $columnFontSize = ? ', [fontSize]);
  }

  Future<int> saveSair(SairModel sair) async {
    var dbClient = await db;
    var result = await dbClient.insert(tableSairler, sair.toMap());

    return result;
  }

  Future<List> getAllSairler() async {
    var dbClient = await db;
    var result = await dbClient.query(tableSairler,
        columns: [columnId, columnName, columnSlug, columnSiirCount],
        orderBy: '$columnName asc');

    return result.toList();
  }

  Future<SairModel> getSairBySlug(String slug) async {
    var dbClient = await db;
    List<Map> result = await dbClient.query(tableSairler,
        columns: [columnId, columnName, columnSlug, columnBio, columnSiirCount],
        where: '$columnSlug = ?',
        whereArgs: [slug]);

    if (result.length > 0) {
      return new SairModel.fromMap(result.first);
    }

    return null;
  }

  Future<List> search(String query) async {
    var dbClient = await db;
    String whereArg = '%$query%';
    var resultSiirler = await dbClient.rawQuery(
        'select siirler.id , $columnIsFavorite, $columnTitle , $columnSairID , $columnContent , $columnName , $columnSlug ' +
            ' from siirler ' +
            'left join sairler on sairler.id = siirler.sair_id ' +
            "where (title like upper('$whereArg')) or (title like lower('$whereArg')) ");

    var resultSairler = await dbClient.query(tableSairler,
        columns: [columnId, columnSlug, columnName, columnBio],
        where:
            "($columnName like upper('$whereArg')) or ($columnName like lower('$whereArg')) ");

    List result = [resultSairler.toList(), resultSiirler.toList()];
    return result;
  }

  Future<List> getFavorites() async {
    var dbClient = await db;
    var result = await dbClient.rawQuery(
        'select siirler.id , $columnIsFavorite, $columnTitle , $columnSairID , $columnContent , $columnName , $columnSlug ' +
            ' from siirler ' +
            'left join sairler on sairler.id = siirler.sair_id ' +
            'where is_favorite = ?',
        [1]);

    return result;
  }

  Future<List> getRandom(int random) async {
    var dbClient = await db;
    var sql = " select " +
        " siirler.id , is_favorite, title , sair_id , content , name , slug " +
        " from siirler left join sairler " +
        " on sairler.id = siirler.sair_id " +
        " order by random() limit ? ";

    var result = await dbClient.rawQuery(sql, [random]);

    return result;
  }

  Future<List> getAllSiirler() async {
    var dbClient = await db;
    var result = await dbClient.query(tableSiirler, columns: [
      columnId,
      columnTitle,
      columnContent,
      columnSairID,
      columnIsFavorite
    ]);

    return result.toList();
  }

  Future<List> getAllSiirlerBySairID(int sairID) async {
    var dbClient = await db;
    var result = await dbClient.rawQuery(
        'select siirler.id , $columnIsFavorite, $columnTitle , $columnSairID , $columnContent , $columnName , $columnSlug ' +
            ' from siirler ' +
            'left join sairler on sairler.id = siirler.sair_id ' +
            'where sair_id = ? order by $columnTitle',
        [sairID]);

    return result;
  }

  String getIDSString(List<int> ids) {
    String str = "";

    for (int i = 0; i < ids.length; i++) {
      str += ids[i].toString();
      if (ids.length - 1 != i) {
        str += " , ";
      }
    }

    print(str);

    return str;
  }

  Future<List> getAllSiirlerByIDs(List<int> ids) async {
    var dbClient = await db;
    var result = await dbClient.rawQuery(
        'select siirler.id , $columnIsFavorite, $columnTitle , $columnSairID , $columnContent , $columnName , $columnSlug ' +
            ' from siirler ' +
            'left join sairler on sairler.id = siirler.sair_id ' +
            'where siirler.id in ( ' +
            getIDSString(ids) +
            ' ) order by $columnTitle');

    return result;
  }

  Future<SiirModel> getSiir(int id) async {
    var dbClient = await db;
    var result = await dbClient.query(tableSiirler,
        columns: [
          columnId,
          columnTitle,
          columnContent,
          columnSairID,
          columnIsFavorite,
        ],
        where: '$columnId = ?',
        whereArgs: [id]);

    if (result.length > 0) {
      return new SiirModel.fromMap(result.first);
    }

    return null;
  }

  Future<int> getCountSair() async {
    var dbClient = await db;
    return Sqflite.firstIntValue(
        await dbClient.rawQuery('SELECT COUNT(*) FROM $tableSairler'));
  }

  Future<int> updateFavorite(int siirID) async {
    var dbClient = await db;
    return await dbClient.rawUpdate(
        'update $tableSiirler set $columnIsFavorite = ' +
            'case $columnIsFavorite when 1 then 0 else 1 end where $columnId = ?',
        [siirID]);
  }

  Future<SairModel> getSair(int id) async {
    var dbClient = await db;
    List<Map> result = await dbClient.query(tableSairler,
        columns: [columnId, columnName, columnSlug, columnBio],
        where: '$columnId = ?',
        whereArgs: [id]);

    if (result.length > 0) {
      return new SairModel.fromMap(result.first);
    }

    return null;
  }

  Future<int> deleteSair(int id) async {
    var dbClient = await db;
    return await dbClient
        .delete(tableSairler, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> updateSair(SairModel note) async {
    var dbClient = await db;
    return await dbClient.update(tableSairler, note.toMap(),
        where: "$columnId = ?", whereArgs: [note.id]);
  }

  Future close() async {
    var dbClient = await db;
    return dbClient.close();
  }

  Future<int> updateFavorites(List<String> lstFavorites) async {
    var dbClient = await db;
    String inString =
        lstFavorites.toString().replaceAll('[', '(').replaceAll(']', ')');

    return await dbClient.rawUpdate(
        'update $tableSiirler set $columnIsFavorite = ' +
            ' 1 where $columnId in $inString');
  }

  Future<int> getIsFirstLogin() async {
    var dbClient = await db;
    return Sqflite.firstIntValue(
        await dbClient.rawQuery('SELECT isFirstLogin FROM $tableSettings'));
  }

  Future<int> setIsFirstLogin(int value) async {
    var dbClient = await db;

    return await dbClient
        .rawUpdate('update $tableSettings set isFirstLogin = $value');
  }

  Future<int> setShowAds(int value) async {
    var dbClient = await db;

    return await dbClient
        .rawUpdate('update $tableSettings set $columnShowAds = $value');
  }

  Future<int> setSendDaily(int value) async {
    var dbClient = await db;

    return await dbClient
        .rawUpdate('update $tableSettings set $columnSendDaily = $value');
  }
}
