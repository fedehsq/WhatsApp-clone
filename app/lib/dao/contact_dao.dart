import 'dart:developer';

import 'package:sqflite/sqflite.dart';
import 'package:whatsapp_clone/dao/message_dao.dart';

import 'package:whatsapp_clone/helper/Contact.dart';
import 'package:whatsapp_clone/helper/Message.dart';
import 'package:whatsapp_clone/models/contact_model.dart';

import 'db.dart';

class ContactDao {
  /// Inserts a [contact] (row) in the database where each key in the Map is a column name
  /// and the value is the column value.
  /// The return value is the id of the inserted row.
  static Future<void> createUser(Contact contact) async {
    Database db = await DatabaseHelper.instance.database;

    await db.insert(
      'contacts',
      ContactModel.fromContact(contact).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// All the [Contact] (rows) are returned as a list of maps, where each map is
  /// a key-value list of columns.
  static Future<List<Contact>> getContacts() async {
    Database db = await DatabaseHelper.instance.database;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> mapContacts = await db.query('contacts');
    log('contacts query done');
    final List<Contact> contacts = [];
    for (var contact in mapContacts) {
      List<Message> messages = await MessageDao.getMessages(contact['phone']);
      log('messages query done for ${contact.toString()}');

      contacts.add(Contact.fromModel(contact, messages));
      log('added');
    }

    return contacts;
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  static Future<int> delete(String phone) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.delete('contacts', where: 'phone = ?', whereArgs: [phone]);
  }
}
