import 'dart:convert';

import 'package:flutter/cupertino.dart';

import 'message.dart';

/// Class representing a registered user to WhatsApp.
class Contact {
  final String phone;
  final String username;
  final Image profileImage;
  final List<Message> messages;
  int toRead;
  bool isOnline;

  Contact(this.phone, this.username, this.profileImage, this.isOnline,
      [this.toRead = 0])
      : messages = [];

  /// Returns a new Contact parsing parameters from [json].
  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      json['phone'],
      json['username'],
      Image.memory(base64Decode(json['photo'])),
      json['isOnline'],
    );
  }

  @override
  String toString() {
    return 'Contact{phone: $phone, username: $username, profileImage: $profileImage}';
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
