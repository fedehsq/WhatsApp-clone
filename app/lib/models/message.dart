/// Class representing text message, it contains message and timestamp
class Message {
  final String text;
  final bool fromServer;
  late DateTime timestamp;

  Message(this.text, this.fromServer) {
    timestamp = DateTime.now();
  }
}
