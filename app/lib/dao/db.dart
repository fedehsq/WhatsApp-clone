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
      onCreate: (db, version) async {
        // Run the CREATE TABLE statement on the database.
        await db.execute('''
          CREATE TABLE contacts (
            phone TEXT PRIMARY KEY NOT NULL,
            username TEXT NOT NULL,
            profile_image TEXT NOT NULL,
            to_read INTEGER NOT NULL
          )''');
        
        await db.execute('''
          CREATE TABLE messages (
            id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            contact_phone INTEGER NOT NULL,
            text TEXT NOT NULL,
            from_server INTEGER NOT NULL,
            timestamp TEXT NOT NULL,
            FOREIGN KEY(contact_phone) REFERENCES contacts(phone)
          )''');
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
  }
}
