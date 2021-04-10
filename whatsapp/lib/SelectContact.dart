
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'Chat.dart';
import 'Contact.dart';
import 'Message.dart';
import 'main.dart';

class SelectContact extends StatefulWidget {
  final List<Contact> online;

  const SelectContact({Key key, this.online}) : super(key: key);

  @override
  _SelectContactState createState() => _SelectContactState();
}

class _SelectContactState extends State<SelectContact> {
  var contactListView;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: PRIMARY_COLOR,
          title: Text('Seleziona'),
        actions: [
          IconButton(icon: Icon(Icons.more_vert), onPressed: () => {}),
          IconButton(icon: Icon(Icons.search), onPressed: () => {}),
        ],
      ),
      body: ListView.builder(itemBuilder: (BuildContext context, int index) {

      },),
    );
  }

  /// On opening Chat screen all messages are loaded
  buildInitialList() {
    for (var c in widget.online) {
        contactListView.add(
            buildListTile(c));
      }
    }

  /// Build the Widget representing a contact with his info
  buildListTile(Contact contact) {
    return ListTile(
      onTap: () async {
        // ----- Even if i wait, the build method is called -----
        // FLUTTER IS MAGIC!
        // Start Chat screen
        final lastContactChat = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Chat(contact: contact)),
        );
      },

      leading: CircleAvatar(
        radius: 25,
        backgroundImage: AssetImage('images/default_profile_pic.png'),),
      title:
      Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 4.0),
        child: Text(contact.username, style: TextStyle(color: TEXT_COLOR),),
      ),
    );
  }


}
