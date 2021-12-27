import 'package:flutter/material.dart';
import '../chat/chat.dart';
import '../../models/contact.dart';
import '../../main.dart';

class ContactsScreen extends StatefulWidget {
  final List<Contact> online;
  final Contact lastContactChat;

  const ContactsScreen(
      {Key? key, required this.online, required this.lastContactChat})
      : super(key: key);

  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final contactListView = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Seleziona'),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () => {}),
          IconButton(icon: const Icon(Icons.search), onPressed: () => {}),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.online.length,
        itemBuilder: (BuildContext context, int index) {
          buildContactList();
          return contactListView[index];
        },
      ),
    );
  }

  /// On opening this screen all online contacts are loaded
  buildContactList() {
    for (var c in widget.online) {
      contactListView.add(buildListTile(c));
    }
  }

  /// Build the Widget representing a contact with his info
  buildListTile(Contact contact) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        onTap: () async {
          // ----- Even if i wait, the build method is called -----
          // FLUTTER IS MAGIC!
          // Start Chat screen
          Contact chatter = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Chat(contact: contact)),
          );
          Navigator.pop(context, chatter);
        },
        leading: CircleAvatar(
            radius: 25, backgroundImage: contact.profileImage.image),
        title: Text(
          contact.username,
          style: const TextStyle(color: textColor),
        ),
      ),
    );
  }
}
