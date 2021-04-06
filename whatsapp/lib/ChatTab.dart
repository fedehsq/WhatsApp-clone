import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/io.dart';
import 'Chat.dart';
import 'main.dart';

class ChatList extends StatefulWidget {

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {

  final channel = IOWebSocketChannel.connect('ws://echo.websocket.org');
  final contacts = ['Fede', 'Paola', 'Lollo', 'Ale', 'Gabri', 'Fabio'];
  final textController = TextEditingController();

  String getTime() {
    var now = new DateTime.now();
    var formatter = new DateFormat('hh:mm');
    String formattedDate = formatter.format(now);
    return formattedDate; // 2016-01-25
  }

  buildListTile(String contact, String message) {
    return ListTile(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(
              builder: (BuildContext context) =>
                  Chat(contact: contact))),
      leading: CircleAvatar(
        backgroundImage: AssetImage('images/account.png'),),
      title:
      Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(contact, style: TextStyle(color: TEXT_COLOR),),
            Text(
              getTime(), style: TextStyle(color: Colors.grey, fontSize: 10),)
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
                Text(message,
                  style: TextStyle(color: Colors.grey),),
              ],
            ),
          ),
          Divider(height: 20, color: Colors.grey,)
        ],
      ),
    );
  }

  // devo ricostruire la solita lista ma con un elemento cambiato
  // TANTO DEVO RICREARLA TUTTA OGNI VOLTA, QUINDI PRIMA DI COSTRUIRLA GRAFICAMENTE
  // CONTROLLO CHI HA INVIATO IL MESSAGGIO
  List<ListTile> getChatList(String sender, String message) {
    List<ListTile> l = [];
    for (int i = 0; i < contacts.length; i++) {
      if (contacts[i] == sender) {
        //contacts.insert(0, sender);
        l.insert(0, buildListTile(sender, message));
      } else {
        l.add(buildListTile(contacts[i], ''));
      }
    }
    return l;
  }

  /*
  @override
  Widget build(BuildContext context) {
    List l = getChatList('', '');
    return Scaffold(
        body:
        ListView.builder(
          padding: EdgeInsets.only(top: 8),
          itemCount: l.length,
          itemBuilder: (BuildContext context, int index) {
            return l[index];
          },
        )
    );
  }

   */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: channel.stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            List l = getChatList('', '');
            return ListView.builder(
              padding: EdgeInsets.only(top: 8),
              itemCount: l.length,
              itemBuilder: (BuildContext context, int index) {
                return l[index];
              },
            );
          } else {
            var received = '${snapshot.data}';
            var sender = received.split(':')[0];
            var message = received.split(':')[1];
            List l = getChatList(sender, message);
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
