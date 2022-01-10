import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:whatsapp_clone/api.dart';
import 'package:whatsapp_clone/dao/contact_dao.dart';
import 'package:whatsapp_clone/helper/group.dart';
import '../chat/chat_screen.dart';
import '../../helper/contact.dart';
import '../../main.dart';

class GroupContactsScreen extends StatefulWidget {
  const GroupContactsScreen({Key? key})
      : super(key: key);

  @override
  _GroupContactsScreenState createState() => _GroupContactsScreenState();
}

class _GroupContactsScreenState extends State<GroupContactsScreen> {
  final IOWebSocketChannel mainChannel = IOWebSocketChannel.connect(server);
  final Group group = Group();

  @override
  void initState() {
    mainChannel.sink.add(jsonEncode({'operation': users}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: primaryColor,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nuovo gruppo'), 
              group.isEmpty
                  ? const Text('Aggiungi partecipanti', style: TextStyle(fontSize: 13),)
                  : Text(
                      '${group.length} di 256 selezionati',
                      style: const TextStyle(fontSize: fontSize),
                    ),
            ],
          ),
          actions: [
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

  /// Build the Widget representing a [contact] with his info.
  Padding _buildListTile(Contact contact) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        onTap: () {
          int index = group.indexOf(contact);
          if (index == -1) {
            group.add(contact);
          } else {
            group.removeAt(index);
          }
          setState(() {});
        },
        leading: CircleAvatar(
            radius: 25, backgroundImage: Image.network(contact.urlImage).image),
        title: Text(
          contact.username,
          style: const TextStyle(color: textColor),
        ),
      ),
    );
  }
}
