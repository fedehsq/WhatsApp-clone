import 'dart:developer';

import 'package:sqflite/sqflite.dart';

import 'package:whatsapp_clone/models/message_model.dart';
import 'package:whatsapp_clone/helper/message.dart';

import 'db.dart';

class MessageDao {
  /// Inserts a [message] (row) in the database where each key in the Map is a column name
  /// and the value is the column value.
  /// The return value is the id of the inserted row.
  static Future<void> createMessage(Message message,
      {required String contactPhone}) async {
    Database db = await DatabaseHelper.instance.database;
    MessageModel messageModel = MessageModel.fromMessage(message);
    messageModel.contactPhone = contactPhone;
    log(messageModel.toString());
    await db.insert(
      'messages',
      messageModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// All the [Message] (rows) are returned as a list of maps, where each map is
  /// a key-value list of columns.
  static Future<List<Message>> getAllMessages() async {
    Database db = await DatabaseHelper.instance.database;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('messages');

    // Convert the List<Map<String, dynamic> into a List<Message>.
    return List.generate(maps.length, (i) => Message.fromJson(maps[i]));
  }

/*
  Future<Story> fetchStoryAndUser(int storyId) async {
    List<Map> results = await _db.query("story", columns: Story.columns, where: "id = ?", whereArgs: [storyId]);

    Story story = Story.fromMap(results[0]);
    story.user = await fetchUser(story.user_id);

    return story;
  }
  */

  /// All the [Message] (rows) are returned as a list of maps, where each map is
  /// a key-value list of columns.
  static Future<List<Message>> getMessages(String contactPhone) async {
    Database db = await DatabaseHelper.instance.database;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('messages',
        where: 'contact_phone = ?', whereArgs: [contactPhone]);
    // orderBy: "timestamp DESC");
    log('messages query done for $contactPhone');

    // Convert the List<Map<String, dynamic> into a List<Message>.
    return List.generate(maps.length, (i) => Message.fromModel(maps[i]));
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  static Future<int> deleteMessages(String contactPhone) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.delete('messages',
        where: 'contact_phone = ?', whereArgs: [contactPhone]);
  }
}
