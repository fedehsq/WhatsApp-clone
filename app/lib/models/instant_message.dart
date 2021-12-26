/// Message to send to the server containing destination and text message
class InstantMessage {
  final String dest;
  final String message;

  InstantMessage(this.dest, this.message);

  Map<String, String> toJson() => {'dest': dest, 'message': message};
}
