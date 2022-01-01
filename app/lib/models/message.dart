import 'dart:convert';
import '../../models/contact.dart';

/// Class representing text message, it contains message and timestamp.
/// This is a field of [Contact] class.
class Message {
  final String text;
  final bool fromServer;
  final DateTime timestamp;

  Message(this.text, {required this.fromServer}) : timestamp = DateTime.now();

  @override
  String toString() {
    return jsonEncode({
      'text': text,
      'fromServer': fromServer,
      'timestamp': timestamp.toString()
    });
  }
}
