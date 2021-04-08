import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';  //for date locale


/// Class representing text message, it contains message and timestamp
class Message {
  final String text;
  String timestamp;

  Message(this.text) {
    var now = new DateTime.now();
    var formatter = new DateFormat('HH:mm');
    timestamp = formatter.format(now);
  }
}