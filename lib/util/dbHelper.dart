import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/model/todo.dart';

class DbHelper{
  static final DbHelper _dbHelper=DbHelper._internal();

  String tblTodo="todo";
  String colId='id';
  String colDescription='description';
  String colTitle='title';
  String colPriority='priority';
  String colDate='date';

  DbHelper._internal();

  static Database _db;
  Future<Database> get db async {
    //singleton
    if (_db != null) {
      return _db;}
    _db = await initializeDb();
    return _db;
  }

  factory DbHelper(){
    return _dbHelper;
  }

Future<Database> initializeDb() async {
    Directory dir=await getApplicationDocumentsDirectory();
    String path=dir.path + "todos.db";
    var dbTodos=await openDatabase(path,version: 1,onCreate: _createDb);
    return dbTodos;
 }

 void _createDb(Database db, int newVersion) async{
  await db.execute(
    "CREATE TABLE $tblTodo($colId INTEGER PRIMARY KEY, $colTitle TEXT, "+
        "$colDescription TEXT, $colPriority INTEGER, $colDate TEXT)");
 }

  //Insertion
  Future<int> insertTodo(Todo todo) async {
    Database db=await this.db;
    //when ever we save or insert things in our table it returns a number
    var result = await db.insert(tblTodo, todo.toMap());
    return result;
  }
  //Get allTodo
  Future<List> getTodo() async {
    Database db=await this.db;
    var result = await db.rawQuery("SELECT * FROM $tblTodo ORDER BY $colPriority ASC");//ASCENDING ODER
    return result.toList();
  }
  //get count of all the users
  Future<int> getCount() async {
    Database db=await this.db;
    var result=Sqflite.firstIntValue(await db.rawQuery(
        "SELECT COUNT(*) FROM $tblTodo")
    );//select every count of everything in our database
    return result;
  }
  //deleting a user
  Future<int> deleteTodo(int id) async {
    Database db=await this.db;
    return await db.delete(tblTodo,
        where: "$colId = ? ", whereArgs: [id]);
  }

  //update user
  Future<int> updateItem(Todo todo) async {
    Database db=await this.db;
    return await db.update(tblTodo, todo.toMap(),
        where: "$colId = ?", whereArgs: [todo.id]);
  }

  //close db
  Future close() async{
    Database db=await this.db;
    return db.close();
  }
}