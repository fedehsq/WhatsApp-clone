import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/io.dart';
import 'Chat.dart';
import 'Contact.dart';
import 'Chat.dart';
import 'Message.dart';
import 'main.dart';

class ChatList extends StatefulWidget {

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {

  final channel = IOWebSocketChannel.connect('ws://echo.websocket.org');
  final List <Contact> contacts = [
    Contact("xxx", "Echo Server", AssetImage('images/d.png'), [])
  ];
  final echo = Contact("xxx", "Echo Server", AssetImage('images/d.png'), []);
  final textController = TextEditingController();



  buildListTile(Contact contact, Message message) {
    return ListTile(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(
              builder: (BuildContext context) =>
                  Chat(contact: contact))),
      leading: CircleAvatar(
        radius: 25,
        backgroundImage: contact.profileImage,),
      title:
      Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(contact.username, style: TextStyle(color: TEXT_COLOR),),
            Text(
              message.timestamp, style: TextStyle(color: Colors.grey, fontSize: 10),)
          ],
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Icon(Icons.done_all,
                  color: Colors.blue, size: 16,),
                Text(message.text,
                  style: TextStyle(color: Colors.grey),),
              ],
            ),
          ),
          Divider(color: Colors.grey, thickness: 0.1,)
        ],
      ),
    );
  }

  /// At every received message, add last message in the preview and put
  /// sender as head item, the last items don't change
  List<ListTile> buildChatList(String sender, Message message) {
    List<ListTile> l = [];
    for (int i = 0; i < contacts.length; i++) {
      if (contacts[i].phone == sender) {
        // Put him in head
        l.insert(0, buildListTile(contacts[i], message));
      } else {
        // rebuilt previous item in the same way (pass last chat message!)
        l.add(buildListTile(contacts[i],
            contacts[i].messages[contacts[i].messages.length - 1]
        ));
      }
    }
    return l;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: channel.stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            // todo: read from db here!
            List l = buildChatList(echo.phone, Message('Start'));
            return ListView.builder(
              padding: EdgeInsets.only(top: 8),
              itemCount: l.length,
              itemBuilder: (BuildContext context, int index) {
                return l[index];
              },
            );
          } else {
            /*
            var received = '${snapshot.data}';
            var sender = received.split(':')[0];
            var message = received.split(':')[1];
             */
            List l = buildChatList(echo.phone, Message('${snapshot.data}'));
            return ListView.builder(
                padding: EdgeInsets.only(top: 8),
                itemCount: l.length,
                itemBuilder: (BuildContext context, int index) {
                  return l[index];
                });
          }
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          style: TextStyle(color: TEXT_COLOR),
          controller: textController,
          onSubmitted: (message) => channel.sink.add(message),
        ),
      ),
    );
  }
}
