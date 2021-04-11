


import 'package:flutter/cupertino.dart';

import 'Message.dart';

/// Class representing a platform user
class Contact {
  final String phone;
  final String username;
  final Image profileImage;

  // ha associaTO UNa lista di messaggi che sarà a sua volta una classe, che contiene il timestamp
  final List<Message> messages;

  Contact(this.phone, this.username, this.profileImage, this.messages);

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
