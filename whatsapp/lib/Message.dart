import 'package:intl/intl.dart';

/// Class representing text message, it contains message and timestamp
class Message {
  final String text;
  final bool fromServer;
  String timestamp;

  Message(this.text, this.fromServer) {
    var now = new DateTime.now();
    var formatter = new DateFormat('HH:mm');
    timestamp = formatter.format(now);
  }

}