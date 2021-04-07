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

  final debugString =  "VEDIAMO DI DEBUGGARE STA CAZZO DI COSA \n";
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
                snapshot.hasData ? '${snapshot.data}' : 'start',
                style: TextStyle(color: TEXT_COLOR),),));
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: chat.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Align(
                        alignment: index % 2 == 0
                            ? Alignment.centerRight
                            : Alignment
                            .centerLeft, child: chat[index],);
                    },),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    onSubmitted: (message) {

                      chat.add(Container(color: PRIMARY_COLOR,
                          child: Text(
                              debugString + debugString + debugString + debugString
                              , style: TextStyle(color: TEXT_COLOR)
                          )
                      ));
                      channel.sink.add(message);
                    },
                    style: TextStyle(color: TEXT_COLOR),
                    decoration: InputDecoration(
                      hintText: 'Scrivi un messaggio',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
    );
  }
}
