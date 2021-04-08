import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/io.dart';
import 'Contact.dart';
import 'Message.dart';
import 'main.dart';

class Chat extends StatefulWidget {
  final Contact contact;

  const Chat({Key key, this.contact}) : super(key: key);
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final channel = IOWebSocketChannel.connect('ws://echo.websocket.org');
  // for user input
  final TextEditingController messageController = TextEditingController();
  // text message
  final chatListView = [];
  // chat must scroll down at every received message
  ScrollController controller = ScrollController();

  var input;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8, bottom: 8.0),
            child: CircleAvatar(
              backgroundImage: widget.contact.profileImage,
              backgroundColor: PRIMARY_COLOR,),
          )
          ,
          backgroundColor: PRIMARY_COLOR,
          title: Text(widget.contact.username),
          actions: [
            IconButton(
                onPressed: () => {},
                icon: Icon(Icons.videocam_rounded)),
            IconButton(onPressed: () => {},
                icon: Icon(Icons.call)),
            IconButton(onPressed: () => {},
                icon: Icon(Icons.more_vert)),
          ],
        ),
        body: StreamBuilder(
            stream: channel.stream,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              // add message of other client
              if (snapshot.hasData) {
                chatListView.add(
                    buildMessageLayout(Message('${snapshot.data}'), true));
              }
              return Stack(
                  children: [
                    SingleChildScrollView(
                      child: Opacity(
                          opacity: 0.1,
                          child: Image(
                              image: AssetImage('images/chat_bg.png'))),
                    ),
                    Column(
                      children: [
                        Expanded(

                          /// NOTHING TO CONTROL! IF THERE IS A MESSAGE, THEN SNAPSHOT HAS DATA
                          child: ListView.builder(
                              controller: controller,
                              itemCount: chatListView.length,
                              itemBuilder: (BuildContext context, int index) {
                                /// DEVO COSTRUIRE IL MESSAGGIO INVIATO DA ME NEL CLICK DI SOTTO
                                return chatListView[index];
                              }),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: TextField(
                                  controller: messageController,
                                  style: TextStyle(color: TEXT_COLOR),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: PRIMARY_COLOR,
                                    prefixIcon: Icon(
                                      Icons.emoji_emotions,
                                      color: Colors.grey,),
                                    contentPadding: EdgeInsets.only(left: 8),
                                    hintText: 'Scrivi un messaggio',
                                    suffixIcon: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.attachment),
                                          color: TEXT_COLOR, onPressed: () {},),
                                        IconButton(
                                          icon: Icon(
                                              Icons.photo_camera_rounded),
                                          color: TEXT_COLOR, onPressed: () {},),
                                      ],
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(Icons.circle, color: SECONDARY_COLOR,
                                    size: 56,
                                  ),
                                  IconButton(onPressed: () {
                                    // save user input
                                    input = messageController.text;
                                    chatListView.add(buildMessageLayout(
                                        Message(input), false));
                                    messageController.text = '';

                                    // WAIT A COUPLE OF MS, OTHERWISE SERVER
                                    // RESPOND TO FAST!
                                    // MORE DELAY IS NECESSARY TO UPDATE LIST!
                                    channel.sink.add(input);
                                    Timer(Duration(milliseconds: 300), () {
                                      controller.jumpTo(
                                          controller.position.maxScrollExtent);
                                    });
                                  },
                                      icon: Icon(
                                          Icons.send, color: Colors.white))
                                ]
                            )
                          ],
                        ),
                      ],
                    ),
                  ]
              );
            }
        )
    );
  }

  // Build message view, am i the sender or not?
  buildMessageLayout(Message message, bool fromServer) {
    return Align(
        alignment: fromServer
            ? Alignment.centerLeft
            : Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
              constraints: BoxConstraints(maxWidth: 350),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: fromServer
                    ? PRIMARY_COLOR
                    : CHAT_COLOR,
              ),
              padding: EdgeInsets.all(8),
              child: fromServer ?
              Text(
                  message.text,
                  style: TextStyle(
                      color: TEXT_COLOR,
                      fontSize: 16)
              ) :
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible( // WHAT'S A MAGIC THIS FRAMEWORK!
                    child: Text(
                        message.text,
                        style: TextStyle(
                            color: TEXT_COLOR,
                            fontSize: 16)
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 8.0, right: 4),
                    child: Text(message.timestamp,
                        style: TextStyle(
                            height: 2,
                            color: Colors.grey,
                            fontSize: 10)
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Icon(Icons.done_all, color: Colors.blue, size: 16,),
                  )
                ],
              )
          ),
        )
    );
  }
}