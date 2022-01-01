import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:whatsapp_clone/api.dart';
import '../chat/chat_screen.dart';
import '../../models/contact.dart';
import '../../main.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({Key? key}) : super(key: key);

  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final IOWebSocketChannel mainChannel = IOWebSocketChannel.connect(server);

  @override
  void initState() {
    mainChannel.sink.add(jsonEncode({'operation': users}));
    super.initState();
  }

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
        body: StreamBuilder(
            stream: mainChannel.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var json = jsonDecode(snapshot.data.toString());
                var encodedBody = json['body'];
                List<dynamic> contacts = jsonDecode(encodedBody['users']);
                return ListView.builder(
                  itemCount: contacts.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildListTile(
                        Contact.fromJson(jsonDecode(contacts[index])));
                  },
                );
              }
              return Container();
            }));
  }

  /// Build the Widget representing a contact with his info
  Padding _buildListTile(Contact contact) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        onTap: () async {
          // ----- Even if i wait, the build method is called -----
          // FLUTTER IS MAGIC!
          // Start Chat screen
          Contact chatter = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Chat(contact: contact, addMessage: contact.messages.isEmpty ? true : false)),
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
