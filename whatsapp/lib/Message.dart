import 'package:intl/intl.dart';

/// Class representing text message, it contains message and timestamp
class Message {
  final String text;
  final bool fromServer;
  DateTime timestamp;

  Message(this.text, this.fromServer) {
    timestamp = new DateTime.now();
  }

}