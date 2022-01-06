import 'dart:convert';

import 'Message.dart';

/// Class representing a registered user to WhatsApp.
class Contact {
  final String phone;
  final String username;
  final String urlImage;
  final List<Message> messages;
  int toRead;
  bool isOnline;

  Contact(this.phone, this.username, this.urlImage, this.isOnline,
      this.messages,
      [this.toRead = 0]);

  /// Returns a new Contact parsing parameters from [json].
  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(json['phone'], json['username'],
        json['photo'], json['isOnline'], []);
  }

  /// Returns a new Contact parsing parameters from [model] and [messages].
  factory Contact.fromModel(Map<String, dynamic> model, List<Message> messages) {
    return Contact(
      model['phone'],
      model['username'],
      model['profile_image'],
      false,
      messages,
      model['to_read'],
    );
  }

  @override
  String toString() {
    return jsonEncode({
      'phone': phone,
      'username': username,
      'profileImage': urlImage,
      'messages': messages.toString()
    });
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Contact &&
          runtimeType == other.runtimeType &&
          phone == other.phone;

  @override
  int get hashCode => phone.hashCode;
}
