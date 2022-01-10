import 'dart:developer';

import 'package:sqflite/sqflite.dart';
import 'package:whatsapp_clone/dao/message_dao.dart';

import 'package:whatsapp_clone/helper/contact.dart';
import 'package:whatsapp_clone/helper/message.dart';
import 'package:whatsapp_clone/models/contact_model.dart';

import 'db.dart';

class ContactDao {
  /// Inserts a [contact] (row) in the database.
  static Future<void> insertContact(Contact contact) async {
    Database db = await DatabaseHelper.instance.database;
    await db.insert(
      'contacts',
      ContactModel.fromContact(contact).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Updates a [contact] (row) in the database.
  static Future<void> updateContact(Contact contact) async {
    Database db = await DatabaseHelper.instance.database;
    await db.update('contacts', ContactModel.fromContact(contact).toMap(),
        where: 'phone = ?', whereArgs: [contact.phone]);
  }

  /// Returns all the [Contact] (rows)..
  static Future<List<Contact>> getContacts() async {
    Database db = await DatabaseHelper.instance.database;

    // Query the table for all the Contacts.
    final List<Map<String, dynamic>> mapContacts = await db.query('contacts');
    final List<Contact> contacts = [];
    for (var contact in mapContacts) {
      List<Message> messages = await MessageDao.getMessages(contact['phone']);
      contacts.add(Contact.fromModel(contact, messages));
    }
    return contacts;
  }

  /// Deletes [contact] (row).
  static Future<int> delete(Contact contact) async {
    Database db = await DatabaseHelper.instance.database;
    return await db
        .delete('contacts', where: 'phone = ?', whereArgs: [contact.phone]);
  }
}
