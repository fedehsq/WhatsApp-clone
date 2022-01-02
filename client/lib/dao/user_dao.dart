import 'package:sqflite/sqflite.dart';

import 'package:whatsapp_clone/models/Contact.dart';

import 'db.dart';

class UserDao {
  /// Inserts a [contact] (row) in the database where each key in the Map is a column name
  /// and the value is the column value. 
  /// The return value is the id of the inserted row.
  Future<void> insert(Contact contact) async {
    Database db = await DatabaseHelper.instance.database;

    await db.insert(
      'contacts',
      contact.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// All the [Contact] (rows) are returned as a list of maps, where each map is
  /// a key-value list of columns.
  Future<List<Contact>> getContacts() async {
    Database db = await DatabaseHelper.instance.database;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('contacts');

    // Convert the List<Map<String, dynamic> into a List<Contact>.
    return List.generate(maps.length, (i) => Contact.fromJson(maps[i]));
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(String phone) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.delete('contacts', where: 'phone = ?', whereArgs: [phone]);
  }
}
