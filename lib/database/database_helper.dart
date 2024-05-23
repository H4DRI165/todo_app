import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/model/todo.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'todo_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          '''
        CREATE TABLE todos(
        id TEXT PRIMARY KEY,
        todoText TEXT,
        isDone INTEGER,
        createdAt TEXT,
        deadlineAt TEXT,
        finishedAt TEXT
        )
        ''',
        );
      },
    );
  }

  //  Function to insert ToDo object into the database
  Future<void> insertToDo(ToDo todo) async {
    final db = await database; //  get database
    await db.insert(
      'todos', //  name of the table
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm
          .replace, //  if same id exist, it will overwrite with the new ones
    );
  }

  //  Function to retrieves all todos from the database
  Future<List<ToDo>> getToDos() async {
    final db = await database; //  get database instance

    //  query the database and return a list
    final List<Map<String, dynamic>> maps = await db.query('todos');

    //  create a list of ToDo objects from  the list of maps
    return List.generate(maps.length, (i) {
      return ToDo(
        id: maps[i]['id'],
        todoText: maps[i]['todoText'],
        isDone: maps[i]['isDone'] == 1,
        createdAt: maps[i]['createdAt'],
        deadlineAt: maps[i]['deadlineAt'],
        finishedAt: maps[i]['finishedAt'],
      );
    });
  }

  Future<void> updateToDo(ToDo todo) async {
    final db = await database;
    await db.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<void> deleteToDo(String id) async {
    final db = await database;
    await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
