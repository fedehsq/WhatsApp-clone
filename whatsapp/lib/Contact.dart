import 'dart:io';
import 'package:flutter/material.dart';

import 'Message.dart';

/// Class representing a platform user
class Contact {
  final String phone;
  final String username;

  // todo: CHANGE WHEN IMPLEMENT DB
  final AssetImage profileImage;

  // ha associaTO UNa lista di messaggi che sarà a sua volta una classe, che contiene il timestamp
  final List<Message> messages;

  Contact(this.phone, this.username, this.profileImage, this.messages);
}

