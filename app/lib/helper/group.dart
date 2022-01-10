import 'dart:collection';
import 'dart:convert';

import 'package:whatsapp_clone/api.dart';
import 'package:whatsapp_clone/helper/contact.dart';

import 'message.dart';
import 'contact.dart';

/// Class representing a chat group.
class Group<Contact> extends ListBase<Contact> {
  final List<Contact> group = [];
  Group();

  @override
  int get length => group.length;
  @override
  Contact operator [](int index) => group[index];
  @override
  void operator []=(int index, Contact value) {
    group[index] = value;
  }

  @override
  set length(int newLength) {
    group.length = newLength;
  }
}
