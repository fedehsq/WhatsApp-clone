import 'package:flutter/cupertino.dart';

import 'message.dart';

/// Class representing a platform user
class Contact {
  final String phone;
  final String username;
  final Image profileImage;
  late int toRead;
  bool isOnline;
  late List<Message> messages;

  Contact(this.phone, this.username, this.profileImage, this.isOnline) {
    toRead = 0;
    messages = [Message('', true)]; // message list
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
          phone == other.phone &&
          username == other.username;

  @override
  int get hashCode => phone.hashCode ^ username.hashCode;
}
