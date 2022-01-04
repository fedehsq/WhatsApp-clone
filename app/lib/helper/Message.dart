import 'dart:convert';
import 'Contact.dart';

/// Class representing text message, it contains message and timestamp.
/// This is a field of [Contact] class.
class Message {
  final String text;
  final bool fromServer;
  final DateTime timestamp;

  Message(this.text, {timestamp, required this.fromServer})
      : timestamp = timestamp ?? DateTime.now();

  /// Returns a new [Message] parsing parameters from [model].
  factory Message.fromModel(Map<String, dynamic> model) {
    return Message(model['text'],
        timestamp: DateTime.parse(model['timestamp']),
        fromServer: model['from_server'] == 1 ? true : false);
  }
  /// Returns a new [Message] parsing parameters from [json].
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(json['text'],
        timestamp: DateTime.parse(json['timestamp']),
        fromServer: json['fromServer']);
  }

  /// Returns a map representation of this [Message].
  Map<String, Object?> toMap() {
    return {
      'text': text,
      'fromServer': fromServer,
      'timestamp': timestamp
    };
  }

  @override
  String toString() {
    return jsonEncode({
      'text': text,
      'fromServer': fromServer,
      'timestamp': timestamp.toString()
    });
  }
}
