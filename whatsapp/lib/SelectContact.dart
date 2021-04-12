
import 'package:flutter/material.dart';
import 'Chat.dart';
import 'Contact.dart';
import 'main.dart';

class SelectContact extends StatefulWidget {
  final List<Contact> online;

  const SelectContact({Key key, this.online}) : super(key: key);

  @override
  _SelectContactState createState() => _SelectContactState();
}

class _SelectContactState extends State<SelectContact> {
  final contactListView = [];
  var lastContactChat;

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
      body: ListView.builder(
        itemCount: widget.online.length,
        itemBuilder: (BuildContext context, int index) {
            buildContactList();
            return contactListView[index];
      },),
    );
  }

  /// On opening this screen all online contacts are loaded
  buildContactList() {
    for (var c in widget.online) {
        contactListView.add(
            buildListTile(c));
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
          lastContactChat = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Chat(contact: contact)),
          );
          Navigator.pop(context, lastContactChat);
        },
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: contact.profileImage.image),
        title:
        Text(contact.username, style: TextStyle(color: TEXT_COLOR),),
      ),
    );
  }
}