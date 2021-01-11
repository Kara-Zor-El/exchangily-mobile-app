/*
* Copyright (c) 2020 Exchangily LLC
*
* Licensed under Apache License v2.0
* You may obtain a copy of the License at
*
*      https://www.apache.org/licenses/LICENSE-2.0
*
*----------------------------------------------------------------------
* Author: barry-ruprai@exchangily.com
*----------------------------------------------------------------------
*/

import 'dart:async';
import 'package:exchangilymobileapp/logger.dart';
import 'package:exchangilymobileapp/models/wallet/token.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class TokenListDatabaseService {
  final log = getLogger('TokenListDatabaseService');

  static final _databaseName = 'token_list_database.db';
  final String tableName = 'token_list';
  // database table and column names
  final String columnId = 'id';
  final String columnDecimal = 'decimal';
  final String columnCoinName = 'coinName';
  final String columnChainName = 'chainName';
  final String columnTickerName = 'tickerName';
  final String columnTokenType = 'type';
  final String columnContract = 'contract';
  final String columnMinWithdraw = 'minWithdraw';
  final String columnFeeWithdraw = 'feeWithdraw';

  static final _databaseVersion = 3;
  static Future<Database> _database;
  String path = '';

  Future<Database> initDb() async {
    //deleteDb();
    if (_database != null) return _database;
    var databasePath = await getDatabasesPath();
    path = join(databasePath, _databaseName);
    log.w('init db $path');
    _database =
        openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
    return _database;
  }

  void _onCreate(Database db, int version) async {
    log.e('in on create $db');
    await db.execute(''' CREATE TABLE $tableName
        (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnDecimal INTEGER,
        $columnCoinName TEXT,
        $columnChainName TEXT,
        $columnTickerName TEXT,
        $columnTokenType TEXT,
        $columnContract TEXT,
        $columnMinWithdraw INTEGER,
        $columnFeeWithdraw INTEGER) ''');
  }

  // Get All Records From The Database

  Future<List<Token>> getAll() async {
    await initDb();
    final Database db = await _database;
    log.w('getall $db');

    // res is giving me the same output in the log whether i map it or just take var res
    final List<Map<String, dynamic>> res = await db.query(tableName);
    log.w('res $res');
    List<Token> list =
        res.isNotEmpty ? res.map((f) => Token.fromJson(f)).toList() : [];
    return list;
  }

// Insert Data In The Database
  Future insert(Token token) async {
    await initDb();
    final Database db = await _database;
    int id = await db.insert(tableName, token.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  // Get Single transaction By Name
  Future<List<Token>> getByName(String name) async {
    await initDb();
    final Database db = await _database;
    List<Map> res =
        await db.query(tableName, where: 'tickerName= ?', whereArgs: [name]);
    log.w('Name - $name --- $res');

    List<Token> list =
        res.isNotEmpty ? res.map((f) => Token.fromJson(f)).toList() : [];
    return list;
    // return TransactionHistory.fromJson((res.first));
  }

  // Get Single transaction By Id
  Future getById(int id) async {
    final Database db = await _database;
    List<Map> res = await db.query(tableName, where: 'id= ?', whereArgs: [id]);
    log.w('ID - $id --- $res');
    if (res.length > 0) {
      return Token.fromJson((res.first));
    }
    return null;
  }

  // Update database
  Future<void> update(Token token) async {
    final Database db = await _database;
    await db.update(
      tableName,
      token.toJson(),
      where: "id = ?",
      whereArgs: [token.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Close Database
  Future closeDb() async {
    var db = await _database;
    return db.close();
  }

  // Delete Database
  Future deleteDb() async {
    log.w(path);
    await deleteDatabase(path);
    log.e('$_databaseName deleted');
    _database = null;
  }
}
