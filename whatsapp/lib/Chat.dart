import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/io.dart';
import 'main.dart';

class Chat extends StatefulWidget {
  final String contact;


  const Chat({Key key, this.contact}) : super(key: key);
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {

  // aggiorno ad ogni invio/ricezione
  final chat = [];
  final channel = IOWebSocketChannel.connect('ws://echo.websocket.org');


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contact),
        actions: [
          Icon(Icons.more_vert),
          Icon(Icons.call),
          Icon(Icons.video_call),
        ],
      ),
      body:
          StreamBuilder(
              stream: channel.stream,

              builder: (BuildContext context, snapshot) {
                chat.add(Container(color: Colors.blueGrey,
                  child: Text(
                    '$snapshot.data', style: TextStyle(color: TEXT_COLOR),),));
                return ListView.builder(
                  itemCount: chat.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Align(
                      alignment: index % 2 == 0
                          ? Alignment.centerRight
                          : Alignment
                          .centerLeft, child: chat[index],);
                  },);
              }),
      bottomNavigationBar: TextField(
        onSubmitted: (message) =>
            setState(() {
              chat.add(Container(color: PRIMARY_COLOR,
                child: Text(
                  message, style: TextStyle(color: TEXT_COLOR),),));
            }),
        style: TextStyle(color: TEXT_COLOR),
        decoration: InputDecoration(
          hintText: 'Scrivi un messaggio',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              width: 0,
              style: BorderStyle.none,
            ),
          ),
        ),
      ),
    );
  }
}
