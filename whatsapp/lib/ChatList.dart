import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'main.dart';

class ChatList extends StatefulWidget {

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {

  //final channel = IOWebSocketChannel.connect('ws://echo.websocket.org');
  

  String getTime() {
    var now = new DateTime.now();
    var formatter = new DateFormat('hh:mm');
    String formattedDate = formatter.format(now);
    return formattedDate; // 2016-01-25
  }

  List<ListTile> buildList(String s) {
    List<ListTile> l = [];
    for (int i = 0; i < 20; i++) {
      l.add(ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage('images/account.png'),),
        title:
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Chat $i', style: TextStyle(color: TEXT_COLOR),),
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
                    color: i % 2 == 0 ? Colors.blue : Colors.grey, size: 16,),
                  Text(s.isEmpty ? ' Last message from $i' : s,
                    style: TextStyle(color: Colors.grey),),
                ],
              ),
            ),
            Divider(height: 20, color: Colors.grey,)
          ],
        ),
      ));
    }
    return l;
  }
  
  @override
  Widget build(BuildContext context) {
    List l = buildList('');
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

  /*@override
  Widget build(BuildContext context) {
    List l = buildList('');
    return Scaffold(
      body: StreamBuilder(
        stream: channel.stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return ListView.builder(
              itemCount: l.length,
              itemBuilder: (BuildContext context, int index) {
                return l[index];
            },
            );
          } else {
            return ListView.builder(
              itemCount: l.length,
              itemBuilder: (BuildContext context, int index) {

              return l[index];
            });
          }
        },
      ),
      floatingActionButton: TextButton(
        onPressed: () { channel.sink.add('Hello, world!'); },
        child: Text('ECHO'),
      ),
    );
  }
   */
}
