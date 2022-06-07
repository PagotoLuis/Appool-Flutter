
import 'package:appool/Model/pH.dart';
import 'dart:io';
import "package:sqflite/sqflite.dart";
import 'package:path_provider/path_provider.dart'; 



class PhHelpers{
  
  static PhHelpers _databasehelper;
  static Database _database;

  PhHelpers._createInstance();
  
  factory PhHelpers(){
    if(_databasehelper == null){
      _databasehelper = PhHelpers._createInstance();
    }
    return _databasehelper;
  }


  Future<Database> get database async {
    if(_database == null){
      _database = await inicializaBanco();

    }
    return _database;
  }

  Future<Database> inicializaBanco() async {
    Directory pasta = await getApplicationDocumentsDirectory();
    String caminho = pasta.path + 'bdph.bd';

    var bancodedados = await openDatabase(
      caminho, version: 1, onCreate: _criaBanco);
    return bancodedados;
  }

  String nomeTabela = 'tbl_ph';
  String colId = 'id';
  String colValor = 'valor';
  String colData = 'data';

  void _criaBanco(Database db, int versao) async {
    await db.execute('CREATE TABLE $nomeTabela ('
      '$colId INTEGER PRIMARY KEY AUTOINCREMENT,'
      '$colValor Text, '
      '$colData Text)'
    );
  }

  listarPh() async{
    Database db = await this.database;
    String sql = "Select * FROM $nomeTabela";
    List  listaPh = await db.rawQuery(sql);

    return listaPh;
    
  }

  Future<int> excluirtodosPh() async {
    Database db = await this.database;
    var resultado = await db.delete(nomeTabela);
    return resultado;
  }

  Future<int> excluirumPh(int id) async {
    Database db = await this.database;
    var resultado = await db.delete(nomeTabela, where: " id=? ", whereArgs: [id]);
    return resultado;
  }

  Future<int> excluirumPhdata(String data) async {
    Database db = await this.database;
    var resultado = await db.delete(nomeTabela, where: "data=? ", whereArgs: [data]);
    return resultado;
  }

  Future<int> inserirPh(Ph obj) async {
    Database db = await this.database;
    var resultado = await db.insert(nomeTabela, obj.topMap());
    return resultado;

  }

}