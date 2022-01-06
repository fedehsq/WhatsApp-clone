import 'package:whatsapp_clone/helper/Contact.dart';

/// Class representing the db model of a registered user to WhatsApp.
class ContactModel {
  final String phone;
  final String username;
  final String urlImage;
  final int toRead;

  ContactModel(this.phone, this.username, this.urlImage, this.toRead);

  /// Returns a new Contact parsing parameters from [contact].
  factory ContactModel.fromContact(Contact contact) {
    return ContactModel(
        contact.phone, contact.username, contact.urlImage, contact.toRead);
  }

/*
  /// Returns a new Contact parsing parameters from [json].
  factory ContactModel.fromJson(Map<String, dynamic> json) {
    ContactModel contact = ContactModel();
    contact.phone = json['phone'];
    contact.username = json['username'];
    contact.profileImage = json['profile_image'];
    contact.toRead = json['to_read'];
    return contact;
  }
  */

  /// Returns a map representation of this [ContactModel].
  Map<String, Object?> toMap() {
    
    return {
      'phone': phone,
      'username': username,
      'profile_image': urlImage,
      'to_read': toRead
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactModel &&
          runtimeType == other.runtimeType &&
          phone == other.phone;

  @override
  int get hashCode => phone.hashCode;
}
