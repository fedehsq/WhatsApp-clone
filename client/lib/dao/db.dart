import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Makes this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only have a single app-wide reference to the database
  static late Database _database;
  Future<Database> get database async {
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    return openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'database.db'),
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute('''
          CREATE TABLE contacts (
            cid ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            phone TEXT NOT NULL,
            username TEXT NOT NULL,
            profileImage TEXT NOT NULL,
            toRead INTEGER NOT NULL,
            isOnline INTEGER NOT NULL
          )
          CREATE TABLE messages (
            mid ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            text TEXT NOT NULL,
            fromServer INTEGER NOT NULL,
            timestamp TEXT NOT NULL
          )
          ''');
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
  }
}
