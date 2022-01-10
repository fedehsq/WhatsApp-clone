import 'dart:convert';

import 'package:whatsapp_clone/helper/message.dart';

import 'contact_model.dart';

/// Class representing db model of WhatsApp message.
/// This is a (List) field of [ContactModel] class.
class MessageModel {
  int? id;
  String? text;
  int? fromServer;
  String? timestamp;

  /// [contactPhone] owner of the message
  String? contactPhone;

  MessageModel(
      [this.id, this.text, this.fromServer, this.timestamp, this.contactPhone]);

  /// Returns a new [MessageModel] parsing parameters from [message].
  factory MessageModel.fromMessage(Message message) {
    MessageModel messageModel = MessageModel();
    messageModel.text = message.text;
    messageModel.fromServer = message.fromServer? 1 : 0;
    messageModel.timestamp = message.timestamp.toIso8601String();
    return messageModel;
  }

  /// Returns a map representation of this [MessageModel].
  Map<String, Object?> toMap() {
    Map<String, Object?> map = {
      'contact_phone': contactPhone,
      'text': text,
      'from_server': fromServer,
      'timestamp': timestamp
    };
    if (id != null) {
      map['id'] = id!;
    }
    return map;
  }

  @override
  String toString() {
    return jsonEncode({
      'contact_phone': contactPhone,
      'text': text,
      'from_server': fromServer,
      'timestamp': timestamp
    });
  }
}
